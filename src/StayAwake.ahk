; ===========================================================================================================================================================================

/*
	Stay Awake (written in AutoHotkey)

	Author ....: jNizM
	Released ..: 2021-10-21
	Modified ..: 2021-11-16
	License ...: MIT
	GitHub ....: https://github.com/jNizM/stay-awake
	Forum .....: https://www.autohotkey.com/boards/viewtopic.php?t=95857
*/


; SCRIPT DIRECTIVES =========================================================================================================================================================

#Requires AutoHotkey v2.0-

#SingleInstance
Persistent


; GLOBALS ===================================================================================================================================================================
; 全局变量定义 - 应用程序信息及资源

; 应用程序信息映射表（应用名称、版本、发布日期、作者、许可证）
app := Map("name", "Stay Awake", "version", "0.3", "release", "2021-11-16", "author", "jNizM", "licence", "MIT")

; 创建位图资源，用于GUI界面背景和装饰
; hFBFBFB: 浅灰色位图（#FBFBFB），用作主要背景色
hFBFBFB := DllCall("gdi32\CreateBitmap", "Int", 1, "Int", 1, "UInt", 0x1, "UInt", 32, "Int64*", 0xfbfbfb, "Ptr")
; hDCDCDC: 中灰色位图（#DCDCDC），用作分隔背景色
hDCDCDC := DllCall("gdi32\CreateBitmap", "Int", 1, "Int", 1, "UInt", 0x1, "UInt", 32, "Int64*", 0xdcdcdc, "Ptr")
; hHLINE: 水平线位图，用作UI分隔线
hHLINE  := DllCall("gdi32\CreateBitmap", "Int", 1, "Int", 2, "UInt", 0x1, "UInt", 32, "Int64*", 0x7fa5a5a57f5a5a5a, "Ptr")


; TRAY ======================================================================================================================================================================
; 配置系统托盘菜单和图标

; 检查Windows版本是否为10.0.22000或更高版本（Windows 11+），设置适配的托盘图标
if (VerCompare(A_OSVersion, "10.0.22000") >= 0)
	TraySetIcon("shell32.dll", 26)

; 获取主托盘菜单并清空默认菜单项
TrayMain := A_TrayMenu
TrayMain.Delete()

; 创建模式子菜单
TrayMode := Menu()
TrayMode.Add("Off (Passive)", SetPassive)               ; 被动模式：不保持系统唤醒
TrayMode.Add("Keep awake indefinitely", SetIndefinitely) ; 无限保持唤醒

; 创建临时唤醒子菜单
TrayTemp := Menu()
TrayTemp.Add("30 minutes", SetTemporarily)  ; 保持30分钟
TrayTemp.Add("1 hour",     SetTemporarily)  ; 保持1小时
TrayTemp.Add("2 hours",    SetTemporarily)  ; 保持2小时

; 将临时唤醒菜单添加到模式菜单
TrayMode.Add("Keep awake temporarily", TrayTemp)

; 构建主托盘菜单
TrayMain.Add("Mode", TrayMode)           ; 模式选择
TrayMain.Add("Keep Screen On", SetDisplayOn) ; 保持屏幕开启
TrayMain.Add()                           ; 菜单分隔符
TrayMain.Add("Open Gui", Gui_Show)       ; 打开主窗口
TrayMain.Add("Exit", ExitFunc)           ; 退出应用


; GUI =======================================================================================================================================================================
; 创建应用程序主窗口

; 创建GUI窗口对象，标题为应用名称
Main := Gui(, app["name"])
; 设置窗口边距
Main.MarginX := 15
Main.MarginY := 15

; 添加应用标题
Main.SetFont("s20 w600", "Segoe UI")   ; 字体大小20，加粗
Main.AddText("xm ym w300 0x200", app["name"])


; "启用唤醒" 部分 - 主开关控件
Main.SetFont("s10 w400", "Segoe UI")
Main.AddPicture("xm   ym+54 w352 h52 BackgroundTrans", "HBITMAP:*" hDCDCDC)  ; 背景装饰
Main.AddPicture("xm+1 ym+55 w350 h50 BackgroundTrans", "HBITMAP:*" hFBFBFB)  ; 主背景
Main.AddText("xm+16 ym+70 w240 h20 0x200 BackgroundFBFBFB", "Enable Awake") ; 标签

