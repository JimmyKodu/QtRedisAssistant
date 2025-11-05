# Qt Redis Assistant - Build and Release System

## 概述 (Overview)

本项目实现了自动化的CI/CD系统，每次提交都会自动构建Windows和Linux两个平台的可执行文件，并按版本组织在文件夹中。

This project implements an automated CI/CD system that builds executable files for both Windows and Linux platforms with each commit, organized in versioned folders.

## 构建流程 (Build Process)

### 触发条件 (Triggers)

GitHub Actions工作流在以下情况下自动触发：
- Push到以下分支: `main`, `master`, `develop`, `copilot/**`
- Pull Request到: `main`, `master`, `develop`

The GitHub Actions workflow automatically triggers when:
- Pushing to branches: `main`, `master`, `develop`, `copilot/**`
- Creating Pull Requests to: `main`, `master`, `develop`

### 构建任务 (Build Jobs)

工作流包含三个主要任务：

1. **build-linux** - Linux平台构建
   - 运行环境: Ubuntu 22.04
   - Qt版本: 6.5.3
   - 编译器: GCC 64-bit
   - 产物: Linux可执行文件

2. **build-windows** - Windows平台构建
   - 运行环境: Windows Server 2022
   - Qt版本: 6.5.3
   - 编译器: MinGW
   - 产物: Windows可执行文件 (.exe) 及所有依赖DLL
   - 自包含发布: 包含所有Qt运行库和MinGW运行时库

3. **create-release-structure** - 发布结构创建
   - 合并两个平台的构建产物
   - 创建版本化的文件夹结构
   - 生成构建信息文件

The workflow contains three main jobs:

1. **build-linux** - Linux platform build
   - Environment: Ubuntu 22.04
   - Qt Version: 6.5.3
   - Compiler: GCC 64-bit
   - Artifacts: Linux executable

2. **build-windows** - Windows platform build
   - Environment: Windows Server 2022
   - Qt Version: 6.5.3
   - Compiler: MinGW
   - Artifacts: Windows executable (.exe) with all dependencies
   - Self-contained release: Includes all Qt runtime and MinGW runtime libraries

3. **create-release-structure** - Release structure creation
   - Combines artifacts from both platforms
   - Creates versioned folder structure
   - Generates build information file

## 文件夹结构 (Folder Structure)

构建产物按以下结构组织：

```
releases/
└── v{version}/
    ├── linux/
    │   ├── QtRedisAssistant       # Linux可执行文件
    │   ├── run.sh                 # 运行脚本
    │   └── README.txt             # 说明文件
    ├── windows/
    │   ├── QtRedisAssistant.exe   # Windows可执行文件
    │   ├── Qt6Core.dll            # Qt核心库
    │   ├── Qt6Gui.dll             # Qt GUI库
    │   ├── Qt6Widgets.dll         # Qt Widgets库
    │   ├── Qt6Network.dll         # Qt网络库
    │   ├── libgcc_s_seh-1.dll     # MinGW运行时库
    │   ├── libstdc++-6.dll        # C++标准库
    │   ├── libwinpthread-1.dll    # pthread库
    │   ├── platforms/             # Qt平台插件
    │   │   └── qwindows.dll       # Windows平台插件
    │   └── README.txt             # 说明文件
    └── BUILD_INFO.txt             # 构建信息
```

## 自包含发布 (Self-Contained Release)

### Windows版本 (Windows Build)

Windows版本采用自包含发布方式，**无需在目标系统安装Qt或MinGW环境**。所有必需的依赖都已包含在发布包中：

- **Qt运行时库**: Qt6Core.dll, Qt6Gui.dll, Qt6Widgets.dll, Qt6Network.dll
- **MinGW运行时库**: libgcc_s_seh-1.dll, libstdc++-6.dll, libwinpthread-1.dll
- **Qt平台插件**: platforms/qwindows.dll

只需解压发布包，直接运行QtRedisAssistant.exe即可使用。

