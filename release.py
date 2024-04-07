import concurrent.futures
import datetime
import os
import re
import shutil
import subprocess
import traceback

import yaml


class VersionManager:
    def __init__(self, yaml_file_path, output_folder):
        self.yaml_file_path = yaml_file_path
        self.output_folder = os.path.expanduser(output_folder)
        self.version_regex = r'^(\d{4}\.\d{2}\.\d{2})\+(\d+)$'
        self.version_date_format = '%Y.%m.%d'
        self.current_version = self.read_version()
        self.calc_version()
        self.tasks = ['apk', 'ios']

    def read_version(self):
        print('开始读取当前版本号')
        with open(self.yaml_file_path, 'r') as file:
            yaml_data = yaml.safe_load(file)
            return yaml_data.get('version')

    def calc_version(self):
        print(f'当前版本号：{self.current_version}')
        print('开始计算新版本号')
        match = re.match(self.version_regex, self.current_version)
        if match:
            date_str, count_str = match.groups()
            current_date = datetime.datetime.strptime(date_str, self.version_date_format)
            current_count = int(count_str)
            if current_date.date() == datetime.datetime.now().date():
                current_count += 1
            else:
                current_date = datetime.datetime.now()
                current_count = 1
            self.new_version = f"{current_date.strftime(self.version_date_format)}+{current_count}"
            print(f'新版本号：{self.new_version}')
            print(f'开始替换新版本号')
            self.update_version(self.new_version)
            return True
        else:
            return False

    def update_version(self, new_version):
        with open(self.yaml_file_path, 'r') as file:
            yaml_data = yaml.safe_load(file)
            yaml_data['version'] = new_version
        with open(self.yaml_file_path, 'w') as file:
            yaml.safe_dump(yaml_data, file, default_flow_style=False, sort_keys=False)

    def compile(self, flag):
        print(f'开始打包：flutter build {flag}')
        try:
            if flag == 'apk':
                subprocess.run(["flutter", "build", "apk"])
                print(f'APK 编译完成，正在移动到指定文件夹 {self.output_folder}')
                shutil.move("build/app/outputs/flutter-apk/app-release.apk",
                            f"{self.output_folder}/harvest_{self.new_version}.apk")
                print(f'APK 打包完成')
            elif flag == 'ios':
                subprocess.run(["flutter", "build", "ios"])
                print(f'IOS 编译完成，打包为 ipa 文件')
                shutil.rmtree("build/ios/iphoneos/Payload", ignore_errors=True)
                os.makedirs("build/ios/iphoneos/Payload", exist_ok=True)
                shutil.move("build/ios/iphoneos/Runner.app", "build/ios/iphoneos/Payload/")
                shutil.make_archive("build/ios/iphoneos/Payload", 'zip',
                                    "build/ios/iphoneos/Payload")
                print(f'ipa 打包完成，正在移动到指定文件夹 {self.output_folder}')
                shutil.move("build/ios/iphoneos/Payload.zip",
                            f"{self.output_folder}/harvest_{self.new_version}.ipa")
                shutil.rmtree("build/ios/iphoneos/Payload")
                print(f'IOS 打包完成')
        except Exception as e:
            print(f"{flag} 打包失败: {e}")
            print(traceback.format_exc())
            print(f'回滚版本号到 {self.current_version}')
            self.update_version(self.current_version)

            raise e

    def compile_and_install(self):
        with concurrent.futures.ThreadPoolExecutor() as executor:
            # 使用 executor.map 并行执行 compile 方法
            results = executor.map(self.compile, ['ios', 'apk'])
            # 处理结果或捕获异常
            for result in results:
                try:
                    result
                except Exception as e:
                    print(f"Compilation failed: {e}")
                    raise e


if __name__ == '__main__':
    manager = VersionManager('pubspec.yaml', '~/Desktop/harvest')
    manager.compile_and_install()