; 启用唤醒复选框
CB01 := Main.AddCheckBox("x+0 yp w80 h20 0x220 BackgroundFBFBFB", "Off ")
CB01.OnEvent("Click", EventCall)  ; 注册点击事件


; 行为设置部分标题
Main.SetFont("s10 w600", "Segoe UI")
Main.AddText("xm ym+130", "Behavior")

; "保持屏幕开启" 复选框控件
Main.SetFont("s10 w400", "Segoe UI")
Main.AddPicture("xm   ym+154 w352 h52 BackgroundTrans", "HBITMAP:*" hDCDCDC)  ; 背景装饰
Main.AddPicture("xm+1 ym+155 w350 h50 BackgroundTrans", "HBITMAP:*" hFBFBFB)  ; 主背景
TX01 := Main.AddText("xm+16 ym+170 w240 h20 0x200 BackgroundFBFBFB Disabled", "Keep screen on")
CB02 := Main.AddCheckBox("x+0 yp w80 h20 0x220 BackgroundFBFBFB Disabled", "Off ")
CB02.OnEvent("Click", EventCall)  ; 注册点击事件


; 模式选择部分 - 包含多个单选按钮及其说明
Main.SetFont("s10", "Segoe UI")
Main.AddPicture("xm   ym+209 w352 h252 BackgroundTrans", "HBITMAP:*" hDCDCDC)  ; 背景装饰
Main.AddPicture("xm+1 ym+210 w350 h250 BackgroundTrans", "HBITMAP:*" hFBFBFB)  ; 主背景
TX02 := Main.AddText("xm+16 ym+218 w320 h20 0x200 BackgroundFBFBFB Disabled", "Mode")

; 模式说明文本
Main.SetFont("s8 c777777", "Segoe UI")
Main.AddText("xm+16 ym+238 w320 0x200 BackgroundFBFBFB", "Set the preferred behaviour or Awake")

; 模式分隔线
Main.SetFont("s10 cDefault norm", "Segoe UI")
Main.AddPicture("xm+5 ym+260 w341 h1 BackgroundTrans", "HBITMAP:*" hHLINE)

; 三个模式选项对应的单选按钮
; RB01: 不活跃模式（默认选中）
RB01 := Main.AddRadio("xm+20 ym+272 w25 h20 BackgroundFBFBFB Checked Disabled")
RB01.OnEvent("Click", EventCall)

; RB02: 无限唤醒模式
RB02 := Main.AddRadio("xm+20 ym+317 w25 h20 BackgroundFBFBFB Disabled")
RB02.OnEvent("Click", EventCall)

; RB03: 临时唤醒模式
RB03 := Main.AddRadio("xm+20 ym+362 w25 h20 BackgroundFBFBFB Disabled")
RB03.OnEvent("Click", EventCall)

; 模式1：不活跃模式的说明
Main.SetFont("s10", "Segoe UI")
TX03 := Main.AddText("xm+45 ym+271 w280 h20 0x200 BackgroundFBFBFB Disabled", "Inactive")
Main.SetFont("s8 c777777", "Segoe UI")
Main.AddText("xm+45 ym+291 w280 h13 0x200 BackgroundFBFBFB", "Your PC operates according to its current power plan")
Main.SetFont("s10 cDefault norm", "Segoe UI")

; 模式2：无限唤醒模式的说明
TX04 := Main.AddText("xm+45 ym+316 w280 h20 0x200 BackgroundFBFBFB Disabled", "Keep awake indefinitely")
Main.SetFont("s8 c777777", "Segoe UI")
Main.AddText("xm+45 ym+336 w280 h13 0x200 BackgroundFBFBFB", "Keeps your PC awake until the setting is disabled")
Main.SetFont("s10 cDefault norm", "Segoe UI")

