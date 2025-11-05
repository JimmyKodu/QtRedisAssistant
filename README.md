# Qt Redis Assistant

[![Build and Release](https://github.com/JimmyKodu/QtRedisAssistant/actions/workflows/build.yml/badge.svg)](https://github.com/JimmyKodu/QtRedisAssistant/actions/workflows/build.yml)

一个基于开源Qt框架开发的桌面Redis GUI管理和监控工具。

A desktop Redis GUI application for visualization, management and monitoring based on open-source Qt framework.

## 功能特性 (Features)

- 🔌 连接到Redis服务器 (Connect to Redis server)
- 💻 执行Redis命令 (Execute Redis commands)
- 📊 可视化界面 (Visual interface)
- 🖥️ 跨平台支持 (Cross-platform support: Windows & Linux)

## 构建状态 (Build Status)

每次提交都会自动构建Windows和Linux两个平台的可执行文件，并存放在版本文件夹中。这确保了每次编译都能成功运行。

Each commit automatically builds executable files for both Windows and Linux platforms, organized in versioned folders. This ensures that every compilation runs successfully.

### 下载 (Downloads)

构建产物会自动上传到GitHub Actions artifacts中：
- Windows版本: `QtRedisAssistant-Windows-v{version}` - **自包含版本，包含所有运行时依赖**
- Linux版本: `QtRedisAssistant-Linux-v{version}`
- 完整版本: `QtRedisAssistant-All-Platforms-v{version}`

Build artifacts are automatically uploaded to GitHub Actions:
- Windows build: `QtRedisAssistant-Windows-v{version}` - **Self-contained with all runtime dependencies**
- Linux build: `QtRedisAssistant-Linux-v{version}`
- Combined build: `QtRedisAssistant-All-Platforms-v{version}`

## 构建说明 (Build Instructions)

### 前置要求 (Prerequisites)

- CMake 3.16+
- Qt 5.15+ 或 Qt 6.x (Qt 5.15+ or Qt 6.x)
- C++17兼容编译器 (C++17 compatible compiler)

### Linux

```bash
mkdir build
cd build
cmake ..
cmake --build . --config Release
```

### Windows

```bash
mkdir build
cd build
cmake .. -G "MinGW Makefiles"
cmake --build . --config Release
```

## 使用说明 (Usage)

1. 启动应用程序 (Launch the application)
2. 输入Redis服务器地址和端口 (Enter Redis server host and port)
3. 点击"Connect"连接 (Click "Connect")
4. 在命令框输入Redis命令并执行 (Enter Redis commands and execute)

## ⚠️ Windows 用户重要提示 (Important Note for Windows Users)

**如果您遇到缺少 DLL 或入口点错误，请阅读 [Windows 用户指南](README_WINDOWS.md)**

**If you encounter missing DLL or entry point errors, please read the [Windows User Guide](README_WINDOWS.md)**

🚫 **绝对不要从其他应用程序（如 Wireshark）复制 Qt DLL！**
🚫 **NEVER copy Qt DLLs from other applications (like Wireshark)!**

这会导致版本不匹配和入口点错误。请使用官方构建版本或按照指南正确构建。

This will cause version mismatch and entry point errors. Use the official build or build correctly following the guide.

## 故障排除 (Troubleshooting)

### Windows DLL 问题 (Windows DLL Issues)

如果您看到以下错误：
- "缺少 Qt6Core.dll" (Missing Qt6Core.dll)
- "无法定位程序输入点" (Unable to locate program entry point)
- "_Z9qBadAllocv" 或其他符号错误 (or other symbol errors)

**解决方案：**
1. 从 GitHub Actions 下载完整的官方构建版本
2. 或阅读 [Windows 用户指南](README_WINDOWS.md) 了解如何正确构建

If you see these errors:
- "Missing Qt6Core.dll"
- "Unable to locate program entry point"
- "_Z9qBadAllocv" or other symbol errors

**Solution:**
1. Download the complete official build from GitHub Actions
2. Or read the [Windows User Guide](README_WINDOWS.md) for correct build instructions

### Linux 依赖问题 (Linux Dependencies)

如果程序无法启动，请确保已安装 Qt6：
```bash
# Ubuntu/Debian
sudo apt-get install qt6-base-dev libqt6network6

# Fedora
sudo dnf install qt6-qtbase qt6-qtbase-gui
```

If the program won't start, make sure Qt6 is installed:
```bash
# Ubuntu/Debian
sudo apt-get install qt6-base-dev libqt6network6

# Fedora
sudo dnf install qt6-qtbase qt6-qtbase-gui
```

## 许可证 (License)

本项目使用开源许可证。(This project uses an open-source license.)

## 版本历史 (Version History)

- v1.0.0 - 初始版本，支持基本的Redis连接和命令执行 (Initial release with basic Redis connection and command execution)