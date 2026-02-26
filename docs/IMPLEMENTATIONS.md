# 多语言实现对比

这个项目展示了如何用不同的编程语言实现相同的功能 - 防止Windows系统进入休眠状态。

## 🎯 功能对比

| 功能 | AutoHotkey | Python | Node.js | C++ |
|------|-----------|--------|---------|-----|
| 调用Windows API | ✅ 原生支持 | ✅ ctypes | ✅ ffi-napi | ✅ 原生支持 |
| GUI界面 | ✅ 完整UI | ❌ 仅命令行 | ❌ 仅命令行 | ❌ 仅命令行 |
| 平台相关性 | 仅Windows | 仅Windows | 仅Windows | 仅Windows |
| 性能 | 中等 | 中等 | 中等 | 最优 |
| 学习难度 | 低 | 低 | 中 | 中 |
| 部署便利性 | 最优 | 需要运行时 | 需要Node.js | 需要编译 |

---

## 📋 语言特性分析

### 1️⃣ AutoHotkey (原始版本)

**优点:**
- 专为Windows自动化设计
- 原生支持GUI创建
- 最接近系统底层
- 代码简洁易读

**缺点:**
- 仅限Windows平台
- 社区较小
- 性能一般

**使用场景:**
- 快速原型开发
- 系统自动化脚本
- 需要完整GUI的应用

---

### 2️⃣ Python

**优点:**
- 代码简洁，易于理解
- 强大的标准库
- 跨平台性好
- 开发速度快

**缺点:**
- 需要Python运行时
- 性能不及C++
- GUI需要额外库

**使用场景:**
- 数据处理和分析
- 系统管理脚本
- 快速开发和测试
- 教学和学习

**依赖:**
```bash
pip install pypiwin32  # 可选，用于更高级的Windows集成
```

**运行:**
```bash
python stay_awake.py
```

---

### 3️⃣ Node.js

**优点:**
- 异步编程模型
- 事件驱动设计
- 可用于全栈开发
- 丰富的NPM生态

**缺点:**
- 需要Node.js运行时
- ffi-napi依赖较重
- 学习曲线较陡

**使用场景:**
- 服务端应用
- 需要异步处理的应用
- 全栈JavaScript开发
- Web应用后端

**依赖:**
```bash
npm install ffi-napi ref-napi
```

**运行:**
```bash
node stay_awake.js
```

---

### 4️⃣ C++

**优点:**
- 极致的性能
- 直接调用Windows API
- 内存占用最小
- 可以编译为单独EXE

**缺点:**
- 学习曲线最陡
- 开发时间长
- 需要编译
- 必须手动管理资源

**使用场景:**
- 性能敏感应用
- 系统级编程
- 需要分发为单独可执行文件
- 大规模企业应用

**编译:**

使用MinGW:
```bash
g++ -o stay_awake.exe stay_awake.cpp -std=c++17 -lkernel32
```

使用MSVC:
```bash
cl stay_awake.cpp
```

**运行:**
```bash
stay_awake.exe
```

---

## 🔑 核心概念 - Windows执行状态

所有版本都基于同一个核心概念：调用Windows的`SetThreadExecutionState` API

### 执行状态标志:

```
AWAYMODE_REQUIRED   = 0x00000040  # 离开模式必需
CONTINUOUS          = 0x80000000  # 持续执行状态（重置空闲计时器）
DISPLAY_REQUIRED    = 0x00000002  # 显示必需（屏幕保持开启）
SYSTEM_REQUIRED     = 0x00000001  # 系统必需（系统保持唤醒）
```

### 三种模式:

1. **被动模式** (Passive Mode)
   - Period: -1
   - 不保持系统唤醒，正常操作

2. **无限保持模式** (Indefinite Mode)
   - Period: 0
   - 持续保持系统唤醒，直到用户禁用

3. **临时保持模式** (Temporary Mode)
   - Period: > 0 (毫秒)
   - 在指定时间内保持系统唤醒

---

## 📊 性能对比

| 指标 | AutoHotkey | Python | Node.js | C++ |
|------|-----------|--------|---------|-----|
| 启动时间 | 200ms | 300-500ms | 500-800ms | <50ms |
| 内存占用 | 10-15MB | 30-50MB | 40-60MB | 2-5MB |
| CPU使用率 | 低 | 低-中 | 低 | 极低 |
| 可执行文件大小 | ~1.5MB | N/A | ~50MB | 0.5-2MB |

---

## 🚀 快速开始

### AutoHotkey (原始)
```bash
# 直接运行
stay_awake.ahk

# 或编译为EXE
Ahk2Exe.exe /in stay_awake.ahk /out stay_awake.exe
```

### Python
```bash
# 安装依赖
pip install -r requirements.txt

# 运行
python stay_awake.py
```

### Node.js
```bash
# 安装依赖
npm install

# 运行
node stay_awake.js
```

### C++
```bash
# 编译
g++ -o stay_awake.exe stay_awake.cpp -std=c++17

# 运行
./stay_awake.exe
```

---

## 💡 选择指南

| 需求 | 推荐语言 | 理由 |
|------|--------|------|
| 快速原型 | AutoHotkey | 最快的开发速度 |
| 最佳用户体验 | AutoHotkey | 内置GUI支持 |
| 易于维护 | Python | 代码清晰易懂 |
| 最小部署包 | C++ | 单个小文件 |
| 最佳性能 | C++ | 最低资源占用 |
| 已有Node.js | Node.js | 生态完善 |

---

## 📝 开发者笔记

### 关键API调用

所有版本都会调用:
```cpp
SetThreadExecutionState(EXECUTION_STATE state)
```

这个API内部会:
1. 重置系统空闲计时器
2. 防止系统进入睡眠/休眠模式
3. 根据标志选择是否保持屏幕开启

### 周期性更新

为了确保保持唤醒状态，需要定期调用此API（建议每60秒）：
- AutoHotkey: `SetTimer`
- Python: `threading.Thread` + `time.sleep()`
- Node.js: `setInterval()`
- C++: `thread` + `chrono::sleep_for()`

### 资源管理

- AutoHotkey: 自动管理，退出时释放
- Python: 手动关闭线程
- Node.js: 使用`clearInterval()`清理计时器
- C++: 使用`detach()`分离线程

---

## 🐛 故障排除

### Windows权限问题
如果应用无法修改系统状态，可能需要以管理员身份运行。

### API调用失败
检查：
- Windows版本（需要Windows XP SP3+）
- 用户权限等级
- 是否在虚拟机中运行

### 线程安全
所有版本都使用了原子变量或线程安全的方式处理状态标志。

---

## 📚 参考资源

- [Windows SetThreadExecutionState API文档](https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-setthreadexecutionstate)
- [AutoHotkey官方文档](https://www.autohotkey.com/)
- [Python ctypes](https://docs.python.org/3/library/ctypes.html)
- [Node.js ffi-napi](https://github.com/node-ffi/node-ffi)
- [C++ Windows编程](https://docs.microsoft.com/en-us/windows/win32/)

---

## 📄 许可证

MIT License - 自由使用、修改和分发

---

## 🤝 贡献

欢迎提交PR改进任何一个版本！
