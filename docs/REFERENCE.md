# 📋 快速参考卡

## 🚀 立即启动

### Windows (推荐)
```bash
startup.bat
```

### PowerShell
```powershell
.\startup.ps1
```

### Linux/Mac
```bash
./startup.sh
```

---

## 📚 文档导航

| 文档 | 用途 |
|------|------|
| **START_HERE.md** | 👈 新用户必读 |
| **QUICKSTART.md** | 详细启动 + **EXE打包教程** |
| **IMPLEMENTATIONS.md** | 各语言对比分析 |
| **QUICK_COMPARISON.md** | 快速选择指南 |

---

## 💻 直接运行各版本

### AutoHotkey (无需依赖)
```bash
src/StayAwake.ahk
```

### Python (需要 Python 3.6+)
```bash
python python_version/stay_awake.py
```

### Node.js (需要 Node.js 12+)
```bash
cd nodejs_version
npm install
node stay_awake.js
```

### C++ (需要 g++ 或 MSVC)
```bash
cd cpp_version
g++ -o stay_awake.exe stay_awake.cpp -std=c++17 -lkernel32
.\stay_awake.exe
```

---

## ⚙️ 环境配置

### 检查和安装依赖
```bash
setup.bat
```

### 安装 Python 工具
```bash
pip install pyinstaller
pip install colorama
```

### 安装 Node.js 工具
```bash
npm install -g pkg
```

### 验证 C++ 编译器
```bash
g++ --version
```

---

## 📦 编译为 EXE

### Python → EXE
```bash
cd python_version
pip install pyinstaller
pyinstaller --onefile stay_awake.py
```

输出: `dist/stay_awake.exe` (30-50MB)

### C++ → EXE (推荐)
```bash
cd cpp_version
g++ -O3 -s -o stay_awake.exe stay_awake.cpp -std=c++17 -lkernel32
```

输出: `stay_awake.exe` (0.5-2MB) ⭐

### Node.js → EXE
```bash
cd nodejs_version
npm install -g pkg
pkg . --targets win
```

输出: `stay-awake-win.exe` (40-60MB)

---

## 🎁 一键编译所有版本

```bash
build_all.bat
```

输出目录: `output/`
- `stay_awake_cpp.exe` - C++ 版本 (最小)
- `stay_awake_python.exe` - Python 版本 (需时间)
- `stay_awake_nodejs.exe` - Node.js 版本 (需时间)

---

## 🎓 版本选择快速表

| 需求 | 选择 |
|------|------|
| 最简单，有GUI | **AutoHotkey** |
| 易学，代码清晰 | **Python** |
| 最快速度 | **C++** |
| 最小体积 | **C++** |
| Web集成 | **Node.js** |
| 学习编程 | **Python** |
| 公司部署 | **C++** 或 **AutoHotkey** |

---

## 🔧 实用脚本

### 编译并输出 Python EXE
```batch
@echo off
cd python_version
pip install pyinstaller
pyinstaller --onefile --windowed ^
  --name stay_awake_python ^
  --distpath ..\dist ^
  stay_awake.py
cd ..
```

### 编译并输出 C++ EXE
```batch
@echo off
cd cpp_version
g++ -O3 -march=native -s ^
  -o stay_awake_cpp.exe ^
  stay_awake.cpp -std=c++17 -lkernel32
cd ..
```

---

## ❓ FAQ

**Q: 哪个版本最好？**
- 初学者 → Python
- 不懂编程 → AutoHotkey
- 性能最优 → C++
- 已有环境 → 对应语言

**Q: 能直接分发 EXE 吗？**
- ✅ 可以！参考上面的"编译为EXE"

**Q: 需要管理员权限吗？**
- ✅ 建议（为了最佳兼容性）

**Q: 支持 Linux/Mac 吗？**
- ✅ Python 和 C++ 支持
- ❌ AutoHotkey 仅 Windows

**Q: 最小化文件大小？**
- 使用 C++: `g++ -O3 -s ...` → 0.5-2MB

**Q: 加速编译速度？**
- 编译前用 `pip install --upgrade pip`
- 使用 C++（编译最快）

---

## 📁 完整文件列表

```
stay-awake/
├── START_HERE.md              # 👈 新用户从这里开始
├── QUICKSTART.md              # 详细启动和EXE打包教程
├── IMPLEMENTATIONS.md         # 各版本完整分析
├── QUICK_COMPARISON.md        # 快速对比
├── REFERENCE.md               # 本文件
│
├── startup.bat                # ⭐ Windows 启动菜单
├── startup.ps1                # PowerShell 启动菜单
├── startup.sh                 # Linux/Mac 启动菜单
├── setup.bat                  # 环境配置向导
├── build_all.bat              # 一键编译所有版本
│
├── src/                       # AutoHotkey 版本
│   └── StayAwake.ahk
│
├── python_version/            # Python 版本
│   ├── stay_awake.py
│   ├── requirements.txt
│   └── README.md
│
├── nodejs_version/            # Node.js 版本
│   ├── stay_awake.js
│   ├── package.json
│   └── README.md
│
└── cpp_version/               # C++ 版本
    ├── stay_awake.cpp
    └── README.md
```

---

## 🚀 20秒快速开始

1. **下载项目**
   ```bash
   git clone https://github.com/jNizM/stay-awake.git
   cd stay-awake
   ```

2. **启动应用**
   ```bash
   startup.bat
   ```

3. **选择版本**
   ```
   1. AutoHotkey (无需依赖)
   2. Python
   3. Node.js
   4. C++
   ```

---

## 💡 专业提示

### 性能优化 (C++)
```bash
g++ -O3 -march=native -s -o stay_awake.exe stay_awake.cpp
```

### 最小化包体积 (Python)
```bash
pip install pyinstaller
pyinstaller --onefile --upx-dir=C:\upx stay_awake.py
```

### 创建安装程序
- 使用 NSIS 或 MSI 包装 EXE
- 参考: QUICKSTART.md

### 后台服务化 (C++)
- 使用 Windows Service Wrapper
- 或 NSSM: Non-Sucking Service Manager

---

## 📞 获取帮助

1. 读 **QUICKSTART.md** 的"故障排除"部分
2. 查看各版本的 README
3. 参考 **IMPLEMENTATIONS.md**

---

**下一步**: 打开 [START_HERE.md](START_HERE.md) 了解更多 👉
