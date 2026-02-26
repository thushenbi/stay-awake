# 🚀 快速启动指南

> **最快上手只需 3 步：1️⃣ 下载项目 →  2️⃣ 运行 startup.bat → 3️⃣ 选择版本启动**

---

## 💻 系统需求

- **操作系统**: Windows 7+ / Linux / macOS
- **无需安装任何依赖**开始使用基础版本
- **可选**: Python、Node.js、C++ 编译器用于特定版本

---

## 🎯 30秒快速开始

### Windows 用户 (推荐)

```bash
# 1. 双击运行
startup.bat

# 2. 选择版本 (输入 1-4)
# 3. 应用启动！
```

### PowerShell 用户

```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
.\startup.ps1
```

### Linux/Mac 用户

```bash
chmod +x startup.sh
./startup.sh
```

---

## 📦 项目结构

```
stay-awake/
├── src/                          # AutoHotkey 原始版本 (GUI)
│   ├── StayAwake.ahk
│   └── StayAwake_Dark.ahk
│
├── python_version/               # Python 版本 (命令行)
│   ├── stay_awake.py
│   ├── requirements.txt
│   └── README.md
│
├── nodejs_version/               # Node.js 版本 (命令行)
│   ├── stay_awake.js
│   ├── package.json
│   └── README.md
│
├── cpp_version/                  # C++ 版本 (最快)
│   ├── stay_awake.cpp
│   └── README.md
│
├── startup.bat                   # ⭐ Windows 启动脚本
├── startup.ps1                   # PowerShell 启动脚本
├── startup.sh                    # Linux/Mac 启动脚本
├── setup.bat                     # 环境配置脚本
├── QUICKSTART.md                 # 详细启动指南（包含EXE打包教程）
├── IMPLEMENTATIONS.md            # 各语言实现对比
└── QUICK_COMPARISON.md           # 快速选择指南
```

---

## 🚀 3 种启动方式

### 方式 1: 脚本启动 (推荐)

**Windows:**
```bash
startup.bat
```

**PowerShell:**
```powershell
.\startup.ps1
```

**Linux/Mac:**
```bash
./startup.sh
```

---

### 方式 2: 直接运行

#### AutoHotkey 版（需要 AutoHotkey 2.0+）
```bash
src/StayAwake.ahk
```

#### Python 版（需要 Python 3.6+）
```bash
python python_version/stay_awake.py
```

#### Node.js 版（需要 Node.js 12+）
```bash
cd nodejs_version
npm install  # 首次运行
node stay_awake.js
```

#### C++ 版（需要 g++ 或 MSVC）
```bash
cd cpp_version
g++ -o stay_awake.exe stay_awake.cpp -std=c++17 -lkernel32
stay_awake.exe
```

---

### 方式 3: 环境配置

```bash
setup.bat
```

此脚本将：
- ✓ 检查已安装的工具
- ✓ 安装 Python 依赖 (PyInstaller)
- ✓ 安装 Node.js 依赖 (pkg)
- ✓ 验证 C++ 编译器

---

## 🎓 版本选择指南

| 版本 | 速度 | 体积 | 学习 | 部署 |
|------|------|------|------|------|
| **AutoHotkey** | 中等 | 1.5MB | ⭐⭐⭐⭐ | 最简单 |
| **Python** | 中等 | N/A | ⭐⭐⭐⭐⭐ | 需运行时 |
| **Node.js** | 中等 | ~50MB | ⭐⭐⭐ | 复杂 |
| **C++** | ⚡最快 | 0.5MB | ⭐⭐ | 需编译 |

**推荐：**
- 初学者 → AutoHotkey 或 Python
- 性能要求 → C++
- 已有环境 → 对应版本

---

## 📚 完整指南

### 基本使用
- [QUICKSTART.md](QUICKSTART.md) - 每个版本的详细启动步骤 + **EXE打包教程**

### 版本对比
- [IMPLEMENTATIONS.md](IMPLEMENTATIONS.md) - 各语言详细分析
- [QUICK_COMPARISON.md](QUICK_COMPARISON.md) - 功能对比表

### 单个版本的 README
- [Python 版](python_version/README.md)
- [Node.js 版](nodejs_version/README.md)
- [C++ 版](cpp_version/README.md)

---

## ⚙️ 快速环境配置

### 安装 Python (可选)

