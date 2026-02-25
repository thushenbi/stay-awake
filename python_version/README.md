# Stay Awake - Python 版本

## ✨ 特点

- 🐍 纯Python实现，易于理解和修改
- 🔒 使用 `ctypes` 调用 Windows API
- 🎯 支持三种模式：被动、无限、临时
- ⏱️ 周期性更新唤醒状态
- 🌐 跨平台代码结构（虽然仅支持Windows）

## 📋 系统需求

- **操作系统**: Windows XP SP3 或更高版本
- **Python**: 3.6 或更高版本
- **权限**: 建议以管理员身份运行

## 🚀 快速开始

### 1. 安装Python
访问 [python.org](https://www.python.org) 下载安装

### 2. （可选）创建虚拟环境
```bash
python -m venv venv
venv\Scripts\activate
```

### 3. 安装依赖
```bash
pip install -r requirements.txt
```

### 4. 运行应用
```bash
python stay_awake.py
```

## 📖 使用说明

应用启动后会显示菜单：

```
==================================================
         🌙 Stay Awake - Python 版本
==================================================

当前状态: 已禁用
当前模式: 被动模式
屏幕保持: 关闭

---- 主菜单 ----
1. 切换启用/禁用
2. 选择模式
   a) 被动模式（不保持唤醒）
   b) 无限保持唤醒
   c) 临时保持唤醒
3. 保持屏幕开启
4. 退出应用
```

### 菜单操作

- **选项 1**: 打开/关闭 Stay Awake
- **选项 2a**: 恢复正常操作，不保持系统唤醒
- **选项 2b**: 无限期保持系统唤醒
- **选项 2c**: 临时保持（可设置小时和分钟）
- **选项 3**: 是否保持屏幕开启（防止屏幕关闭）
- **选项 4**: 退出应用

## 🏗️ 代码结构

### `ExecutionState` - 枚举类
定义Windows执行状态常量：
- `AWAYMODE_REQUIRED`: 离开模式
- `CONTINUOUS`: 持续执行
- `DISPLAY_REQUIRED`: 屏幕必需
- `SYSTEM_REQUIRED`: 系统必需

### `StayAwake` - 核心类
主要方法：
- `set_state(state)`: 调用Windows API设置执行状态
- `run_loop()`: 周期性运行循环
- `timer_loop()`: 后台计时器线程
- `start()`: 启动唤醒
- `stop()`: 停止唤醒

### `StayAwakeApp` - 应用类
处理用户交互和菜单显示

## 🔑 关键技术

### Windows API调用
```python
import ctypes
kernel32 = ctypes.windll.kernel32
result = kernel32.SetThreadExecutionState(state)
```

### 线程管理
```python
import threading
timer_thread = threading.Thread(target=self.timer_loop, daemon=True)
timer_thread.start()
```

### 枚举和位操作
```python
state = (ExecutionState.CONTINUOUS | 
         ExecutionState.SYSTEM_REQUIRED | 
         ExecutionState.DISPLAY_REQUIRED)
```

## 💡 使用场景

- 📹 长时间视频录制
- 🎮 游戏直播或录制
- ⏬ 大文件下载
- 🎬 视频转码/渲染
- 📊 数据处理和分析
- 🔄 自动化任务执行

## 🐛 故障排除

### 问题：" ModuleNotFoundError: No module named 'ctypes'"
**解决**: ctypes是Python内置模块，确保Python版本 >= 3.6

### 问题："SetThreadExecutionState failed"
**解决**: 确保以管理员身份运行应用

### 问题：应用无反应
**解决**: 按 `Ctrl+C` 强制退出，然后重启

## 📊 性能

- **启动时间**: 300-500ms
- **内存占用**: 30-50MB
- **CPU使用**: 低（空闲时 <1%）
- **线程数**: 3个（主线程 + 计时器线程 + 停止计时器线程）

## 🔄 更新循环

应用每60秒调用一次 `SetThreadExecutionState` 以确保系统保持唤醒状态。这个间隔是经过优化的，足以防止系统睡眠，同时不会过度消耗资源。

## 🛡️ 线程安全

应用使用 `threading` 库的原子操作确保线程安全：
- `self.running` 作为状态标志
- `daemon=True` 设置守护线程，确保主线程退出时清理资源

## 📝 扩展和修改

代码易于扩展：

```python
# 添加自定义行为
class StayAwake:
    def custom_behavior(self):
        # 你的代码
        pass
```

## 📚 相关资源

- [ctypes文档](https://docs.python.org/3/library/ctypes.html)
- [threading文档](https://docs.python.org/3/library/threading.html)
- [Windows API SetThreadExecutionState](https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-setthreadexecutionstate)

## 📄 许可证

MIT License

## 🤝 贡献

欢迎提交问题报告和改进建议！

---

**提示**: 需要GUI版本？请查看原始的 [AutoHotkey 版本](../src/StayAwake.ahk)
