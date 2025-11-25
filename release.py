import argparse
import concurrent.futures
import datetime
import os
import platform
import re
import shutil
import subprocess
import sys
import tempfile
import traceback
import yaml

if sys.platform.startswith("darwin"):
    import dmgbuild


class VersionManager:
    def __init__(
            self,
            output_folder,
            yaml_file_path="pubspec.yaml",
            tasks=None,
            calc=True,
    ):
        print("初始化 VersionManager")
        print(
            f"初始化任务参数：yaml文件路径: {yaml_file_path}   任务列表:{tasks}  是否计算版本号: {calc} {type(calc)}")

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
        if calc:
            # 执行版本号自增
            self.calc_version()
        # 按照新的版本号创建输出目录
        print(f"当前编译版本号：{self.new_version}")
        self.output_folder = os.path.join(self.output_folder, self.new_version)
        print(f"当前输出文件夹：{self.output_folder}")
        if not tasks:
            self.tasks = ["macos"]

            is_mac = sys.platform.startswith("darwin")
            if is_mac:
                self.tasks = ["apk", "ipa", "macos"]

            if sys.platform.startswith("win32"):
                self.output_folder = self.output_folder.replace("/", "\\")
                self.tasks = ["windows"]
        else:
            self.tasks = tasks
        # 确保输出目录存在
        os.makedirs(self.output_folder, exist_ok=True)
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
                # 分架构打包，生成多个架构版本的 APK
                subprocess.run([
                    self.fvm, "flutter", "build", "apk",
                    "--release",
                    "--obfuscate",
                    "--split-debug-info=build/symbols",
                    "--split-per-abi"  # 按架构分包
                ])

                print(f"APK 编译完成，正在移动到指定文件夹 {self.output_folder}")

                # 架构对应输出路径
                arch_map = {
                    "armeabi-v7a": f"{self.output_folder}/harvest_{self.new_version}_arm32.apk",
                    "arm64-v8a": f"{self.output_folder}/harvest_{self.new_version}_arm64.apk",
                    "x86_64": f"{self.output_folder}/harvest_{self.new_version}_x86_64.apk",
                }

                for arch, output_name in arch_map.items():
                    src_path = f"build/app/outputs/flutter-apk/app-{arch}-release.apk"
                    if os.path.exists(src_path):
                        shutil.move(src_path, output_name)
                        print(f"✅ 已生成: {output_name}")
                    else:
                        print(f"⚠️ 未找到 {src_path}")

                print(f"APK 打包完成")
            elif flag == "macos":
                subprocess.run([self.fvm, "flutter", "build", "macos", "--release", "--obfuscate",
                                "--split-debug-info=build/symbols"])
                print(f"macos APP 编译完成，正在移动到指定文件夹 {self.output_folder}")
                app_name = "harvest.app"
                dmg_name = f"harvest_{self.new_version}_{self.machine}-macos.dmg"
                app_path = "build/macos/Build/Products/Release/" + app_name
                dmg_path = os.path.join(self.output_folder, dmg_name)
                #
                with tempfile.NamedTemporaryFile("w", suffix=".py", delete=False) as tmp:
                    settings_file = tmp.name
                    tmp.write(f"""
files = ["{app_path}"]

symlinks = {{
    "Applications": "/Applications"
}}

icon_locations = {{
    "harvest.app": (140, 120),
    "Applications": (500, 120)
}}
""")

                try:
                    dmgbuild.build_dmg(
                        dmg_path,
                        "Harvest",
                        settings_file
                    )
                    print(f"✅ DMG 打包完成: {dmg_path}")
                finally:
                    # 删除临时配置文件
                    # os.remove(settings_file)
                    pass
                # res = subprocess.run(
                #     "zip -r harvest.app.zip harvest.app",
                #     cwd="build/macos/Build/Products/Release/",
                #     shell=True,
                #     stdout=subprocess.PIPE,
                #     stderr=subprocess.PIPE,
                # )
                # print(res.stdout.decode("utf-8"))
                # shutil.move(
                #     "build/macos/Build/Products/Release/harvest.app.zip",
                #     f"{self.output_folder}/harvest_{self.new_version}_{self.machine}-macos.zip",
                # )
                # target_path = os.path.join(self.output_folder, os.path.basename(dmg_path))
                # if os.path.exists(target_path):
                #     os.remove(target_path)  # 删除已有文件
                # shutil.move(
                #     dmg_path,
                #     f"{self.output_folder}/",
                # )
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
            elif flag == "ipa":
                res = subprocess.run(
                    ["rm -rf build/ios/iphoneos/*"],
                    shell=True,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                )
                print(res.stdout.decode("utf-8"))
                res = subprocess.run(
                    f"{self.fvm} flutter build ipa --export-options-plist=ExportOptions.plist",
                    shell=True,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                )
                print(res.stdout.decode("utf-8"))
                print(
                    f"IOS 编译完成，正在移动到指定文件夹 {self.output_folder}/harvest_{self.new_version}_ios.ipa"
                )
                shutil.move(
                    "build/ios/ipa/harvest.ipa",
                    f"{self.output_folder}/harvest_{self.new_version}_ios.ipa",
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
            #                     'ipa',
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

    parser.add_argument(
        "--tasks",
        "-t",
        nargs="*",
        default=None,
        help="任务列表（默认：None）",
    )
    parser.add_argument(
        "--calc",
        "-c",
        action="store_true",
        default=False,
        help="计算版本号（默认：False）",
    )
    args = parser.parse_args()
    manager = VersionManager(args.output_folder, yaml_file_path=args.yaml, tasks=args.tasks,
                             calc=args.calc)
    print(manager.tasks)
    #     manager = VersionManager('~/Desktop/harvest')
    manager.compile_and_install()
    # manager.calc_version()
