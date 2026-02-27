#!/usr/bin/env powershell
# =============================================================================
# Stay Awake - PowerShell启动和配置脚本
# =============================================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# 禁用错误停止以便继续执行
$ErrorActionPreference = "Continue"

# 设置控制台颜色
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Error { Write-Host $args -ForegroundColor Red }
function Write-Warning { Write-Host $args -ForegroundColor Yellow }
function Write-Info { Write-Host $args -ForegroundColor Cyan }

Clear-Host

Write-Host ""
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "   Stay Awake - PowerShell 配置和启动脚本" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# 检查环境
# =============================================================================

function Test-Environment {
    Write-Info "[检查环境配置...]"
    Write-Host ""
    
    # 检查Python
    Write-Host "检查 Python..."
    try {
        $version = python --version 2>&1
        Write-Success "  ✓ $version 已安装"
    } catch {
        Write-Error "  ✗ Python 未安装或未在PATH中"
    }
    
    # 检查Node.js
    Write-Host "检查 Node.js..."
    try {
        $version = node --version
        Write-Success "  ✓ Node.js $version 已安装"
    } catch {
        Write-Error "  ✗ Node.js 未安装或未在PATH中"
    }
    
    # 检查npm
    Write-Host "检查 npm..."
    try {
        $version = npm --version
        Write-Success "  ✓ npm $version 已安装"
    } catch {
        Write-Error "  ✗ npm 未安装或未在PATH中"
    }
    
    # 检查G++
    Write-Host "检查 C++ 编译器 (g++)..."
    try {
        $version = g++ --version 2>&1 | Select-Object -First 1
        Write-Success "  ✓ g++ 已安装"
    } catch {
        Write-Error "  ✗ g++ 未安装"
    }
    
    Write-Host ""
}

# =============================================================================
# 安装依赖
# =============================================================================

function Install-Dependencies {
    Write-Info "[安装依赖...]"
    Write-Host ""
    
    # 检查Python依赖
    Write-Host "Python 依赖检查..."
    try {
        python -c "import ctypes" -ErrorAction Stop
        Write-Success "  ✓ Python ctypes 已可用"
    } catch {
        Write-Error "  ✗ Python ctypes 不可用"
    }
    
    # 检查Node.js依赖
    Write-Host "Node.js 依赖检查..."
    if (Test-Path "nodejs_version/node_modules") {
        Write-Success "  ✓ Node.js 依赖已安装"
    } else {
        Write-Warning "  ! Node.js 需要运行 'npm install'"
    }
    
    Write-Host ""
}

# =============================================================================
# 启动应用
# =============================================================================

function Start-AutoHotkey {
    Write-Info "[启动 AutoHotkey 版本...]"
    Write-Host ""
    
    if (-not (Test-Path "src/StayAwake.ahk")) {
        Write-Error "错误: 找不到 src/StayAwake.ahk"
        Read-Host "按 Enter 继续"
        return
    }
    
    Write-Host "尝试启动 AutoHotkey 脚本..."
    try {
        Start-Process "src/StayAwake.ahk"
        Write-Success "AutoHotkey 应用已启动"
    } catch {
        Write-Error "启动失败，请确保已安装 AutoHotkey v2.0+"
    }
    
    Read-Host "按 Enter 返回菜单"
}

function Start-Python {
    Write-Info "[启动 Python 版本...]"
    Write-Host ""
    
    if (-not (Test-Path "python_version/stay_awake.py")) {
        Write-Error "错误: 找不到 python_version/stay_awake.py"
        Read-Host "按 Enter 继续"
        return
    }
    
    Push-Location python_version
    Write-Host "运行应用..."
    python stay_awake.py
    Pop-Location
}

function Start-NodeJS {
    Write-Info "[启动 Node.js 版本...]"
    Write-Host ""
    
    if (-not (Test-Path "nodejs_version/stay_awake.js")) {
        Write-Error "错误: 找不到 nodejs_version/stay_awake.js"
        Read-Host "按 Enter 继续"
        return
    }
    
    Push-Location nodejs_version
    
    if (-not (Test-Path "node_modules")) {
        Write-Host "正在安装依赖..."
        npm install
    }
    
    Write-Host "运行应用..."
    node stay_awake.js
    
    Pop-Location
}

function Start-CPP {
    Write-Info "[启动 C++ 版本...]"
    Write-Host ""
    
    if (-not (Test-Path "cpp_version/stay_awake.cpp")) {
        Write-Error "错误: 找不到 cpp_version/stay_awake.cpp"
        Read-Host "按 Enter 继续"
        return
    }
    
    Push-Location cpp_version
    
    if (-not (Test-Path "stay_awake.exe")) {
        Write-Host "编译应用中（首次运行）..."
        g++ -O2 -o stay_awake.exe stay_awake.cpp -std=c++17 -lkernel32
        
        if ($LASTEXITCODE -ne 0) {
            Write-Error "编译失败！请确保已安装 g++"
            Pop-Location
            Read-Host "按 Enter 继续"
            return
        }
    }
    
    Write-Host "运行应用..."
    .\stay_awake.exe
    
    Pop-Location
}

# =============================================================================
# 编译所有版本
# =============================================================================

