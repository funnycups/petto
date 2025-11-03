# v3.0.0更新日志(相对v2.1.0)

本文档记录了从v2.1.0到v3.0.0的主要变更，方便用户了解新功能和迁移注意事项。

*Scroll down to view English version*

## 核心更新

### 新默认模式：Kage
* 添加了全新的Kage模式作为默认桌宠渲染方案
* 基于WebSocket的统一接口，支持：
  * 动作触发
  * 表情管理
  * 文本气泡显示
  * 模型路径设置
  * 位置尺寸控制
* 自动检测Kage可用性，首次启动时弹窗询问下载
* 设置对话框增加动作获取按钮，可自动填充动作分组列表

### 兼容性保障
* 保留Live2DViewerEX ExAPI支持作为兼容模式
* 旧用户可继续使用原有配置

### 代码重构
* 全面重构代码库，重新组织目录结构
* 分离服务层次，提升代码可维护性
* 改进附属进程退出处理机制

### 跨平台改进
* 使用[xcap](https://github.com/nashaofu/xcap)进行跨平台截图
* 添加Linux平台支持
* 迁移xcap_ffi到Native Assets

### 新增功能
* 快捷键唤醒功能
* 自动更新检查
* 文字显示时长可配置
* 日志开关选项

### 脚本和配置变更
* **重要**：v3重构后不再自动执行旧PowerShell启动脚本(startmodel.ps1, startserver.ps1)
* 如需使用本地LLM/ASR服务，请手动运行服务后在设置中填写接口地址
* **废弃**：移除"窗口标题"作为上下文的配置选项，现统一使用窗口截图功能

## 修复与维护
* 修正动作拉取逻辑
* 移除过时的窗口名称代码路径
* CI构建流程优化
* License头统一格式

## 迁移指南

### 从Live2DViewerEX模式迁移到Kage
1. 在设置中将桌宠模式从"Live2DViewerEX"切换为"Kage"
2. 如果系统提示下载Kage，选择同意下载或手动指定已安装的Kage可执行文件
3. 设置模型配置路径(JSON文件)
4. 点击动作分组旁的刷新按钮自动获取动作列表
5. 其他设置(LLM、语音、TTS等)保持不变

### 继续使用Live2DViewerEX兼容模式
如果暂时不想切换，可以：
1. 在设置中保持桌宠模式为"Live2DViewerEX"
2. 继续使用原有的ExAPI地址和模型序号配置
3. **注意**：如果之前使用了本地脚本启动服务，需要手动运行这些脚本
4. **注意**：旧版本的"窗口标题"配置已废弃，需改用截图功能获取上下文

---

# v3.0.0 Changelog (since v2.1.0)

This document records the major changes from v2.1.0 to v3.0.0, helping users understand new features and migration considerations.

## Core Updates

### New Default Mode: Kage
* Added brand new Kage mode as the default desktop pet rendering solution
* WebSocket-based unified interface supporting:
  * Motion triggering
  * Expression management
  * Text bubble display
  * Model path configuration
  * Position and size control
* Auto-detection of Kage availability with download prompt on first launch
* Added motion fetch button in settings dialog for auto-populating action groups

### Compatibility Assurance
* Retained Live2DViewerEX ExAPI support as compatibility mode
* Existing users can continue using original configurations

### Code Refactoring
* Complete codebase refactoring with reorganized directory structure
* Separated service layers for improved code maintainability
* Enhanced subprocess exit handling mechanism

### Cross-platform Improvements
* Using [xcap](https://github.com/nashaofu/xcap) for cross-platform screenshots
* Added Linux platform support
* Migrated xcap_ffi to Native Assets

### New Features
* Hotkey wake functionality
* Automatic update checking
* Configurable text display duration
* Logging toggle option

### Script and Configuration Changes
* **Important**: v3 refactoring no longer auto-executes old PowerShell startup scripts (startmodel.ps1, startserver.ps1)
* For local LLM/ASR services, manually run services and configure interface addresses in settings
* **Deprecated**: Removed "window title" context configuration option, now unified to use window screenshot functionality

## Fixes & Maintenance
* Fixed motion fetching logic
* Removed outdated window name code paths
* Optimized CI build workflows
* Unified License header format

## Migration Guide

### Migrating from Live2DViewerEX Mode to Kage
1. Switch desktop pet mode from "Live2DViewerEX" to "Kage" in settings
2. If prompted to download Kage, agree to download or manually specify installed Kage executable
3. Set model configuration path (JSON file)
4. Click refresh button next to action groups to auto-fetch action list
5. Other settings (LLM, voice, TTS, etc.) remain unchanged

### Continuing with Live2DViewerEX Compatibility Mode
If you prefer not to switch yet:
1. Keep desktop pet mode as "Live2DViewerEX" in settings
2. Continue using existing ExAPI address and model number configuration
3. **Note**: If previously used local startup scripts, manually run these services
4. **Note**: Old "window title" configuration has been deprecated, switch to screenshot functionality for context

---

If you have migration issues or missing features, please provide feedback in [Issues](https://github.com/funnycups/petto/issues).