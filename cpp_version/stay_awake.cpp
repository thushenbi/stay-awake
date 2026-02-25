/**
 * Stay Awake - C++ 版本
 * 防止系统进入休眠状态
 * 
 * Author: C++ Implementation
 * License: MIT
 * 
 * 编译: g++ -o stay_awake.exe stay_awake.cpp -std=c++17
 * 或使用 Visual Studio 创建 Win32 控制台应用
 */

#include <windows.h>
#include <iostream>
#include <thread>
#include <chrono>
#include <atomic>
#include <string>
#include <conio.h>

using namespace std;

/**
 * Windows API 执行状态常量
 */
enum class ExecutionState : DWORD {
    AWAYMODE_REQUIRED = 0x00000040,   // 离开模式必需
    CONTINUOUS = 0x80000000,          // 持续执行状态
    DISPLAY_REQUIRED = 0x00000002,    // 显示必需（屏幕保持开启）
    SYSTEM_REQUIRED = 0x00000001      // 系统必需（保持唤醒）
};

/**
 * 核心功能类 - 控制系统唤醒状态
 */
class StayAwake {
private:
    atomic<bool> running{ false };
    DWORD period = 0;                  // 唤醒周期（毫秒）
    string flags = "";                 // 唤醒标志
    DWORD start_time = 0;
    thread timer_thread;
    
public:
    StayAwake() = default;
    
    /**
     * 设置线程执行状态 - 调用 Windows API
     */
    bool SetState(ExecutionState state) {
        try {
            DWORD result = SetThreadExecutionState(static_cast<DWORD>(state));
            if (result == 0) {
                cerr << "❌ SetThreadExecutionState 失败" << endl;
                return false;
            }
            return true;
        }
        catch (const exception& e) {
            cerr << "❌ 错误: " << e.what() << endl;
            return false;
        }
    }
    
    /**
     * 周期性执行循环 - 定期更新系统唤醒状态
     */
    void RunLoop() {
        ExecutionState state;
        
        // 根据标志选择执行状态
        if (flags == "DisplayOn") {
            // 保持屏幕开启模式
            state = static_cast<ExecutionState>(
                static_cast<DWORD>(ExecutionState::CONTINUOUS) |
                static_cast<DWORD>(ExecutionState::SYSTEM_REQUIRED) |
                static_cast<DWORD>(ExecutionState::DISPLAY_REQUIRED)
            );
        }
        else if (flags == "AwayMode") {
            // 离开模式（当前未使用）
            state = static_cast<ExecutionState>(
                static_cast<DWORD>(ExecutionState::CONTINUOUS) |
                static_cast<DWORD>(ExecutionState::SYSTEM_REQUIRED) |
                static_cast<DWORD>(ExecutionState::AWAYMODE_REQUIRED)
            );
        }
        else {
            // 默认模式 - 只保持系统唤醒，允许屏幕关闭
            state = static_cast<ExecutionState>(
                static_cast<DWORD>(ExecutionState::CONTINUOUS) |
                static_cast<DWORD>(ExecutionState::SYSTEM_REQUIRED)
            );
        }
        
        SetState(state);
    }
    
    /**
     * 后台计时器线程
     */
    void TimerLoop() {
        while (running) {
            try {
                RunLoop();
                this_thread::sleep_for(chrono::seconds(60));
            }
            catch (const exception& e) {
                cerr << "⚠️  计时器错误: " << e.what() << endl;
                break;
            }
        }
        
        // 线程退出时恢复正常状态
        SetState(ExecutionState::CONTINUOUS);
    }
    
public:
    /**
     * 启动唤醒循环
     */
    void Start() {
        if (running) {
            cout << "⚠️  已经在运行中" << endl;
            return;
        }
        
        running = true;
        
        // 启动后台计时器线程
        timer_thread = thread(&StayAwake::TimerLoop, this);
        timer_thread.detach();  // 分离线程，让其独立运行
        
        // 如果设置了有限的唤醒时间
        if (period > 0) {
            start_time = GetTickCount();
            // 启动临时计时器
            thread stop_timer([this]() {
                DWORD elapsed = 0;
                while (running && elapsed < this->period) {
                    this_thread::sleep_for(chrono::milliseconds(100));
                    elapsed = GetTickCount() - this->start_time;
                }
                if (running) {
                    this->Stop();
                }
            });
            stop_timer.detach();
        }
        
        cout << "✅ Stay Awake 已启动 (周期: " << period << "ms, 标志: " 
             << (flags.empty() ? "默认" : flags) << ")" << endl;
    }
    
    /**
     * 停止唤醒循环
     */
    void Stop() {
        if (!running) {
            return;
        }
        
        running = false;
        
        // 恢复系统正常状态
        SetState(ExecutionState::CONTINUOUS);
        
        cout << "⏹️  Stay Awake 已停止" << endl;
    }
    
    /**
     * 检查是否正在运行
     */
    bool IsRunning() const {
        return running;
    }
    
    /**
     * 设置周期
     */
    void SetPeriod(DWORD ms) {
        period = ms;
    }
    
    /**
     * 设置标志
     */
    void SetFlags(const string& new_flags) {
        flags = new_flags;
    }
    
    /**
     * 获取标志
     */
    string GetFlags() const {
        return flags;
    }
};

/**
 * 应用程序主类
 */
