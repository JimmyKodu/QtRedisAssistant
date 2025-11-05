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
- Windows版本: `QtRedisAssistant-Windows-v{version}`
- Linux版本: `QtRedisAssistant-Linux-v{version}`
- 完整版本: `QtRedisAssistant-All-Platforms-v{version}`

Build artifacts are automatically uploaded to GitHub Actions:
- Windows build: `QtRedisAssistant-Windows-v{version}`
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

## 许可证 (License)

本项目使用开源许可证。(This project uses an open-source license.)

## 版本历史 (Version History)

- v1.0.0 - 初始版本，支持基本的Redis连接和命令执行 (Initial release with basic Redis connection and command execution)