# Qt Redis Assistant - Windows 用户指南 (Windows User Guide)

## 重要警告 ⚠️ IMPORTANT WARNING

### 🚫 **绝对不要从其他应用程序复制 Qt DLL！**
### 🚫 **NEVER copy Qt DLLs from other applications!**

如果您遇到缺少 DLL 的错误（例如缺少 Qt6Core.dll），**请勿**从其他应用程序（如 Wireshark、Notepad++、或其他 Qt 应用）复制 DLL 文件到 QtRedisAssistant 目录！

If you encounter missing DLL errors (e.g., missing Qt6Core.dll), **DO NOT** copy DLL files from other applications (such as Wireshark, Notepad++, or other Qt applications) into the QtRedisAssistant directory!

### 为什么？ Why?

不同的应用程序可能使用：
- 不同版本的 Qt（例如 Qt 5.x vs Qt 6.x）
- 不同的编译器（例如 MSVC vs MinGW）
- 不同的编译器版本（例如 MinGW 8.1 vs MinGW 9.0）

Different applications may use:
- Different Qt versions (e.g., Qt 5.x vs Qt 6.x)
- Different compilers (e.g., MSVC vs MinGW)
- Different compiler versions (e.g., MinGW 8.1 vs MinGW 9.0)

混合使用不兼容的 DLL 会导致：
- `无法定位程序输入点 _Z9qBadAllocv` 等符号错误
- 应用程序崩溃
- 随机的、难以调试的错误

Mixing incompatible DLLs will cause:
- Symbol errors like `Unable to locate program entry point _Z9qBadAllocv`
- Application crashes
- Random, hard-to-debug errors

## 正确的解决方案 Correct Solutions

### 方案 1：使用官方构建版本 Solution 1: Use Official Builds

从 GitHub Actions 下载完整的预构建版本：

Download the complete pre-built release from GitHub Actions:

1. 访问仓库的 "Actions" 页面
   Go to the "Actions" tab in the repository
   
2. 点击最新的 "Build and Release" 工作流
   Click on the latest "Build and Release" workflow
   
3. 下载 `QtRedisAssistant-Windows-v{version}` 产物
   Download the `QtRedisAssistant-Windows-v{version}` artifact
   
4. 解压并直接运行 QtRedisAssistant.exe
   Extract and run QtRedisAssistant.exe directly

**所有必需的 DLL 都已包含在内！**
**All required DLLs are already included!**

### 方案 2：本地构建 Solution 2: Build Locally

如果您想从源代码构建，请按照以下步骤操作：

If you want to build from source, follow these steps:

#### 安装依赖 Install Dependencies

1. **安装 Qt 6.5.3 或更高版本**
   **Install Qt 6.5.3 or higher**
   
   下载地址：https://www.qt.io/download
   Download from: https://www.qt.io/download
   
   - 选择 "Qt Online Installer"
     Choose "Qt Online Installer"
   - 安装时选择 "MinGW 9.0 64-bit" 组件（或更新版本的 MinGW，取决于您的 Qt 版本）
     During installation, select "MinGW 9.0 64-bit" component (or a newer MinGW version that comes with your Qt version)
   - 确保选择 Qt 6.5.x 版本
     Make sure to select Qt 6.5.x version
   
   **注意：** MinGW 版本应与您的 Qt 安装捆绑的版本匹配。如果使用更新的 Qt 版本，请选择相应的 MinGW 工具链。
   **Note:** The MinGW version should match the one bundled with your Qt installation. If using a newer Qt version, select the corresponding MinGW toolchain.

2. **安装 CMake 3.16 或更高版本**
   **Install CMake 3.16 or higher**
   
   下载地址：https://cmake.org/download/
   Download from: https://cmake.org/download/

#### 构建步骤 Build Steps