class StayAwakeApp {
private:
    StayAwake awake;
    string mode = "passive";  // passive, indefinite, temporary
    
public:
    /**
     * 显示主菜单
     */
    void ShowMenu() {
        system("cls");  // 清屏
        cout << "\n" << string(50, '=') << endl;
        cout << "         🌙 Stay Awake - C++ 版本" << endl;
        cout << string(50, '=') << endl;
        cout << "\n当前状态: " << (awake.IsRunning() ? "已启用" : "已禁用") << endl;
        cout << "当前模式: " << GetModeName() << endl;
        cout << "屏幕保持: " << (awake.GetFlags() == "DisplayOn" ? "开启" : "关闭") << endl;
        cout << "\n---- 主菜单 ----" << endl;
        cout << "1. 切换启用/禁用" << endl;
        cout << "2. 选择模式" << endl;
        cout << "   a) 被动模式（不保持唤醒）" << endl;
        cout << "   b) 无限保持唤醒" << endl;
        cout << "   c) 临时保持唤醒" << endl;
        cout << "3. 保持屏幕开启" << endl;
        cout << "4. 退出应用" << endl;
        cout << string(50, '-') << endl;
    }
    
    /**
     * 获取当前模式名称
     */
    string GetModeName() const {
        if (mode == "passive") return "被动模式";
        if (mode == "indefinite") return "无限保持";
        if (mode == "temporary") return "临时保持";
        return "未知";
    }
    
    /**
     * 设置临时保持模式
     */
    void SetModeTemporary() {
        try {
            int hours, minutes;
            cout << "输入小时数 (0-1192): ";
            if (!(cin >> hours)) {
                cin.clear();
                cin.ignore(10000, '\n');
                hours = 1;
            }
            
            cout << "输入分钟数 (0-71568): ";
            if (!(cin >> minutes)) {
                cin.clear();
                cin.ignore(10000, '\n');
                minutes = 0;
            }
            cin.ignore();  // 清除缓冲区中的换行符
            
            if (!(0 <= hours && hours <= 1192 && 0 <= minutes && minutes <= 71568)) {
                cout << "❌ 输入超出范围" << endl;
                return;
            }
            
            DWORD total_ms = (hours * 3600 + minutes * 60) * 1000;
            awake.SetPeriod(total_ms);
            mode = "temporary";
            StartAwake();
        }
        catch (const exception& e) {
            cerr << "❌ 输入无效: " << e.what() << endl;
        }
    }
    
    /**
     * 启动保持唤醒
     */
    void StartAwake() {
        if (mode == "passive") {
            awake.Stop();
            awake.SetPeriod(-1);
        }
        else if (mode == "indefinite") {
            awake.SetPeriod(0);
            cout << "保持屏幕开启? (y/n): ";
            char choice;
            cin >> choice;
            cin.ignore();
            awake.SetFlags(choice == 'y' || choice == 'Y' ? "DisplayOn" : "");
            awake.Start();
        }
        else if (mode == "temporary") {
            cout << "保持屏幕开启? (y/n): ";
            char choice;
            cin >> choice;
            cin.ignore();
            awake.SetFlags(choice == 'y' || choice == 'Y' ? "DisplayOn" : "");
            awake.Start();
        }
    }
    
    /**
     * 运行应用
     */
    void Run() {
        cout << "\n🚀 Stay Awake 应用已启动" << endl;
        
        bool running = true;
        while (running) {
            ShowMenu();
            cout << "请选择 (1-4): ";
            
            char choice;
            cin >> choice;
            cin.ignore();  // 清除缓冲区中的换行符
            
            switch (choice) {
                case '1':
                    if (awake.IsRunning()) {
                        awake.Stop();
                    }
                    else {
                        StartAwake();
                    }
                    break;
                
                case '2': {
                    cout << "\n选择模式:" << endl;
                    cout << "a) 被动模式（不保持唤醒）" << endl;
                    cout << "b) 无限保持唤醒" << endl;
                    cout << "c) 临时保持唤醒" << endl;
                    cout << "请选择 (a/b/c): ";
                    
                    char mode_choice;
                    cin >> mode_choice;
                    cin.ignore();
                    
                    if (mode_choice == 'a') {
                        mode = "passive";
                        awake.Stop();
                    }
                    else if (mode_choice == 'b') {
                        mode = "indefinite";
                        StartAwake();
                    }
                    else if (mode_choice == 'c') {
                        mode = "temporary";
                        SetModeTemporary();
                    }
                    break;
                }
                
                case '3':
                    if (awake.IsRunning()) {
                        string new_flags = awake.GetFlags() == "DisplayOn" ? "" : "DisplayOn";
                        awake.SetFlags(new_flags);
                        cout << "✅ 屏幕保持: " << (new_flags == "DisplayOn" ? "开启" : "关闭") << endl;
                    }
                    else {
                        cout << "⚠️  请先启用 Stay Awake" << endl;
                    }
                    break;
                
                case '4':
                    cout << "\n👋 正在退出..." << endl;
                    awake.Stop();
                    running = false;
                    break;
                
                default:
                    cout << "❌ 无效选择" << endl;
            }
            
            if (running) {
                cout << "\n按 Enter 继续...";
                cin.get();
            }
        }
    }
};

/**
 * 主函数
 */
int main() {
    try {
        // 设置控制台编码为UTF-8
        SetConsoleCP(CP_UTF8);
        SetConsoleOutputCP(CP_UTF8);
        
        StayAwakeApp app;
        app.Run();
    }
    catch (const exception& e) {
        cerr << "❌ 应用错误: " << e.what() << endl;
        return 1;
    }
    
    return 0;
}
