@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

echo.
echo ============================================
echo   Stay Awake - Build All Versions
echo ============================================
echo.

set "ROOT_DIR=%cd%"
set "OUTPUT_DIR=%ROOT_DIR%\output"

REM 创建输出目录
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

REM ========== Python版本 ==========
echo [1/3] Building Python version...
echo ----------------------------------------

cd /d "%ROOT_DIR%\python_version"

REM 检查PyInstaller
pip show pyinstaller > nul 2>&1
if errorlevel 1 (
    echo Installing PyInstaller...
    pip install pyinstaller
)

REM 生成EXE
echo Generating EXE with PyInstaller...
pyinstaller --noconfirm --clean --onefile --distpath "%OUTPUT_DIR%\python" stay_awake.py

if exist "%OUTPUT_DIR%\python\stay_awake.exe" (
    echo ✓ Python EXE created: %OUTPUT_DIR%\python\stay_awake.exe
) else (
    echo ✗ Python EXE build failed
)

cd /d "%ROOT_DIR%"

REM ========== Node.js版本 ==========
echo.
echo [2/3] Building Node.js version...
echo ----------------------------------------

cd /d "%ROOT_DIR%\nodejs_version"

REM 安装依赖并使用 electron-packager 打包
echo Installing Node.js dependencies...
npm install

echo Generating EXE with electron-packager...
npx electron-packager . "Stay Awake" --platform=win32 --arch=x64 --out=dist-packager --overwrite

if not exist "%OUTPUT_DIR%\nodejs" mkdir "%OUTPUT_DIR%\nodejs"
xcopy /E /I /Y "dist-packager\Stay Awake-win32-x64\*" "%OUTPUT_DIR%\nodejs\" > nul

if exist "%OUTPUT_DIR%\nodejs\Stay Awake.exe" (
    echo ✓ Node.js EXE created: %OUTPUT_DIR%\nodejs\Stay Awake.exe
) else (
    echo ✗ Node.js EXE build failed
)

cd /d "%ROOT_DIR%"

REM ========== C++版本 ==========
echo.
echo [3/3] Building C++ version...
echo ----------------------------------------

cd /d "%ROOT_DIR%\cpp_version"

REM 检查g++
where g++ > nul 2>&1
if errorlevel 1 (
    echo ✗ g++ not found. Please install MinGW or a C++ compiler.
    cd /d "%ROOT_DIR%"
    goto :error
)

REM 编译EXE
echo Compiling with g++...
if not exist "%OUTPUT_DIR%\cpp" mkdir "%OUTPUT_DIR%\cpp"
g++ -O3 -s -o "%OUTPUT_DIR%\cpp\stay_awake.exe" stay_awake.cpp -std=c++17 -lkernel32

if exist "%OUTPUT_DIR%\cpp\stay_awake.exe" (
    echo ✓ C++ EXE created: %OUTPUT_DIR%\cpp\stay_awake.exe
) else (
    echo ✗ C++ EXE build failed
)

cd /d "%ROOT_DIR%"

REM ========== 总结 ==========
echo.
echo ============================================
echo   Build Summary
echo ============================================
echo.

if exist "%OUTPUT_DIR%\python\stay_awake.exe" (
    for %%A in ("%OUTPUT_DIR%\python\stay_awake.exe") do set "PYTHON_SIZE=%%~zA"
    echo ✓ Python:  !PYTHON_SIZE! bytes
)

if exist "%OUTPUT_DIR%\nodejs\Stay Awake.exe" (
    for %%A in ("%OUTPUT_DIR%\nodejs\Stay Awake.exe") do set "NODEJS_SIZE=%%~zA"
    echo ✓ Node.js: !NODEJS_SIZE! bytes
)

if exist "%OUTPUT_DIR%\cpp\stay_awake.exe" (
    for %%A in ("%OUTPUT_DIR%\cpp\stay_awake.exe") do set "CPP_SIZE=%%~zA"
    echo ✓ C++:     !CPP_SIZE! bytes
)

echo.
echo All executables available in: %OUTPUT_DIR%
echo.
pause
exit /b 0

:error
echo.
echo Build failed. Please check the error messages above.
echo.
pause
exit /b 1
