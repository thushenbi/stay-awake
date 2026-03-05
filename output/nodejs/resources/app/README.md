# Stay Awake - Node.js 版本

## ✨ 特点

- 🚀 基于Node.js的异步设计
- 📦 使用 `ffi-napi` 调用 Windows API
- 🎯 支持三种模式：被动、无限、临时
- 🎪 事件驱动架构
- 🔄 周期性更新唤醒状态

## 📋 系统需求

- **操作系统**: Windows XP SP3 或更高版本
- **Node.js**: 12.0.0 或更高版本
- **npm**: 6.0.0 或更高版本
- **权限**: 建议以管理员身份运行

## 🚀 快速开始

### 1. 安装Node.js
访问 [nodejs.org](https://nodejs.org) 下载安装

### 2. 安装依赖
```bash
npm install
```

**注意**: 首次安装需要编译native模块，可能需要Visual C++ Build Tools

### 3. 运行应用
```bash
npm start
```

或直接运行：
```bash
node stay_awake.js
```

## 📖 使用说明

应用启动后会显示菜单：

```
==================================================
         🌙 Stay Awake - Node.js 版本
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
- **选项 3**: 是否保持屏幕开启
- **选项 4**: 退出应用

## 🏗️ 代码结构

### `EXECUTION_STATE` - 常量对象
定义Windows执行状态常量：
```javascript
{
    AWAYMODE_REQUIRED: 0x00000040,
    CONTINUOUS: 0x80000000,
    DISPLAY_REQUIRED: 0x00000002,
    SYSTEM_REQUIRED: 0x00000001
}
```

### `StayAwake` - 核心类
继承自 `EventEmitter`，主要方法：
- `setState(state)`: 调用Windows API设置执行状态
- `runLoop()`: 周期性运行循环
- `start()`: 启动唤醒
- `stop()`: 停止唤醒

事件：
- `started`: 唤醒开始时触发
- `stopped`: 唤醒停止时触发

### `StayAwakeApp` - 应用类
处理用户交互和菜单显示

## 🔑 关键技术

### FFI 调用Windows API
```javascript
const ffi = require('ffi-napi');

const kernel32 = ffi.Library('kernel32', {
    SetThreadExecutionState: ['uint', ['uint']]
});

const result = kernel32.SetThreadExecutionState(state);
```

### 异步操作
```javascript
prompt(question) {
    return new Promise(resolve => {
        this.rl.question(question, answer => {
            resolve(answer.trim());
        });
    });
}
```

### 事件发布
```javascript
awake.on('started', () => {
    console.log('起始事件');
});
```

## 💡 使用场景

- 🌐 Web服务器需要持续运行
- 📹 后端视频处理服务
- 🎮 游戏服务器
- ⏬ 文件服务器
- 🔄 自动化任务
- 📊 数据爬取和处理

## 🐛 故障排除

### 问题："npm ERR! code EBUILD"
**解决**: 需要安装Visual C++ Build Tools
1. 访问 [visualstudio.com](https://visualstudio.microsoft.com/downloads/)
2. 安装"Desktop development with C++"
3. 重新运行 `npm install`

### 问题："Cannot find module 'ffi-napi'"
**解决**: 确保已运行 `npm install`

### 问题：权限错误
**解决**: 以管理员身份打开Command Prompt/PowerShell，然后运行应用

### 问题：应用无反应
**解决**: 按 `Ctrl+C` 强制退出，然后重启

## 📊 性能

- **启动时间**: 500-800ms
- **内存占用**: 40-60MB
- **CPU使用**: 低（空闲时 <1%）
- **事件驱动**: 高效的事件处理

## 🔄 更新循环

应用每60秒调用一次 `SetThreadExecutionState`，通过 `setInterval()` 实现异步定时：

```javascript
this.timerInterval = setInterval(() => this.runLoop(), 60000);
```

## 🎯 异步设计优势

1. **非阻塞I/O**: 用户输入不会阻塞倒计时
2. **事件驱动**: 响应式设计
3. **易于扩展**: 可添加Websocket、HTTP服务等

## 🛠️ 依赖说明

- `ffi-napi`: 外部函数接口，用于调用DLL
- `ref-napi`: 提供类型系统支持FFI

这两个包都是当前最活跃维护的FFI解决方案。

## 📝 扩展和修改

容易扩展为Web应用：

```javascript
// 添加HTTP服务器
const http = require('http');

http.createServer((req, res) => {
    if (req.url === '/status') {
        res.end(JSON.stringify({ running: app.awake.running }));
    }
}).listen(3000);
```

## 📚 相关资源

- [ffi-napi文档](https://github.com/node-ffi/node-ffi)
- [Node.js模块系统](https://nodejs.org/api/modules.html)
- [Windows API SetThreadExecutionState](https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-setthreadexecutionstate)

## 📄 许可证

MIT License

## 🤝 贡献

欢迎提交问题报告和改进建议！

---

**提示**: 
- 需要GUI版本？请查看原始的 [AutoHotkey 版本](../src/StayAwake.ahk)
- 需要单个可执行文件？请参考 [C++ 版本](../cpp_version/)
