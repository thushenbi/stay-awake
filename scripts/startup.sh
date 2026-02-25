#!/bin/bash
# =============================================================================
# Stay Awake - Linux/Mac 启动脚本
# =============================================================================

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 函数定义
print_header() {
    clear
    echo ""
    echo -e "${CYAN}============================================================================${NC}"
    echo -e "${CYAN}   Stay Awake - Linux/Mac 启动脚本${NC}"
    echo -e "${CYAN}============================================================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}! $1${NC}"
}

print_info() {
    echo -e "${CYAN}[*] $1${NC}"
}

# 检查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 检查环境
check_environment() {
    print_info "检查环境配置..."
    echo ""
    
    echo "检查 Python..."
    if command_exists python3; then
        version=$(python3 --version 2>&1)
        print_success "$version 已安装"
    else
        print_error "Python 未安装"
    fi
    
    echo "检查 Node.js..."
    if command_exists node; then
        version=$(node --version)
        print_success "Node.js $version 已安装"
    else
        print_error "Node.js 未安装"
    fi
    
    echo "检查 npm..."
    if command_exists npm; then
        version=$(npm --version)
        print_success "npm $version 已安装"
    else
        print_error "npm 未安装"
    fi
    
    echo "检查 g++..."
    if command_exists g++; then
        print_success "g++ 已安装"
    else
        print_error "g++ 未安装"
    fi
    
    echo ""
}

# 启动Python版本
start_python() {
    print_info "启动 Python 版本..."
    echo ""
    
    if [ ! -f "python_version/stay_awake.py" ]; then
        print_error "找不到 python_version/stay_awake.py"
        read -p "按 Enter 继续"
        return
    fi
    
    cd python_version
    echo "运行应用..."
    python3 stay_awake.py
    cd ..
}

# 启动Node.js版本
start_nodejs() {
    print_info "启动 Node.js 版本..."
    echo ""
    
    if [ ! -f "nodejs_version/stay_awake.js" ]; then
        print_error "找不到 nodejs_version/stay_awake.js"
        read -p "按 Enter 继续"
        return
    fi
    
    cd nodejs_version
    
    if [ ! -d "node_modules" ]; then
        echo "正在安装依赖..."
        npm install
    fi
    
    echo "运行应用..."
    node stay_awake.js
    
    cd ..
}

# 启动C++版本
start_cpp() {
    print_info "启动 C++ 版本..."
    echo ""
    
    if [ ! -f "cpp_version/stay_awake.cpp" ]; then
        print_error "找不到 cpp_version/stay_awake.cpp"
        read -p "按 Enter 继续"
        return
    fi
    
    cd cpp_version
    
    if [ ! -f "stay_awake" ]; then
        echo "编译应用中（首次运行）..."
        g++ -O2 -o stay_awake stay_awake.cpp -std=c++17
        
        if [ $? -ne 0 ]; then
            print_error "编译失败！请确保已安装 g++"
            cd ..
            read -p "按 Enter 继续"
            return
        fi
    fi
    
    echo "运行应用..."
    ./stay_awake
    
    cd ..
}

# 编译所有版本
build_all() {
    print_info "编译所有版本..."
    echo ""
    
    mkdir -p output
    
    # 编译C++
    echo "[1/3] 编译 C++ 版本..."
    cd cpp_version
    if [ -f "stay_awake" ]; then
        rm stay_awake
    fi
    echo "  编译中..."
    g++ -O3 -march=native -o stay_awake stay_awake.cpp -std=c++17
    if [ $? -eq 0 ]; then
        cp stay_awake ../output/stay_awake_cpp
        print_success "C++ 编译成功 (stay_awake_cpp)"
    else
        print_error "C++ 编译失败"
    fi
    cd ..
    
    # 编译Python
    echo "[2/3] 编译 Python 版本..."
    if pip3 install --quiet pyinstaller 2>/dev/null; then
        cd python_version
        if pyinstaller --onefile --name stay_awake_python --distpath ../output stay_awake.py >/dev/null 2>&1; then
            print_success "Python 编译成功 (stay_awake_python)"
        else
            print_error "Python 编译失败"
        fi
        cd ..
    else
        print_warning "无法编译 Python 版本"
    fi
    
    # 编译Node.js
    echo "[3/3] 编译 Node.js 版本..."
    cd nodejs_version
    npm install --quiet 2>/dev/null
    npm install -g pkg --quiet 2>/dev/null
    if pkg . --targets node12-linux-x64 --output ../output/stay_awake_nodejs >/dev/null 2>&1; then
        print_success "Node.js 编译成功 (stay_awake_nodejs)"
    else
        print_warning "Node.js 编译失败（这可能是正常的）"
    fi
    cd ..
    
    # 显示结果
    echo ""
    echo "============================================================================"
    echo "   编译结果"
    echo "============================================================================"
    echo ""
    ls -lh output/*
    echo ""
    print_info "所有可执行文件都在 output/ 目录中"
    echo ""
    read -p "按 Enter 返回菜单"
}

# 主菜单
show_menu() {
    print_header
    
    print_info "选择要启动的版本："
    echo ""
    echo "   1. Python 版本 (命令行菜单)"
    echo "   2. Node.js 版本 (命令行菜单)"
    echo "   3. C++ 版本 (命令行菜单)"
    echo ""
    print_info "工具和配置："
    echo ""
    echo "   4. 编译所有版本"
    echo "   5. 检查环境"
    echo "   6. 打开快速启动指南"
    echo "   7. 退出"
    echo ""
    
    read -p "请输入选择 (1-7): " choice
    
    case $choice in
        1) start_python ;;
        2) start_nodejs ;;
        3) start_cpp ;;
        4) build_all ;;
        5) check_environment; read -p "按 Enter 继续" ;;
        6)
            if [ -f "QUICKSTART.md" ]; then
                if command_exists xdg-open; then
                    xdg-open QUICKSTART.md
                elif command_exists open; then
                    open QUICKSTART.md
                else
                    cat QUICKSTART.md | less
                fi
            else
                print_error "QUICKSTART.md 不存在"
                read -p "按 Enter 继续"
            fi
            ;;
        7) exit 0 ;;
        *) print_error "无效选择"; sleep 1 ;;
    esac
    
    if [ "$choice" != "7" ]; then
        show_menu
    fi
}

# 主程序
check_environment
show_menu

echo ""
echo -e "${GREEN}再见！${NC}"
