import concurrent.futures
import datetime
import os
import platform
import re
import shutil
import subprocess
import sys
import traceback
import argparse

import yaml


class VersionManager:
    def __init__(
        self,
        output_folder,
        yaml_file_path="pubspec.yaml",
    ):
        self.yaml_file_path = yaml_file_path
        self.output_folder = os.path.expanduser(output_folder)
        # 确保输出目录存在
        os.makedirs(self.output_folder, exist_ok=True)
        self.version_regex = r"^(\d{4}\.\d{4}).(\d+)\+(\d+)$"
        self.version_date_format = "%Y.%m%d"
        self.ios_path = "build/ios/iphoneos/"
        self.current_version = self.read_version()
        self.new_version = self.current_version
        self.machine = self.calc_machine()
        self.tasks = ["macos"]
        # 只在 Apple Silicon 的 macOS 上执行版本号自增
        is_arm_mac = sys.platform.startswith("darwin") and platform.processor() == "arm"
        if is_arm_mac:
            self.calc_version()
            self.tasks = ["apk", "ios", "macos"]

        if sys.platform.startswith("win32"):
            self.output_folder = self.output_folder.replace("/", "\\")
            self.tasks = ["windows"]
        self.fvm = self.get_fvm_command()

    @staticmethod
    def get_fvm_command():
        if shutil.which("fvm"):
            print("fvm 已安装")
            return "fvm"
        else:
            print("fvm 未安装")
            return ""

    @staticmethod
    def calc_machine():
        machine = platform.machine().lower()

        x86_set = {"x86_64", "amd64"}
        x86_32_set = {"i386", "i686"}
        arm64_set = {"arm64", "aarch64"}
        arm32_set = {"arm", "armv7", "armv7l", "armhf"}

        if machine in x86_set:
            return "x86_64"
        elif machine in x86_32_set:
            return "x86_32"
        elif machine in arm64_set:
            return "arm64"
        elif machine in arm32_set:
            return "arm32"
        else:
            return "unknown"

    def read_version(self):
        print("开始读取当前版本号")
        with open(self.yaml_file_path, "r") as file:
            yaml_data = yaml.safe_load(file)
            return yaml_data.get("version")

    def calc_version(self):
        print(f"当前版本号：{self.current_version}")
        print("开始计算新版本号")
        match = re.match(self.version_regex, self.current_version)
        if match:
            date_str, count_str, build_str = match.groups()
            print(date_str, count_str, build_str)
            current_date = datetime.datetime.strptime(
                date_str, self.version_date_format
            )
            current_count = int(count_str)
            build_str = int(build_str)
            if current_date.date() == datetime.datetime.now().date():
                current_count += 1
                if current_count < 9:
                    current_count = f"0{current_count}"
            else:
                current_date = datetime.datetime.now()
                current_count = "01"
            build_str += 1
            self.new_version = f"{current_date.strftime(self.version_date_format)}.{current_count}+{build_str}"
            print(f"新版本号：{self.new_version}")
            print(f"开始替换新版本号")
            self.update_version(self.new_version)
            return True
        else:
            return False

    def update_version(self, new_version):
        with open(self.yaml_file_path, "r") as file:
            yaml_data = yaml.safe_load(file)
            yaml_data["version"] = new_version
        with open(self.yaml_file_path, "w") as file:
            yaml.safe_dump(yaml_data, file, default_flow_style=False, sort_keys=False)

    def compile(self, flag):
        print(f"开始打包：{self.fvm} flutter build {flag}")
        try:
            if flag == "apk":
                subprocess.run([self.fvm, "flutter", "build", "apk"])
                print(f"APK 编译完成，正在移动到指定文件夹 {self.output_folder}")
                shutil.move(
                    "build/app/outputs/flutter-apk/app-release.apk",
                    f"{self.output_folder}/harvest_{self.new_version}.apk",
                )
                print(f"APK 打包完成")
            elif flag == "macos":
                subprocess.run([self.fvm, "flutter", "build", "macos"])
                print(f"macos APP 编译完成，正在移动到指定文件夹 {self.output_folder}")
                res = subprocess.run(
                    "zip -r harvest.app.zip harvest.app",
                    cwd="build/macos/Build/Products/Release/",
                    shell=True,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                )
                print(res.stdout.decode("utf-8"))
                shutil.move(
                    "build/macos/Build/Products/Release/harvest.app.zip",
                    f"{self.output_folder}/harvest_{self.new_version}_{self.machine}-macos.zip",
                )
                print(f"MacOS 打包完成")
            elif flag == "windows":
                res = subprocess.run(
                    f"{self.fvm} flutter build windows",
                    shell=True,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                )
                print(f"{res.stdout.decode('utf-8')}")
                print(f"Windows APP 编译完成, 开始压缩")
                zip_path = shutil.make_archive(
                    "Release",
                    "zip",
                    os.path.join(os.getcwd(), "build\\windows\\x64\\runner\\Release"),
                )
                print(f"压缩结果：{os.path.exists(zip_path)}")
                print(
                    f"APP 压缩完毕，准备移动，正在移动到指定文件夹 {self.output_folder}"
                )
                shutil.move(
                    zip_path,
                    f"{self.output_folder.replace('/', '\\')}\\harvest_{self.current_version}_{self.machine}-win.zip",
                )
                print(f"Windows 打包完成，打开文件夹")
                #                 subprocess.run(
                #                     [f"explorer", self.output_folder.replace('/', '\\')],
                #                     shell=True,
                #                     stdout=subprocess.PIPE, stderr=subprocess.PIPE
                #                 )
            elif flag == "ios":
                res = subprocess.run(
                    ["rm -rf build/ios/iphoneos/*"],
                    shell=True,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                )
                print(res.stdout.decode("utf-8"))
                res = subprocess.run(
                    f"{self.fvm} flutter build ios",
                    shell=True,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                )
                print(res.stdout.decode("utf-8"))
                print(f"IOS 编译完成，打包为 ipa 文件")
                res = subprocess.run(
                    "mkdir -p Payload/",
                    cwd=self.ios_path,
                    shell=True,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                )
                print(res.stdout.decode("utf-8"))
                res = subprocess.run(
                    "mv Runner.app Payload/",
                    cwd=self.ios_path,
                    shell=True,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                )
                print(res.stdout.decode("utf-8"))
                res = subprocess.run(
                    "zip -r Payload.zip Payload",
                    cwd=self.ios_path,
                    shell=True,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                )
                print(f'命令执行成功！{res.stdout.decode("utf-8")}')
                print(
                    f"ipa 打包完成，正在移动到指定文件夹 {self.output_folder}/harvest_{self.new_version}.ipa"
                )
                shutil.move(
                    "build/ios/iphoneos/Payload.zip",
                    f"{self.output_folder}/harvest_{self.new_version}.ipa",
                )

                print(f"IOS 打包完成")
        except Exception as e:
            print(f"{flag} 打包失败: {e}")
            print(traceback.format_exc())
            print(f"回滚版本号到 {self.current_version}")
            self.update_version(self.current_version)

            raise e

    def compile_and_install(self):
        with concurrent.futures.ThreadPoolExecutor() as executor:
            #             # 使用 executor.map 并行执行 compile 方法
            #             if sys.platform.startswith('win32'):
            #                 tasks = ['windows']
            #             if sys.platform.startswith('darwin'):
            #                 tasks = [
            #                     'apk',
            #                     'ios',
            #                     'macos',
            #                 ]
            # results = executor.map(self.compile, tasks)
            results = [self.compile(task) for task in self.tasks]
            # 处理结果或捕获异常
            for result in results:
                try:
                    result
                except Exception as e:
                    print(f"Compilation failed: {e}")
                    raise e
            subprocess.run(
                [
                    "explorer" if sys.platform.startswith("win32") else "open",
                    self.output_folder,
                ]
            )


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Flutter build helper.")
    parser.add_argument(
        "output_folder",
        nargs='?',
        default="~/Desktop/harvest",
        help="目标输出目录，支持相对路径，默认路径： ~/Desktop/harvest",
    )
    parser.add_argument(
        "--yaml",
        "-y",
        default="pubspec.yaml",
        help="pubspec.yaml 路径（默认：pubspec.yaml）",
    )
    args = parser.parse_args()
    manager = VersionManager(args.output_folder, yaml_file_path=args.yaml)
    #     manager = VersionManager('~/Desktop/harvest')
    manager.compile_and_install()
    # manager.calc_version()