function Build-AllVersions {
    Write-Info "[编译所有版本为 EXE 文件]"
    Write-Host ""
    
    New-Item -ItemType Directory -Force -Path output | Out-Null
    
    # 编译C++
    Write-Host "[1/3] 编译 C++ 版本..."
    Push-Location cpp_version
    
    if (Test-Path "stay_awake.exe") {
        Remove-Item "stay_awake.exe"
    }
    
    Write-Host "  编译中..."
    g++ -O3 -march=native -s -o stay_awake.exe stay_awake.cpp -std=c++17 -lkernel32 2>$null
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "  ✗ C++ 编译失败"
    } else {
        Copy-Item stay_awake.exe ../output/stay_awake_cpp.exe
        Write-Success "  ✓ C++ 编译成功 (stay_awake_cpp.exe)"
    }
    
    Pop-Location
    
    # 编译Python
    Write-Host "[2/3] 编译 Python 版本..."
    try {
        pip install --quiet pyinstaller 2>$null
        
        Push-Location python_version
        
        $output = pyinstaller --onefile --windowed --name stay_awake_python --distpath ../output stay_awake.py 2>&1
        
        if ($LASTEXITCODE -ne 0) {
            Write-Error "  ✗ Python 编译失败"
        } else {
            Write-Success "  ✓ Python 编译成功 (stay_awake_python.exe)"
        }
        
        Pop-Location
    } catch {
        Write-Warning "  ! 无法编译 Python 版本"
    }
    
    # 编译Node.js
    Write-Host "[3/3] 编译 Node.js 版本..."
    Push-Location nodejs_version
    
    npm install --quiet 2>$null
    npm install -g pkg --quiet 2>$null
    
    pkg . --targets win --output ../output/stay_awake_nodejs.exe 2>$null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "  ✓ Node.js 编译成功 (stay_awake_nodejs.exe)"
    } else {
        Write-Warning "  ! Node.js 编译失败（这可能是正常的）"
    }
    
    Pop-Location
    
    # 显示结果
    Write-Host ""
    Write-Info "============================================================================"
    Write-Info "   编译结果"
    Write-Info "============================================================================"
    Write-Host ""
    
    Get-ChildItem output\*.exe | ForEach-Object {
        $size = $_.Length
        Write-Host "  $($_.Name): $size 字节"
    }
    
    Write-Host ""
    Write-Host "所有EXE文件都在 output\ 目录中" -ForegroundColor Yellow
    Write-Host ""
    
    Read-Host "按 Enter 返回菜单"
}

# =============================================================================
# 设置步骤
# =============================================================================

function Setup-Environment {
    Write-Info "[环境设置向导]"
    Write-Host ""
    
    Write-Host "这将帮助您安装所需的依赖。选择要安装的组件："
    Write-Host ""
    Write-Host "1. 安装 Python 依赖"
    Write-Host "2. 安装 Node.js 依赖"
    Write-Host "3. 检查 C++ 编译器"
    Write-Host "4. 安装所有推荐的工具"
    Write-Host "5. 返回菜单"
    Write-Host ""
    
    $choice = Read-Host "请输入选择 (1-5)"
    
    switch ($choice) {
        "1" {
            Write-Host "pip install --quiet pyinstaller"
            pip install pyinstaller
        }
        "2" {
            Push-Location nodejs_version
            npm install
            Pop-Location
        }
        "3" {
            Write-Host "检查 g++ 是否可用..."
            g++ --version
        }
        "4" {
            Write-Host "安装推荐工具..."
            pip install pyinstaller
            npm install -g pkg
        }
        "5" { return }
    }
    
    Read-Host "按 Enter 返回菜单"
}

# =============================================================================
# 主菜单
# =============================================================================

function Show-Menu {
    Clear-Host
    Write-Host ""
    Write-Host "============================================================================" -ForegroundColor Cyan
    Write-Host "   Stay Awake - 快速启动菜单" -ForegroundColor Cyan
    Write-Host "============================================================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Info "选择要启动的版本："
    Write-Host ""
    Write-Host "   1. AutoHotkey 版本 (GUI界面)"
    Write-Host "   2. Python 版本 (命令行菜单)"
    Write-Host "   3. Node.js 版本 (命令行菜单)"
    Write-Host "   4. C++ 版本 (命令行菜单)"
    Write-Host ""
    Write-Info "工具和配置："
    Write-Host ""
    Write-Host "   5. 编译所有版本为 EXE 文件"
    Write-Host "   6. 环境设置向导"
    Write-Host "   7. 检查环境"
    Write-Host "   8. 打开快速启动指南"
    Write-Host "   9. 退出"
    Write-Host ""
    
    $choice = Read-Host "请输入选择 (1-9)"
    
    switch ($choice) {
        "1" { Start-AutoHotkey }
        "2" { Start-Python }
        "3" { Start-NodeJS }
        "4" { Start-CPP }
        "5" { Build-AllVersions }
        "6" { Setup-Environment }
        "7" { Test-Environment; Read-Host "按 Enter 继续" }
        "8" {
            if (Test-Path "QUICKSTART.md") {
                Start-Process "QUICKSTART.md"
            } else {
                Write-Error "QUICKSTART.md 不存在"
                Read-Host "按 Enter 继续"
            }
        }
        "9" { exit }
    }
    
    if ($choice -ne "9") {
        Show-Menu
    }
}

# =============================================================================
# 主程序
# =============================================================================

Test-Environment
Install-Dependencies
Show-Menu

Write-Host ""
Write-Host "再见！" -ForegroundColor Green