The Windows build uses a self-contained release approach, **no Qt or MinGW installation required on target system**. All necessary dependencies are included in the release package:

- **Qt Runtime Libraries**: Qt6Core.dll, Qt6Gui.dll, Qt6Widgets.dll, Qt6Network.dll
- **MinGW Runtime Libraries**: libgcc_s_seh-1.dll, libstdc++-6.dll, libwinpthread-1.dll
- **Qt Platform Plugins**: platforms/qwindows.dll

Simply extract the release package and run QtRedisAssistant.exe directly.

### Linux版本 (Linux Build)

Linux版本需要在目标系统安装Qt6运行时库。可以通过系统包管理器安装：

```bash
# Ubuntu/Debian
sudo apt-get install qt6-base-dev

# Fedora
sudo dnf install qt6-qtbase-devel
```

The Linux build requires Qt6 runtime libraries to be installed on the target system. Install via system package manager:

```bash
# Ubuntu/Debian
sudo apt-get install qt6-base-dev

# Fedora
sudo dnf install qt6-qtbase-devel
```

## 下载构建产物 (Download Build Artifacts)

构建产物可以从GitHub Actions页面下载：

1. 访问仓库的"Actions"标签页
2. 点击最近的"Build and Release"工作流运行
3. 在底部的"Artifacts"部分下载：
   - `QtRedisAssistant-Linux-v{version}` - Linux版本
   - `QtRedisAssistant-Windows-v{version}` - Windows版本
   - `QtRedisAssistant-All-Platforms-v{version}` - 完整版本

Build artifacts can be downloaded from the GitHub Actions page:

1. Go to the "Actions" tab in the repository
2. Click on the latest "Build and Release" workflow run
3. Download from the "Artifacts" section at the bottom:
   - `QtRedisAssistant-Linux-v{version}` - Linux build
   - `QtRedisAssistant-Windows-v{version}` - Windows build
   - `QtRedisAssistant-All-Platforms-v{version}` - Combined build

## 版本管理 (Version Management)

版本号在`CMakeLists.txt`文件中定义：

```cmake
project(QtRedisAssistant VERSION 1.0.0 LANGUAGES CXX)
```

要更新版本号，修改这一行并提交更改。构建系统会自动使用新版本号。

The version number is defined in the `CMakeLists.txt` file:

```cmake
project(QtRedisAssistant VERSION 1.0.0 LANGUAGES CXX)
```

To update the version, modify this line and commit the change. The build system will automatically use the new version number.

## 验证构建成功 (Verify Build Success)

每次构建成功后，会生成以下证明：

1. **GitHub Actions徽章** - 在README中显示构建状态
2. **构建产物** - 可下载的可执行文件证明编译成功
3. **BUILD_INFO.txt** - 包含构建日期、Git提交信息等
4. **README.txt** - 每个平台的说明文件

After each successful build, the following proof is generated:

1. **GitHub Actions Badge** - Shows build status in README
2. **Build Artifacts** - Downloadable executables prove successful compilation
3. **BUILD_INFO.txt** - Contains build date, Git commit info, etc.
4. **README.txt** - Instructions for each platform

## 本地构建 (Local Build)

如需在本地构建，请参考README.md中的构建说明。

For local building, please refer to the build instructions in README.md.

## 故障排除 (Troubleshooting)

### 构建失败 (Build Failures)

如果构建失败：
1. 检查GitHub Actions日志查看错误详情
2. 确保CMakeLists.txt语法正确
3. 确保所有源文件已提交
4. 检查Qt相关代码是否符合跨平台要求

If builds fail:
1. Check GitHub Actions logs for error details
2. Ensure CMakeLists.txt syntax is correct
3. Ensure all source files are committed
4. Check that Qt code follows cross-platform requirements

### 产物不可用 (Artifacts Unavailable)

产物保留90天。如需长期保存，请手动下载或创建GitHub Release。

Artifacts are retained for 90 days. For long-term storage, download manually or create a GitHub Release.
