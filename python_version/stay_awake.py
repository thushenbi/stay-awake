#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Stay Awake - Python 版本
防止系统进入休眠状态

Author: Python Implementation
License: MIT
"""

import ctypes
import threading
import time
import sys
from enum import IntFlag
from typing import Optional

# Windows API 常量
class ExecutionState(IntFlag):
    """Windows 线程执行状态常量"""
    AWAYMODE_REQUIRED = 0x00000040  # 离开模式必需
    CONTINUOUS = 0x80000000        # 持续执行状态
    DISPLAY_REQUIRED = 0x00000002  # 显示必需（屏幕保持开启）
    SYSTEM_REQUIRED = 0x00000001   # 系统必需（保持唤醒）


class StayAwake:
    """
    核心功能类 - 控制系统唤醒状态
    """
    
    def __init__(self):
        """初始化 Stay Awake 实例"""
        self.kernel32 = ctypes.windll.kernel32
        self.timer_thread: Optional[threading.Thread] = None
        self.running = False
        self.period = 0  # 唤醒周期（毫秒），0表示无限，-1表示禁用
        self.flags = ""  # 唤醒标志
        self.start_time = 0
    
    def set_state(self, state: ExecutionState) -> int:
        """
        设置线程执行状态 - 调用 Windows API
        
        Args:
            state: 执行状态标志
            
        Returns:
            新的执行状态，失败则为0
        """
        try:
            result = self.kernel32.SetThreadExecutionState(state)
            if result == 0:
                raise RuntimeError("SetThreadExecutionState failed")
            return result
        except Exception as e:
            print(f"❌ 错误: {e}")
            return 0
    
    def run_loop(self):
        """周期性执行循环 - 定期更新系统唤醒状态"""
        # 根据标志选择执行状态
        if self.flags == "DisplayOn":
            # 保持屏幕开启模式
            state = (ExecutionState.CONTINUOUS | 
                    ExecutionState.SYSTEM_REQUIRED | 
                    ExecutionState.DISPLAY_REQUIRED)
        elif self.flags == "AwayMode":
            # 离开模式（当前未使用）
            state = (ExecutionState.CONTINUOUS | 
                    ExecutionState.SYSTEM_REQUIRED | 
                    ExecutionState.AWAYMODE_REQUIRED)
        else:
            # 默认模式 - 只保持系统唤醒，允许屏幕关闭
            state = (ExecutionState.CONTINUOUS | 
                    ExecutionState.SYSTEM_REQUIRED)
        
        self.set_state(state)
    
    def timer_loop(self):
        """后台计时器线程"""
        while self.running:
            try:
                self.run_loop()
                time.sleep(60)  # 60秒更新一次
            except Exception as e:
                print(f"⚠️ 计时器错误: {e}")
                break
        
        # 线程退出时恢复正常状态
        self.set_state(ExecutionState.CONTINUOUS)
    
    def start(self):
        """启动唤醒循环"""
        if self.running:
            print("⚠️ 已经在运行中")
            return
        
        self.running = True
        
        # 启动后台计时器线程
        self.timer_thread = threading.Thread(target=self.timer_loop, daemon=True)
        self.timer_thread.start()
        
        # 如果设置了有限的唤醒时间
        if self.period > 0:
            self.start_time = time.time()
            # 启动一次性计时器，在指定时间后停止
            def stop_after_period():
                time.sleep(self.period / 1000)  # 转换为秒
                self.stop()
            
            timer = threading.Timer(self.period / 1000, stop_after_period)
            timer.daemon = True
            timer.start()
        
        print(f"✅ Stay Awake 已启动 (周期: {self.period}ms, 标志: {self.flags})")
    
    def stop(self):
        """停止唤醒循环"""
        if not self.running:
            return
        
        self.running = False
        
        # 恢复系统正常状态
        self.set_state(ExecutionState.CONTINUOUS)
        
        print("⏹️  Stay Awake 已停止")


class StayAwakeApp:
    """应用程序主类 - 处理菜单和用户交互"""
    
    def __init__(self):
        """初始化应用"""
        self.awake = StayAwake()
        self.mode = "passive"  # passive, indefinite, temporary
    
    def show_menu(self):
        """显示主菜单"""
        print("\n" + "="*50)
        print("         🌙 Stay Awake - Python 版本")
        print("="*50)
        print(f"\n当前状态: {'已启用' if self.awake.running else '已禁用'}")
        print(f"当前模式: {self.get_mode_name()}")
        print(f"屏幕保持: {'开启' if self.awake.flags == 'DisplayOn' else '关闭'}")
        print("\n---- 主菜单 ----")
        print("1. 切换启用/禁用")
        print("2. 选择模式")
        print("   a) 被动模式（不保持唤醒）")
        print("   b) 无限保持唤醒")
        print("   c) 临时保持唤醒")
        print("3. 保持屏幕开启")
        print("4. 退出应用")
        print("-" * 50)
    
    def get_mode_name(self) -> str:
        """获取当前模式名称"""
        modes = {
            "passive": "被动模式",
            "indefinite": "无限保持",
            "temporary": "临时保持"
        }
        return modes.get(self.mode, "未知")
    
    def set_mode_temporary(self):
        """设置临时保持模式"""
        try:
            hours = int(input("输入小时数 (0-1192): ") or "1")
            minutes = int(input("输入分钟数 (0-71568): ") or "0")
            
            if not (0 <= hours <= 1192 and 0 <= minutes <= 71568):
                print("❌ 输入超出范围")
                return
            
            total_seconds = hours * 3600 + minutes * 60
            self.awake.period = total_seconds * 1000  # 转换为毫秒
            self.mode = "temporary"
            self.start_awake()
        except ValueError:
            print("❌ 输入无效")
    
    def start_awake(self):
        """启动保持唤醒"""
        if self.mode == "passive":
            self.awake.stop()
            self.awake.period = -1
        elif self.mode == "indefinite":
            self.awake.period = 0
            self.awake.flags = "DisplayOn" if input("保持屏幕开启? (y/n): ").lower() == 'y' else ""
            self.awake.start()
        elif self.mode == "temporary":
            self.awake.flags = "DisplayOn" if input("保持屏幕开启? (y/n): ").lower() == 'y' else ""
            self.awake.start()
    
    def run(self):
        """运行应用"""
        print("\n🚀 Stay Awake 应用已启动")
        
        while True:
            self.show_menu()
            choice = input("请选择 (1-4): ").strip()
            
            if choice == "1":
                if self.awake.running:
                    self.awake.stop()
                else:
                    self.start_awake()
            
            elif choice == "2":
                print("\n选择模式:")
                print("a) 被动模式（不保持唤醒）")
                print("b) 无限保持唤醒")
                print("c) 临时保持唤醒")
                mode_choice = input("请选择 (a/b/c): ").strip().lower()
                
                if mode_choice == "a":
                    self.mode = "passive"
                    self.awake.stop()
                elif mode_choice == "b":
                    self.mode = "indefinite"
                    self.start_awake()
                elif mode_choice == "c":
                    self.mode = "temporary"
                    self.set_mode_temporary()
            
            elif choice == "3":
                if self.awake.running:
                    self.awake.flags = "" if self.awake.flags == "DisplayOn" else "DisplayOn"
                    print(f"✅ 屏幕保持: {'开启' if self.awake.flags == 'DisplayOn' else '关闭'}")
                else:
                    print("⚠️ 请先启用 Stay Awake")
            
            elif choice == "4":
                print("\n👋 正在退出...")
                self.awake.stop()
                break
            
            else:
                print("❌ 无效选择")


def main():
    """主函数"""
    try:
        app = StayAwakeApp()
        app.run()
    except KeyboardInterrupt:
        print("\n\n🛑 应用被中断")
    except Exception as e:
        print(f"\n❌ 应用错误: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