; 模式3：临时唤醒模式的说明
TX05 := Main.AddText("xm+45 ym+361 w280 h20 0x200 BackgroundFBFBFB Disabled", "Keep awake temporarily")
Main.SetFont("s8 c777777", "Segoe UI")
Main.AddText("xm+45 ym+381 w280 h13 0x200 BackgroundFBFBFB", "Keeps your PC awake until the set time elapses")
Main.SetFont("s10 cDefault norm", "Segoe UI")

; 临时唤醒模式的时间输入控件
TX06 := Main.AddText("xm+45 ym+402 w80 h20 0x200 BackgroundFBFBFB Disabled", "Hours")    ; 小时标签
TX07 := Main.AddText("x+5 yp w80 h20 0x200 BackgroundFBFBFB Disabled", "Minutes")  ; 分钟标签

; 小时输入框（范围0-1192小时）
ED01 := Main.AddEdit("xm+45 ym+425 w80 Limit4 0x2000 Disabled")
Main.AddUpDown("Range0-1192", 1)
ED01.OnEvent("Change", EventCall)

; 分钟输入框（范围0-71568分钟）
ED02 := Main.AddEdit("x+5 yp w80 Limit5 0x2000 Disabled")
Main.AddUpDown("Range0-71568", 0)
ED02.OnEvent("Change", EventCall)


; 注册窗口关闭事件
Main.OnEvent("Close", Gui_Hide)


; WINDOW EVENTS =============================================================================================================================================================
; 窗口事件处理函数

; 显示主窗口
Gui_Show(*)
{
	Main.Show()
}


; 隐藏主窗口
Gui_Hide(*)
{
	Main.Hide()
}


; 应用退出函数 - 清理资源
ExitFunc(*)
{
	; 释放创建的位图资源
	if (hDCDCDC)
		DllCall("gdi32\DeleteObject", "Ptr", hDCDCDC)  ; 释放中灰色位图
	if (hFBFBFB)
		DllCall("gdi32\DeleteObject", "Ptr", hFBFBFB)  ; 释放浅灰色位图
	if (hHLINE)
		DllCall("gdi32\DeleteObject", "Ptr", hHLINE)   ; 释放分隔线位图
	
	; 清理GUI窗口
	Main.Destroy()
	
	; 停止唤醒循环
	StayAwake.Stop()
	
	; 退出应用程序
	ExitApp
}