```bash
# 克隆仓库
# Clone the repository
git clone https://github.com/JimmyKodu/QtRedisAssistant.git
cd QtRedisAssistant

# 创建构建目录
# Create build directory
mkdir build
cd build

# 配置项目（确保 Qt 的 bin 目录在 PATH 中）
# Configure project (make sure Qt's bin directory is in PATH)
cmake .. -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release

# 构建
# Build
cmake --build . --config Release

# 部署（复制所有必需的 DLL）
# Deploy (copy all required DLLs)
cd ..
mkdir release
bash deploy_windows.sh build/QtRedisAssistant.exe release

# 现在 release 目录包含可运行的应用程序和所有 DLL
# Now the release directory contains the runnable application with all DLLs
```

## 常见问题 Common Issues

### Q: 我看到 "缺少 Qt6Core.dll" 错误
### Q: I see "Qt6Core.dll is missing" error

**A:** 请使用上述方案 1（下载官方构建）或方案 2（正确构建）。不要从其他应用程序复制 DLL！

**A:** Use Solution 1 (download official build) or Solution 2 (build correctly) above. Do not copy DLLs from other applications!

### Q: 我已经从 Wireshark 复制了 DLL，现在看到入口点错误
### Q: I already copied DLLs from Wireshark and now I see entry point errors

**A:** 删除所有从 Wireshark 复制的 DLL，然后：
1. 删除 QtRedisAssistant 目录中的所有 .dll 文件
2. 删除 platforms 文件夹
3. 重新下载官方构建版本，或使用正确的 Qt 版本重新构建

**A:** Remove all DLLs copied from Wireshark, then:
1. Delete all .dll files in the QtRedisAssistant directory
2. Delete the platforms folder
3. Re-download the official build, or rebuild with the correct Qt version

### Q: 为什么应用程序需要这么多 DLL？
### Q: Why does the application need so many DLLs?

**A:** 这些 DLL 提供 Qt 框架功能：
- Qt6Core.dll - 核心功能（Core functionality）
- Qt6Gui.dll - GUI 支持（GUI support）
- Qt6Widgets.dll - 窗口小部件（Widgets）
- Qt6Network.dll - 网络功能（Network functionality）
- libgcc_s_seh-1.dll, libstdc++-6.dll, libwinpthread-1.dll - MinGW 运行时（MinGW runtime）
- platforms/qwindows.dll - Windows 平台插件（Windows platform plugin）

所有这些都必须来自同一个 Qt 安装和编译器！
All of these MUST come from the same Qt installation and compiler!

## 文件清单 File Checklist

一个正确部署的 QtRedisAssistant 目录应包含：

A correctly deployed QtRedisAssistant directory should contain:

```
QtRedisAssistant/
├── QtRedisAssistant.exe     # 主程序 (Main executable)
├── qt.conf                   # Qt 配置文件 (Qt configuration)
├── Qt6Core.dll              # Qt 核心库 (Qt Core)
├── Qt6Gui.dll               # Qt GUI 库 (Qt GUI)
├── Qt6Widgets.dll           # Qt Widgets 库 (Qt Widgets)
├── Qt6Network.dll           # Qt 网络库 (Qt Network)
├── libgcc_s_seh-1.dll       # MinGW 运行时 (MinGW runtime)
├── libstdc++-6.dll          # C++ 标准库 (C++ standard library)
├── libwinpthread-1.dll      # pthread 库 (pthread library)
└── platforms/
    └── qwindows.dll         # Windows 平台插件 (Windows platform plugin)
```

## 获取帮助 Getting Help

如果您在使用官方构建或正确构建后仍然遇到问题，请在 GitHub 上开启一个 issue，并提供：

If you still have issues after using the official build or building correctly, please open an issue on GitHub and provide:

1. 您使用的版本（Version you're using）
2. 错误的完整消息（Complete error message）
3. 您的操作系统版本（Your Windows version）
4. 您是使用官方构建还是自己构建的（Whether you're using official build or built yourself）

**重要提示：如果您从其他应用程序复制了 DLL，请在报告问题之前先清理并重新安装！**

**Important: If you copied DLLs from other applications, please clean and reinstall before reporting an issue!**
