# 🚀 Stay Awake 快速启动指南

## ⚡ 5分钟快速开始

这份指南将帮您快速上手所有版本的Stay Awake应用。

---

## 1️⃣ AutoHotkey版本（原始版本）- 最简单

### 快速启动

**无需安装，直接运行：**

1. **下载AutoHotkey运行时**（可选）
   - 访问 [autohotkey.com](https://www.autohotkey.com/)
   - 下载AutoHotkey v2.0或更高版本

2. **运行脚本**
```bash
# 直接双击运行
src/StayAwake.ahk

# 或在命令行运行
AutoHotkey.exe src/StayAwake.ahk
```

### 打包为EXE

**使用Ahk2Exe编译器（最简单）：**

```bash
# 方法1: 使用Ahk2Exe GUI
# 1. 打开Ahk2Exe（AutoHotkey安装目录）
# 2. 选择脚本文件: src/StayAwake.ahk
# 3. 选择输出文件: stay_awake.exe
# 4. 点击"Convert"

# 方法2: 命令行
"C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" `
  /in src\StayAwake.ahk `
  /out stay_awake.exe `
  /icon stay_awake.ico
```

**结果：**
- 文件大小: ~1.5MB
- 无需任何依赖
- 可直接分发

---

## 2️⃣ Python版本

### 前置要求

```bash
# 1. 安装Python 3.6+
# 下载: https://www.python.org/downloads/

# 验证安装
python --version
```

### 快速启动

```bash
# 1. 进入目录
cd python_version

# 2. 安装依赖（可选，本项目无第三方依赖）
pip install -r requirements.txt

# 3. 运行应用
python stay_awake.py
```

### 打包为EXE - 3种方法

#### 方法1: PyInstaller（推荐）

```bash
# 1. 安装PyInstaller
pip install pyinstaller

# 2. 生成单文件EXE
pyinstaller --onefile --windowed --icon=icon.ico python_version/stay_awake.py

# 3. 在dist/目录中找到可执行文件
dist/stay_awake.exe
```

**优点:**
- 最稳定的方法
- 支持隐藏控制台窗口
- 可添加图标

**参数说明：**
```bash
--onefile          # 生成单个可执行文件
--windowed         # 隐藏控制台窗口（可选）
--icon=icon.ico    # 添加应用图标（可选）
--name stay_awake  # 自定义输出名称
--add-data "src:src"  # 包含额外的数据文件
```

#### 方法2: cx_Freeze

```bash
# 1. 安装cx_Freeze
pip install cx-Freeze

# 2. 创建setup.py
cat > setup.py << EOF
from cx_Freeze import setup, Executable

setup(
    name="Stay Awake",
    version="0.3",
    description="Keep your PC awake",
    executables=[Executable("python_version/stay_awake.py")]
)
EOF

# 3. 构建
python setup.py build

# 4. 在build/目录中找到可执行文件
```

#### 方法3: Auto-py-to-exe (GUI工具)

```bash
# 1. 安装
pip install auto-py-to-exe

# 2. 启动GUI
auto-py-to-exe

# 3. 在GUI中配置
#    - 选择脚本: stay_awake.py
#    - 选择"One File"
#    - 点击"Convert .py to .exe"
```

### 完整打包脚本

创建 `build_python.bat`：

```bash
@echo off
echo Building Python version...
cd python_version

:: 清除旧的构建
rmdir /s /q build dist *.spec 2>nul

:: 安装依赖
pip install -r requirements.txt
pip install pyinstaller

:: 构建EXE
pyinstaller --onefile --windowed ^
  --name stay_awake ^
  --icon ..\img\icon.ico ^
  stay_awake.py

:: 复制到输出目录
cd ..
mkdir output 2>nul
copy python_version\dist\stay_awake.exe output\stay_awake_python.exe

echo Build complete! Output: output\stay_awake_python.exe
pause
```

运行：
```bash
build_python.bat
```

---

## 3️⃣ Node.js版本

### 前置要求

```bash
# 1. 安装Node.js 12.0+
# 下载: https://nodejs.org/

# 验证安装
node --version
npm --version
```

### 快速启动

```bash
# 1. 进入目录
cd nodejs_version

# 2. 安装依赖
npm install

# 3. 运行应用
npm start
# 或
node stay_awake.js
```

### 打包为EXE - 2种方法

#### 方法1: pkg（推荐）

```bash
# 1. 全局安装pkg
npm install -g pkg

# 2. 在项目目录打包
cd nodejs_version
pkg . --targets win

# 3. 在输出目录找到EXE
stay-awake-win.exe
```

**完整配置示例（package.json）：**

```json
{
  "name": "stay-awake",
  "version": "0.3.0",
  "main": "stay_awake.js",
  "bin": "stay_awake.js",
  "pkg": {
    "assets": ["node_modules/**/*"],
    "targets": ["win"],
    "outputPath": "dist"
  },
  "scripts": {
    "build": "pkg . --targets win --output dist/stay_awake.exe"
  },
  "dependencies": {
    "ffi-napi": "^4.0.0",
    "ref-napi": "^3.0.0"
  }
}
```

运行打包：
```bash
npm run build
```

#### 方法2: nexe

```bash
# 1. 安装nexe
npm install -g nexe

# 2. 打包
nexe stay_awake.js -o stay_awake.exe

# 3. 在当前目录找到EXE
stay_awake.exe
```

### 完整打包脚本

创建 `build_nodejs.bat`：

```bash
@echo off
echo Building Node.js version...
cd nodejs_version

:: 清除旧的构建
rmdir /s /q dist node_modules 2>nul

:: 安装依赖
call npm install

:: 全局安装pkg
call npm install -g pkg

:: 打包
call pkg . --targets win --output dist/stay_awake.exe

cd ..
mkdir output 2>nul
copy nodejs_version\dist\stay_awake.exe output\stay_awake_nodejs.exe

echo Build complete! Output: output\stay_awake_nodejs.exe
pause
```

运行：
```bash
build_nodejs.bat
```

---

## 4️⃣ C++版本

### 前置要求

**选择一种编译工具链：**

#### 选项A: MinGW (推荐，完全免费)

```bash
# 1. 下载MinGW-w64
# 链接: https://www.mingw-w64.org/

# 2. 安装（或使用便携版）
# 3. 验证安装
g++ --version
```

#### 选项B: MSVC (Visual Studio)

```bash
# 1. 安装Visual Studio Community（免费）
# 2. 选择"Desktop development with C++"
# 3. 验证安装
cl.exe
```

#### 选项C: Clang

```bash
# 1. 下载Clang for Windows
# 2. 验证安装
clang++ --version
```

### 快速启动（编译）

```bash
# 进入目录
cd cpp_version

# 使用g++编译
g++ -o stay_awake.exe stay_awake.cpp -std=c++17 -lkernel32

# 或使用clang++
clang++ -o stay_awake.exe stay_awake.cpp -std=c++17 -lkernel32

# 运行
stay_awake.exe
```

### 优化编译

```bash
# 最大优化，去除调试符号，压缩大小
g++ -O3 -march=native -s -o stay_awake.exe stay_awake.cpp -std=c++17 -lkernel32

# 结果：~500KB 可执行文件
dir stay_awake.exe
```

### 完整打包脚本

创建 `build_cpp.bat`：

```bash
@echo off
echo Building C++ version...
cd cpp_version

:: 清除旧的构建
del stay_awake.exe 2>nul

:: 编译
echo Compiling...
g++ -O3 -march=native -s -o stay_awake.exe stay_awake.cpp -std=c++17 -lkernel32

if errorlevel 1 (
    echo Build failed!
    pause
    exit /b 1
)

cd ..
mkdir output 2>nul
copy cpp_version\stay_awake.exe output\stay_awake_cpp.exe

echo Build complete! Output: output\stay_awake_cpp.exe
echo File size:
for %%I in (output\stay_awake_cpp.exe) do echo %%~zI bytes
pause
```

运行：
```bash
build_cpp.bat
```

---

## 🔧 一键全部编译

创建 `build_all.bat`：

```batch
@echo off
title Stay Awake - Build All Versions
setlocal enabledelayedexpansion

echo.
echo ============================================
echo      Stay Awake - Build All Versions
echo ============================================
echo.

:: 创建输出目录
mkdir output 2>nul

:: 构建Python版本
echo [1/3] Building Python version...
cd python_version
pip install -r requirements.txt >nul 2>&1
pip install pyinstaller >nul 2>&1
pyinstaller --onefile --windowed ^
  --name stay_awake_python ^
  --distpath ..\output ^
  stay_awake.py >nul 2>&1
cd ..
if exist output\stay_awake_python.exe (
    echo ✓ Python version built successfully
) else (
    echo ✗ Python build failed
)

:: 构建Node.js版本
echo [2/3] Building Node.js version...
cd nodejs_version
call npm install >nul 2>&1
call npm install -g pkg >nul 2>&1
call pkg . --targets win --output ..\output\stay_awake_nodejs.exe >nul 2>&1
cd ..
if exist output\stay_awake_nodejs.exe (
    echo ✓ Node.js version built successfully
) else (
    echo ✗ Node.js build failed
)

:: 构建C++版本
echo [3/3] Building C++ version...
cd cpp_version
g++ -O3 -march=native -s -o ..\output\stay_awake_cpp.exe stay_awake.cpp -std=c++17 -lkernel32 >nul 2>&1
cd ..
if exist output\stay_awake_cpp.exe (
    echo ✓ C++ version built successfully
) else (
    echo ✗ C++ build failed
)

echo.
echo ============================================
echo      Build Summary
echo ============================================
echo.
echo Output directory: output\
echo.
echo File sizes:
for %%I in (output\*.exe) do (
    echo   %%~nxI: %%~zI bytes
)

echo.
echo ============================================
pause
```

运行所有编译：
```bash
build_all.bat
```

---

## 📊 编译结果对比

| 版本 | 文件大小 | 编译时间 | 依赖 |
|------|---------|--------|------|
| Python | 30-50MB | 30-60s | 无 |
| Node.js | 40-60MB | 20-40s | 无 |
| C++ | 0.5-2MB | 5-10s | 无 |

---

## ✅ 验证安装

### 验证Python

```bash
python --version
# 输出: Python 3.x.x

python -c "import ctypes; print('✓ ctypes available')"
```

### 验证Node.js

```bash
node --version
# 输出: v12.x.x 或更高

npm --version
# 输出: 6.x.x 或更高
```

### 验证C++编译器

```bash
# MinGW
g++ --version

# 或 Visual Studio
cl.exe

# 或 Clang
clang++ --version
```

---

## 🐛 常见问题

### Python编译失败

**错误**: "pyinstaller: command not found"
```bash
# 解决
pip install --upgrade pyinstaller
```

**错误**: "ctypes not found"
```bash
# 解决（ctypes是Python内置，检查Python安装）
python -c "import ctypes"
```

### Node.js编译失败

**错误**: "MSBUILD : error MSB3873"
```bash
# 解决（安装必要的构建工具）
npm install --global windows-build-tools
```

**错误**: "Cannot find ffi-napi"
```bash
# 解决
cd nodejs_version
npm install
```

### C++编译失败

**错误**: "g++: command not found"
```bash
# 解决（添加MinGW到PATH）
set PATH=C:\Program Files\mingw-w64\bin;%PATH%
g++ --version
```

**错误**: "kernel32 not found"
```bash
# 解决（确保使用-lkernel32标志）
g++ -o out.exe main.cpp -lkernel32
```

---

## 📦 分发最小化

### Python版本优化

```bash
# 使用UPX压缩
pip install pyinstaller
pyinstaller --onefile --upx-dir=C:\upx stay_awake.py

# 结果: ~15-20MB（从30-50MB）
```

### Node.js版本优化

```bash
# 使用--compress选项
pkg . --targets win --compress Brotli

# 结果: ~25-35MB（从40-60MB）
```

### C++版本优化

```bash
# 已经极小化
# 可再用UPX进一步压缩
upx --best --lzma stay_awake.exe

# 结果: ~200-400KB（从500KB-2MB）
```

---

## 🚀 自动化脚本示例

### PowerShell版本

创建 `build.ps1`：

```powershell
# 全面构建脚本
$ErrorActionPreference = "Stop"

function Build-Python {
    Write-Host "Building Python version..." -ForegroundColor Cyan
    Push-Location python_version
    pip install -r requirements.txt
    pip install pyinstaller
    pyinstaller --onefile stay_awake.py
    Pop-Location
}

function Build-NodeJS {
    Write-Host "Building Node.js version..." -ForegroundColor Cyan
    Push-Location nodejs_version
    npm install
    npm install -g pkg
    pkg . --targets win
    Pop-Location
}

function Build-CPP {
    Write-Host "Building C++ version..." -ForegroundColor Cyan
    Push-Location cpp_version
    g++ -O3 -s -o stay_awake.exe stay_awake.cpp -std=c++17 -lkernel32
    Pop-Location
}

# 执行所有构建
try {
    mkdir output -ErrorAction SilentlyContinue
    Build-Python
    Build-NodeJS
    Build-CPP
    Write-Host "All builds completed!" -ForegroundColor Green
} catch {
    Write-Host "Build failed: $_" -ForegroundColor Red
}
```

运行：
```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
.\build.ps1
```

---

## 📋 检查清单

部署前验证清单：

- [ ] 所有版本都能成功编译
- [ ] EXE文件可正常执行
- [ ] 无管理员权限警告（如果需要则添加manifest）
- [ ] 文件大小符合预期
- [ ] 包含必要的资源文件（图标等）

---

## 🎯 推荐流程

### 第一次设置（5分钟）

```bash
# 1. 克隆或下载项目
git clone https://github.com/jNizM/stay-awake.git
cd stay-awake

# 2. 测试运行各个版本（选一个）
# Python
python python_version/stay_awake.py

# Node.js
node nodejs_version/stay_awake.js

# C++
g++ -o test.exe cpp_version/stay_awake.cpp -std=c++17 -lkernel32
test.exe
```

### 生成发布版本（10分钟）

```bash
# 运行全部构建脚本
build_all.bat

# 生成的文件在 output/ 目录
cd output
dir
```

### 分发和安装

```bash
# 选择需要的版本，直接分发EXE
# 或创建安装程序

# NSIS示例
# installer.nsi 配置文件指向 output/*.exe
makensis installer.nsi
# 生成 StayAwakeInstaller.exe
```

---

## 💡 高级技巧

### 添加应用图标

```bash
# Python + PyInstaller
pyinstaller --onefile --icon=icon.ico stay_awake.py

# C++ + Resource编译
# 创建 resources.rc 文件
# rc resources.rc
# g++ stay_awake.cpp resources.res
```

### 自动更新机制

```batch
@echo off
REM 检查新版本并自动更新
curl -o new_version.exe https://example.com/latest.exe
if exist new_version.exe (
    del old_version.exe
    ren new_version.exe stay_awake.exe
)
```

### 创建便携版本

```bash
# 不需要安装的完整包
mkdir StayAwake_Portable
copy output\stay_awake_*.exe StayAwake_Portable\
copy README.md StayAwake_Portable\
7z a StayAwake_Portable.7z StayAwake_Portable\
```

---

**下一步**: 选择上面的任何一个版本开始使用！🎉
