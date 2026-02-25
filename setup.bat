@echo off
REM =============================================================================
REM Stay Awake - 一键环境配置脚本
REM =============================================================================

setlocal enabledelayedexpansion
color 0A
title Stay Awake - 环境设置

echo.
echo ============================================================================
echo   Stay Awake - 一键环境配置和依赖安装
echo ============================================================================
echo.

set "python_installed=0"
set "node_installed=0"
set "git_installed=0"

REM 检查Python
echo 检查 Python...
python --version >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=*" %%i in ('python --version') do (
        echo   ✓ %%i
        set "python_installed=1"
    )
) else (
    echo   ✗ Python 未安装
)

REM 检查Node.js
echo 检查 Node.js...
node --version >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=*" %%i in ('node --version') do (
        echo   ✓ Node.js %%i
        set "node_installed=1"
    )
) else (
    echo   ✗ Node.js 未安装
)

REM 检查Git
echo 检查 Git...
git --version >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=*" %%i in ('git --version') do (
        echo   ✓ %%i
        set "git_installed=1"
    )
) else (
    echo   ! Git 未安装（仅在克隆仓库时需要）
)

echo.
echo ============================================================================
echo   选择操作
echo ============================================================================
echo.
echo   1. 仅检查环境（默认）
echo   2. 安装 Python 依赖
echo   3. 安装 Node.js 依赖
echo   4. 安装推荐工具 (PyInstaller, pkg)
echo   5. 完整配置（推荐）
echo   6. 打开快速启动指南
echo.

set /p choice="请输入选择 (1-6, 默认=1): "
if "%choice%"=="" set choice=1

if "%choice%"=="1" goto :check_only
if "%choice%"=="2" goto :install_python
if "%choice%"=="3" goto :install_nodejs
if "%choice%"=="4" goto :install_tools
if "%choice%"=="5" goto :install_all
if "%choice%"=="6" goto :quickstart

echo 无效选择！
pause
exit /b 1

REM =============================================================================
REM 仅检查环境
REM =============================================================================
:check_only
echo.
echo ============================================================================
echo   环境检查完成
echo ============================================================================
echo.
if %python_installed% equ 1 (
    echo ✓ Python: 已安装
    echo   可以运行 Python 版本应用
) else (
    echo ✗ Python: 未安装
    echo   下载: https://www.python.org/downloads/
)

if %node_installed% equ 1 (
    echo ✓ Node.js: 已安装
    echo   可以运行 Node.js 版本应用
) else (
    echo ✗ Node.js: 未安装
    echo   下载: https://nodejs.org/
)

echo ✓ C++: 需要配置（参考 QUICKSTART.md）
echo.
pause
goto :end

REM =============================================================================
REM 安装Python依赖
REM =============================================================================
:install_python
echo.
echo ============================================================================
echo   安装 Python 依赖
echo ============================================================================
echo.

if %python_installed% equ 0 (
    echo 错误: Python 未安装！
    echo 请先从 https://www.python.org/downloads/ 安装 Python
    pause
    goto :end
)

echo 正在升级 pip...
python -m pip install --upgrade pip

echo 正在安装 PyInstaller...
pip install pyinstaller

echo 正在安装 colorama (彩色输出)...
pip install colorama

echo ✓ Python 依赖安装完成！
echo.
pause
goto :end

REM =============================================================================
REM 安装Node.js依赖
REM =============================================================================
:install_nodejs
echo.
echo ============================================================================
echo   安装 Node.js 依赖
echo ============================================================================
echo.

if %node_installed% equ 0 (
    echo 错误: Node.js 未安装！
    echo 请先从 https://nodejs.org/ 安装 Node.js
    pause
    goto :end
)

echo 正在进入 nodejs_version 目录...
cd nodejs_version

echo 正在安装 npm 依赖...
call npm install

echo 正在全局安装 pkg...
call npm install -g pkg

echo ✓ Node.js 依赖安装完成！
echo.

cd ..
pause
goto :end

REM =============================================================================
REM 安装推荐工具
REM =============================================================================
:install_tools
echo.
echo ============================================================================
echo   安装推荐工具
echo ============================================================================
echo.

if %python_installed% equ 1 (
    echo 正在安装 PyInstaller...
    pip install pyinstaller
) else (
    echo 跳过 PyInstaller（需要 Python）
)

if %node_installed% equ 1 (
    echo 正在全局安装 pkg...
    call npm install -g pkg
) else (
    echo 跳过 pkg（需要 Node.js）
)

echo ✓ 工具安装完成！
echo.
pause
goto :end

REM =============================================================================
REM 完整配置
REM =============================================================================
:install_all
echo.
echo ============================================================================
echo   完整环境配置
echo ============================================================================
echo.

if %python_installed% equ 1 (
    echo [1/2] 安装 Python 工具...
    python -m pip install --upgrade pip
    pip install pyinstaller
    pip install colorama
    echo ✓ Python 配置完成
) else (
    echo 跳过 Python（未安装）
)

if %node_installed% equ 1 (
    echo [2/2] 安装 Node.js 工具...
    call npm install -g pkg
    cd nodejs_version
    call npm install
    cd ..
    echo ✓ Node.js 配置完成
) else (
    echo 跳过 Node.js（未安装）
)

echo.
echo ============================================================================
echo   配置完毕！
echo ============================================================================
echo.
echo 现在可以使用以下命令启动各版本应用：
echo.
if %python_installed% equ 1 (
    echo   Python: python python_version/stay_awake.py
)
if %node_installed% equ 1 (
    echo   Node.js: node nodejs_version/stay_awake.js
)
echo   C++: cd cpp_version ^&^& g++ -o stay_awake.exe stay_awake.cpp -std=c++17 -lkernel32 ^&^& stay_awake.exe
echo.
echo 或使用启动脚本：
echo   startup.bat (Windows Batch)
echo   startup.ps1 (PowerShell)
echo   startup.sh (Linux/Mac)
echo.
pause
goto :end

REM =============================================================================
REM 打开QUICKSTART
REM =============================================================================
:quickstart
if exist QUICKSTART.md (
    start "" QUICKSTART.md
    echo QUICKSTART.md 已在默认浏览器中打开
) else (
    echo 错误: QUICKSTART.md 不存在
)
echo.
pause
goto :end

REM =============================================================================
:end
endlocal
