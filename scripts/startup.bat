@echo off
chcp 65001 >nul
REM =============================================================================
REM Stay Awake - 环境配置和一键启动脚本
REM =============================================================================

setlocal enabledelayedexpansion
color 0A
title Stay Awake - Configuration and Launch

echo.
echo ============================================================================
echo   Stay Awake - 多语言版本环境配置和启动
echo ============================================================================
echo.

REM 检查环境
echo --- 检查环境配置 ---
echo.

REM 检查Python
echo 检查 Python...
python --version >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=*" %%i in ('python --version') do (
        echo   ✓ %%i 已安装
    )
) else (
    echo   ✗ Python 未安装或未在PATH中
)

REM 检查Node.js
echo 检查 Node.js...
node --version >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=*" %%i in ('node --version') do (
        echo   ✓ Node.js %%i 已安装
    )
) else (
    echo   ✗ Node.js 未安装或未在PATH中
)

REM 检查npm
echo 检查 npm...
call npm --version >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=*" %%i in ('call npm --version') do (
        echo   ✓ npm %%i 已安装
    )
) else (
    echo   ✗ npm 未安装或未在PATH中
)

REM 检查G++
echo 检查 C++ 编译器 (g++)...
g++ --version >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=1" %%i in ('g++ --version') do (
        echo   ✓ g++ 已安装
        goto :found_cpp
    )
) else (
    echo   ✗ g++ 未安装
    goto :skip_cpp
)
:found_cpp
:skip_cpp

REM 检查Visual Studio (可选)
echo 检查 Visual Studio C++ 编译器 (cl.exe)...
cl.exe >nul 2>&1
if %errorlevel% equ 0 (
    echo   ✓ MSVC cl.exe 已安装
) else (
    echo   ✗ MSVC cl.exe 未安装
)

echo.
echo ============================================================================
echo   选择要启动的版本
echo ============================================================================
echo.
echo   1. AutoHotkey版本 (GUI界面)
echo   2. Python版本 (命令行菜单)
echo   3. Node.js版本 (命令行菜单)
echo   4. C++版本 (命令行菜单)
echo   5. 一键编译所有版本为EXE
echo   6. 打开快速启动指南 (QUICKSTART.md)
echo   7. 退出
echo.

set /p choice="请输入选择 (1-7): "

if "%choice%"=="1" goto :autohotkey
if "%choice%"=="2" goto :python
if "%choice%"=="3" goto :nodejs
if "%choice%"=="4" goto :cpp
if "%choice%"=="5" goto :build_all
if "%choice%"=="6" goto :quickstart
if "%choice%"=="7" goto :exit_script

echo 无效选择！
pause
goto :end

REM =============================================================================
REM AutoHotkey版本
REM =============================================================================
:autohotkey
echo.
echo 启动 AutoHotkey 版本...
echo.

if not exist "src\StayAwake.ahk" (
    echo 错误: 找不到 src\StayAwake.ahk
    pause
    goto :end
)

echo 尝试启动AutoHotkey脚本...
start "" "src\StayAwake.ahk"

echo AutoHotkey应用已启动（如果已安装AutoHotkey）
echo 如果没有反应，请确保已安装 AutoHotkey v2.0+
echo.
pause
goto :end

REM =============================================================================
REM Python版本
REM =============================================================================
:python
echo.
echo 启动 Python 版本...
echo.

if not exist "python_version\stay_awake.py" (
    echo 错误: 找不到 python_version\stay_awake.py
    pause
    goto :end
)

cd python_version
echo 运行应用...
python stay_awake.py
cd ..

goto :end

REM =============================================================================
REM Node.js版本
REM =============================================================================
:nodejs
echo.
echo 启动 Node.js 版本...
echo.

if not exist "nodejs_version\stay_awake.js" (
    echo 错误: 找不到 nodejs_version\stay_awake.js
    pause
    goto :end
)

cd nodejs_version

REM 检查依赖
if not exist "node_modules" (
    echo 正在安装依赖...
    call npm install
)

echo 运行应用...
call node stay_awake.js
cd ..

goto :end

REM =============================================================================
REM C++版本
REM =============================================================================
:cpp
echo.
echo 启动 C++ 版本...
echo.