```bash
# 下载并安装
https://www.python.org/downloads/

# 验证
python --version
```

### 安装 Node.js (可选)

```bash
# 下载并安装
https://nodejs.org/

# 验证
node --version
npm --version
```

### 安装 C++ 编译器 (可选)

**选项 A: MinGW (推荐，完全免费)**
```bash
# 下载: https://www.mingw-w64.org/
# 或用 scoop 安装
scoop install mingw
```

**选项 B: Visual Studio (免费社区版)**
```
https://visualstudio.microsoft.com/downloads/
选择 "Desktop development with C++"
```

---

## 🎁 打包为 EXE

> **重要**: 详见 [QUICKSTART.md](QUICKSTART.md) 中的 "打包为EXE" 部分

### 快速方法

**Python → EXE** (最简单)
```bash
pip install pyinstaller
cd python_version
pyinstaller --onefile stay_awake.py
```

**C++ → EXE** (最小)
```bash
cd cpp_version
g++ -o stay_awake.exe stay_awake.cpp -std=c++17 -lkernel32
```

**Node.js → EXE**
```bash
npm install -g pkg
cd nodejs_version
pkg . --targets win
```

---

## 🎯 常见问题

### Q: 我该选择哪个版本？
**A:** 
- 只想快速使用 → **AutoHotkey**（有GUI）
- 想学习代码 → **Python**（最清晰）
- 已有Node环境 → **Node.js**
- 需要最小文件 → **C++**

### Q: 能直接运行 EXE 吗？
**A:** 可以！但需要先编译。参考 [QUICKSTART.md](QUICKSTART.md)

### Q: 哪个版本最快？
**A:** **C++** 快 10 倍以上，但需要编译

### Q: 需要管理员权限吗？
**A:** 建议以管理员身份运行以获得最佳效果

### Q: 能在 Linux/Mac 上运行吗？
**A:** Python 和 Node.js 可以，C++ 也可以编译，AutoHotkey 不行

---

## 🔧 启动脚本说明

### startup.bat (Windows)
- 检查环境
- 提供交互菜单
- 一键启动任何版本
- 自动编译（首次）

### startup.ps1 (PowerShell)
- 同上，更多颜色和美观
- 支持环境设置向导

### startup.sh (Linux/Mac)
- Unix 版本的启动脚本
- 自动格式检测

### setup.bat (快速配置)
- 检查工具安装状态
- 安装依赖
- 推荐工具配置

---

## 📊 性能对比

| 指标 | AutoHotkey | Python | Node.js | C++ |
|------|-----------|--------|---------|-----|
| 启动 | 200ms | 300ms | 500ms | <50ms |
| 内存 | 10MB | 40MB | 50MB | 3MB |
| 文件 | 1.5MB | 30MB* | 50MB* | 0.5MB |

\* 编译后的 EXE 大小

---

## 🏃 下一步

1. **立即开始**
   ```bash
   startup.bat
   ```

2. **详细了解**
   - 读 [QUICKSTART.md](QUICKSTART.md)
   - 选择感兴趣的版本

3. **打包分发**
   - 参考 [QUICKSTART.md](QUICKSTART.md) 的 EXE 打包教程
   - 或使用 `build_all.bat` 一次编译所有版本

---

## 📝 快速命令参考

```bash
# 启动
startup.bat              # Windows 启动菜单
.\startup.ps1            # PowerShell 菜单
./startup.sh             # Linux/Mac 菜单

# 配置
setup.bat                # 环境检查和依赖安装

# 直接运行
python python_version/stay_awake.py
node nodejs_version/stay_awake.js
cd cpp_version && g++ -o stay_awake.exe stay_awake.cpp -std=c++17 -lkernel32 && stay_awake.exe

# 编译
cd python_version && pyinstaller --onefile stay_awake.py
cd cpp_version && g++ -O3 -s -o stay_awake.exe stay_awake.cpp -std=c++17 -lkernel32
```

---

## 📄 许可证

MIT License - 自由使用和修改

---

## 🤝 支持

- 遇到问题？读 [QUICKSTART.md](QUICKSTART.md) 的"故障排除"部分
- 想了解更多？参考各版本的 README
- 需要对比？查看 [IMPLEMENTATIONS.md](IMPLEMENTATIONS.md)

---

**立即开始！** 🎉

```bash
startup.bat
```