; 控件事件回调函数 - 处理所有用户交互事件
EventCall(*)
{
	; 先停止当前的唤醒循环，以便应用新的设置
	StayAwake.Stop()
	; 检查是否选择了临时唤醒模式（RB03）
	if (RB03.Value)
	{
		; 启用时间设置控件
		TX07.Opt("-Disabled")       ; 启用分钟标签
		TX06.Opt("-Disabled")       ; 启用小时标签
		ED01.Opt("-Disabled")       ; 启用小时输入框
		ED02.Opt("-Disabled")       ; 启用分钟输入框
		
		; 更新托盘菜单
		TrayMode.UnCheck("Off (Passive)")
		TrayMode.UnCheck("Keep awake indefinitely")
		TrayMode.Check("Keep awake temporarily")
		
		; 计算总时间（转换为毫秒）：(小时*3600 + 分钟*60) * 1000
		StayAwake.Period := 1000 * ((ED01.Value * 3600) + (ED02.Value * 60))
	}
	else
	{
		; 禁用时间设置控件
		TX07.Opt("+Disabled")
		TX06.Opt("+Disabled")
		ED01.Opt("+Disabled")
		ED02.Opt("+Disabled")
		TrayMode.UnCheck("Keep awake temporarily")
	}
	
	; 检查是否选择了无限唤醒模式（RB02）
	if (RB02.Value)
	{
		; 更新托盘菜单
		TrayMode.UnCheck("Off (Passive)")
		TrayMode.Check("Keep awake indefinitely")
		TrayMode.UnCheck("Keep awake temporarily")
		
		; 设置周期为0表示无限唤醒
		StayAwake.Period := 0
	}
	else
	{
		TrayMode.Uncheck("Keep awake indefinitely")
	}
	
	; 检查是否选择了不活跃模式（RB01）
	if (RB01.Value)
	{
		; 更新托盘菜单
		TrayMode.Check("Off (Passive)")
		TrayMode.UnCheck("Keep awake indefinitely")
		TrayMode.UnCheck("Keep awake temporarily")
		
		; 设置周期为-1表示不活跃模式（停止唤醒）
		StayAwake.Period := -1
	}
	else
	{
		TrayMode.UnCheck("Off (Passive)")
	}
	
	; 检查是否启用了"保持屏幕开启"选项（CB02）
	if (CB02.Value)
	{
		CB02.Text := "On "                           ; 更新复选框显示
		TrayMain.Check("Keep Screen On")              ; 更新托盘菜单
		StayAwake.Flags := "DisplayOn"               ; 设置标志以保持屏幕开启
	}
	else
	{
		CB02.Text := "Off "                          ; 更新复选框显示
		TrayMain.UnCheck("Keep Screen On")           ; 更新托盘菜单
		StayAwake.Flags := ""                        ; 清除标志
	}
	
	; 检查是否启用了主开关"Enable Awake"（CB01）
	if (CB01.Value)
	{
		; 启用模式
		CB01.Text := "On "                          ; 更新复选框显示
		
		; 启用所有相关控件
		TX05.Opt("-Disabled")                        ; 启用临时模式说明
		TX04.Opt("-Disabled")                        ; 启用无限模式说明
		TX03.Opt("-Disabled")                        ; 启用不活跃模式说明
		TX02.Opt("-Disabled")                        ; 启用模式标题
		TX01.Opt("-Disabled")                        ; 启用屏幕保持说明
		RB03.Opt("-Disabled")                        ; 启用临时模式单选按钮
		RB02.Opt("-Disabled")                        ; 启用无限模式单选按钮
		RB01.Opt("-Disabled")                        ; 启用不活跃模式单选按钮
		CB02.Opt("-Disabled")                        ; 启用屏幕保持复选框
		
		; 启动唤醒循环
		StayAwake.Start()
	}
	else
	{
		; 禁用模式
		CB01.Text := "Off "                         ; 更新复选框显示
		
		; 禁用所有相关控件
		TX07.Opt("+Disabled")                        ; 禁用分钟标签
		TX06.Opt("+Disabled")                        ; 禁用小时标签
		TX05.Opt("+Disabled")                        ; 禁用临时模式说明
		TX04.Opt("+Disabled")                        ; 禁用无限模式说明
		TX03.Opt("+Disabled")                        ; 禁用不活跃模式说明
		TX02.Opt("+Disabled")                        ; 禁用模式标题
		TX01.Opt("+Disabled")                        ; 禁用屏幕保持说明
		ED01.Opt("+Disabled")                        ; 禁用小时输入框
		ED02.Opt("+Disabled")                        ; 禁用分钟输入框
		RB03.Opt("+Disabled")                        ; 禁用临时模式单选按钮
		RB02.Opt("+Disabled")                        ; 禁用无限模式单选按钮
		RB01.Opt("+Disabled")                        ; 禁用不活跃模式单选按钮
		CB02.Opt("+Disabled")                        ; 禁用屏幕保持复选框
		
		; 清除托盘菜单中的所有检查标记
		TrayMode.UnCheck("Off (Passive)")
		TrayMode.UnCheck("Keep awake indefinitely")
		TrayMode.UnCheck("Keep awake temporarily")
		
		; 停止唤醒循环
		StayAwake.Stop()
	}
}


; FUNCTIONS =================================================================================================================================================================
; 菜单回调函数 - 处理托盘菜单事件

; 设置为被动模式（不保持唤醒）
SetPassive(ItemName, ItemPos, *)
{
	; 切换菜单项的检查状态
	TrayMode.ToggleCheck(ItemName)

	; 获取当前菜单项的状态
	if (MenuCheckState(TrayMode.Handle, ItemPos))
	{
		; 如果被检查，更新GUI控件为被动模式
		CB01.Value := 1               ; 启用主开关
		RB01.Value := 1               ; 选择被动模式
		RB02.Value := 0               ; 取消选择无限模式
		RB03.Value := 0               ; 取消选择临时模式
	}
	else
	{
		; 如果未被检查，取消选择被动模式
		RB01.Value := 0
	}
	
	; 触发事件回调以应用改变
	EventCall()
}