if not exist "cpp_version\stay_awake.cpp" (
    echo 错误: 找不到 cpp_version\stay_awake.cpp
    pause
    goto :end
)

cd cpp_version

REM 检查编译
if not exist "stay_awake.exe" (
    echo 编译应用中（首次运行）...
    g++ --version >nul 2>&1
    if %errorlevel% equ 0 (
        g++ -O2 -o stay_awake.exe stay_awake.cpp -std=c++17 -lkernel32
    ) else (
        cl.exe /utf-8 /EHsc /O2 /Fe:stay_awake.exe stay_awake.cpp >nul 2>&1
    )
    if not exist "stay_awake.exe" (
        echo.
        echo 编译失败！请确保已安装 g++ 或 cl.exe
        pause
        cd ..
        goto :end
    )
)

echo 运行应用...
call stay_awake.exe
cd ..

goto :end

REM =============================================================================
REM 编译所有版本
REM =============================================================================
:build_all
echo.
echo ============================================================================
echo   编译所有版本为 EXE 文件
echo ============================================================================
echo.

mkdir output 2>nul

REM 编译 C++
echo [1/3] 编译 C++ 版本...
cd cpp_version
if exist stay_awake.exe del stay_awake.exe
echo   编译中...
g++ --version >nul 2>&1
if %errorlevel% equ 0 (
    g++ -O3 -march=native -s -o stay_awake.exe stay_awake.cpp -std=c++17 -lkernel32
) else (
    cl.exe /utf-8 /EHsc /O2 /Fe:stay_awake.exe stay_awake.cpp >nul 2>&1
)
if not exist stay_awake.exe (
    echo   ✗ C++ 编译失败
    cd ..
    goto :after_build
)
copy stay_awake.exe ..\output\stay_awake_cpp.exe >nul
echo   ✓ C++ 编译成功 (stay_awake_cpp.exe)
cd ..

REM 编译 Python
echo [2/3] 编译 Python 版本...
python -m pip install --quiet pyinstaller 2>nul
if errorlevel 1 (
    echo   ! 无法安装 PyInstaller，跳过 Python 编译
) else (
    cd python_version
    call pyinstaller --onefile --windowed --name stay_awake_python --distpath ..\output stay_awake.py >nul 2>&1
    if errorlevel 1 (
        echo   ✗ Python 编译失败
    ) else (
        echo   ✓ Python 编译成功 (stay_awake_python.exe)
    )
    cd ..
)

REM 编译 Node.js
echo [3/3] 编译 Node.js 版本...
cd nodejs_version
call npm install --quiet >nul 2>&1
call npm install -g pkg --quiet >nul 2>&1
call pkg . --targets win --output ..\output\stay_awake_nodejs.exe >nul 2>&1
if errorlevel 1 (
    echo   ! Node.js 编译可能失败（这是正常的，需要依赖复杂）
) else (
    echo   ✓ Node.js 编译成功 (stay_awake_nodejs.exe)
)
cd ..

:after_build
echo.
echo ============================================================================
echo   编译结果
echo ============================================================================
echo.
if exist output\stay_awake_cpp.exe (
    for %%I in (output\stay_awake_cpp.exe) do (
        echo   C++ 版本: %%~zI 字节
    )
)
if exist output\stay_awake_python.exe (
    for %%I in (output\stay_awake_python.exe) do (
        echo   Python 版本: %%~zI 字节
    )
)
if exist output\stay_awake_nodejs.exe (
    for %%I in (output\stay_awake_nodejs.exe) do (
        echo   Node.js 版本: %%~zI 字节
    )
)
echo.
echo   所有EXE文件都在 output\ 目录中
echo.
pause
goto :end

REM =============================================================================
REM 打开QUICKSTART指南
REM =============================================================================
:quickstart
echo.
echo 打开 QUICKSTART.md...
if exist QUICKSTART.md (
    start "" QUICKSTART.md
) else (
    echo 错误: QUICKSTART.md 不存在
    pause
)
goto :end

REM =============================================================================
REM 退出
REM =============================================================================
:exit_script
echo.
echo 再见！
echo.

REM =============================================================================
:end
endlocal