; 设置为无限唤醒模式
SetIndefinitely(ItemName, ItemPos, *)
{
	; 取消检查临时模式，以避免冲突
	TrayMode.Uncheck("Keep awake temporarily")
	; 切换无限模式的检查状态
	TrayMode.ToggleCheck(ItemName)

	; 获取当前菜单项的状态
	if (MenuCheckState(TrayMode.Handle, ItemPos))
	{
		; 如果被检查，更新GUI控件为无限模式
		CB01.Value := 1               ; 启用主开关
		RB01.Value := 0               ; 取消选择被动模式
		RB02.Value := 1               ; 选择无限模式
		RB03.Value := 0               ; 取消选择临时模式
	}
	else
	{
		; 如果未被检查，取消选择无限模式
		RB02.Value := 0
	}
	
	; 触发事件回调以应用改变
	EventCall()
}


; 设置为临时唤醒模式
SetTemporarily(ItemName, ItemPos, *)
{
	; 取消检查无限模式，以避免冲突
	TrayMode.Uncheck("Keep awake indefinitely")
	; 切换临时唤醒模式的检查状态
	TrayMode.ToggleCheck("Keep awake temporarily")
	
	; 计算"Keep awake temporarily"菜单项的位置
	ModePos := ItemPos - ((ItemName = "30 minutes") ? 1 : (ItemName = "1 hour") ? 2 : 3)

	; 获取"Keep awake temporarily"菜单项的检查状态
	if (MenuCheckState(TrayMode.Handle, ModePos))
	{
		; 如果被检查，更新GUI控件为临时模式
		CB01.Value := 1               ; 启用主开关
		RB01.Value := 0               ; 取消选择被动模式
		RB02.Value := 0               ; 取消选择无限模式
		RB03.Value := 1               ; 选择临时模式
		
		; 根据选择的菜单项设置时间
		if (ItemName = "30 minutes")
		{
			ED01.Value := 0               ; 小时设为0
			ED02.Value := 30              ; 分钟设为30
		}
		if (ItemName = "1 hour")
		{
			ED01.Value := 1               ; 小时设为1
			ED02.Value := 0               ; 分钟设为0
		}
		if (ItemName = "2 hours")
		{
			ED01.Value := 2               ; 小时设为2
			ED02.Value := 0               ; 分钟设为0
		}
	}
	else
	{
		; 如果未被检查，取消选择临时模式
		RB03.Value := 0
	}
	
	; 触发事件回调以应用改变
	EventCall()
}


; 设置是否保持屏幕开启
SetDisplayOn(ItemName, ItemPos, *)
{
	; 切换菜单项的检查状态
	TrayMain.ToggleCheck(ItemName)

	; 获取当前菜单项的状态
	if (MenuCheckState(TrayMain.Handle, ItemPos))
	{
		; 如果被检查，启用屏幕保持复选框
		CB02.Value := 1
	}
	else
	{
		; 如果未被检查，禁用屏幕保持复选框
		CB02.Value := 0
	}
	
	; 触发事件回调以应用改变
	EventCall()
}


; 获取菜单项的检查状态
; 参数: Handle - 菜单句柄, Item - 菜单项索引
; 返回: 1表示已检查, 0表示未检查, -1表示错误
MenuCheckState(Handle, Item)
{
	; 定义Windows API常量
	static MF_BYPOSITION := 0x00000400  ; 按位置识别菜单项
	static MF_CHECKED    := 0x00000008  ; 菜单项已检查标志位

	; 调用Windows API获取菜单项状态
	MenuState := DllCall("user32\GetMenuState", "Ptr", Handle, "UInt", Item - 1, "UInt", MF_BYPOSITION, "UInt")
	
	; 检查API调用是否失败
	if (MenuState = -1)
		return -1
	
	; 返回菜单项是否被检查（检查状态标志位）
	return !!(MenuState & MF_CHECKED)
}


; CLASS =====================================================================================================================================================================
; StayAwake类 - 核心功能类，控制系统唤醒状态

class StayAwake
{
	; 静态变量
	static Timer  := 0      ; 计时器句柄，用于周期性更新唤醒状态
	static Period := 0      ; 唤醒周期（毫秒），0表示无限，-1表示禁用
	static Flags  := ""     ; 唤醒标志，控制具体的唤醒行为


	; 属性定义 - 允许外部代码设置Flags和Period
	
	; Flags属性 - 设置唤醒标志
	Flags[Flags]
	{
		set => Flags    ; 允许设置Flags值
	}

	; Period属性 - 设置唤醒周期
	Period[Period]
	{
		set => Period   ; 允许设置Period值
	}


	; 注释掉的方法：计算剩余时间
	; static TimeLeft() => (this.StartTime + this.Period) - A_TickCount


	; 启动唤醒循环
	static Start()
	{
		; 创建并启动周期性计时器，每60秒调用一次RunLoop方法
		this.Timer := Timer := this.RunLoop.bind(this)
		SetTimer Timer, 60000    ; 60000毫秒 = 60秒

		; 如果设置了有限的唤醒时间（Period > 0）
		if (this.Period > 0)
		{
			; 创建一次性计时器，在指定时间后调用Stop方法
			this.RunOnce := RunOnce := this.Stop.bind(this)
			this.StartTime := A_TickCount                ; 记录启动时间
			SetTimer RunOnce, - this.Period             ; 负数表示一次性执行
		}
	}


	; 停止唤醒循环
	static Stop()
	{
		; 设置执行状态为CONTINUOUS，允许系统正常进入睡眠
		this.SetState(this.EXECUTION_STATE.CONTINUOUS)
		
		; 停止周期性计时器
		if (Timer := this.Timer)
			SetTimer Timer, 0      ; 0表示停止计时器
	}


	; 周期性执行循环 - 定期更新系统唤醒状态
	static RunLoop()
	{
		; 根据不同的标志设置不同的执行状态
		switch this.Flags
		{
			; 保持屏幕开启模式
			case "DisplayOn":
				; 设置系统持续运行、系统必需、屏幕必需
				this.SetState(this.EXECUTION_STATE.CONTINUOUS | this.EXECUTION_STATE.SYSTEM_REQUIRED | this.EXECUTION_STATE.DISPLAY_REQUIRED)
			
			; 离开模式（当前未使用）
			case "AwayMode":
				; 设置系统持续运行、系统必需、离开模式必需
				this.SetState(this.EXECUTION_STATE.CONTINUOUS | this.EXECUTION_STATE.SYSTEM_REQUIRED | this.EXECUTION_STATE.AWAYMODE_REQUIRED)
			
			; 默认模式 - 只保持系统唤醒，允许屏幕关闭
			default:
				; 设置系统持续运行、系统必需
				this.SetState(this.EXECUTION_STATE.CONTINUOUS | this.EXECUTION_STATE.SYSTEM_REQUIRED)
		}
	}


	; 设置线程执行状态 - 调用Windows API来控制系统唤醒
	static SetState(State)
	{
		try
		{
			; 调用Windows API SetThreadExecutionState来改变系统执行状态
			; 返回值不为0表示成功
			if (EXECUTION_STATE := DllCall("kernel32\SetThreadExecutionState", "UInt", State) != 0)
				return EXECUTION_STATE   ; 返回新的执行状态
		}
		catch
		{
			; 如果API调用失败，抛出错误
			throw Error("SetThreadExecutionState failed", -1)
		}
	}


	; 嵌套类 - Windows执行状态常量
	; 参考: https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-setthreadexecutionstate
	class EXECUTION_STATE
	{
		; 离开模式必需（用户不在计算机前）
		static AWAYMODE_REQUIRED := 0x00000040
		
		; 持续执行状态（重置系统空闲计时器）
		static CONTINUOUS        := 0x80000000
		
		; 显示必需（屏幕保持开启）
		static DISPLAY_REQUIRED  := 0x00000002
		
		; 系统必需（系统保持唤醒，不进入睡眠）
		static SYSTEM_REQUIRED   := 0x00000001
	}
}


; ===========================================================================================================================================================================
