/**
 * Stay Awake - Node.js 版本
 * 防止系统进入休眠状态
 * 
 * Author: JavaScript Implementation
 * License: MIT
 * 
 * 依赖: npm install ffi-napi ref-napi
 */

const ffi = require('ffi-napi');
const ref = require('ref-napi');
const readline = require('readline');
const EventEmitter = require('events');

/**
 * Windows API 执行状态常量
 */
const EXECUTION_STATE = {
    AWAYMODE_REQUIRED: 0x00000040,  // 离开模式必需
    CONTINUOUS: 0x80000000,         // 持续执行状态
    DISPLAY_REQUIRED: 0x00000002,   // 显示必需（屏幕保持开启）
    SYSTEM_REQUIRED: 0x00000001     // 系统必需（保持唤醒）
};

/**
 * 核心功能类 - 控制系统唤醒状态
 */
class StayAwake extends EventEmitter {
    constructor() {
        super();
        
        // 加载 kernel32.dll 并定义 SetThreadExecutionState 函数
        try {
            this.kernel32 = ffi.Library('kernel32', {
                SetThreadExecutionState: ['uint', ['uint']]
            });
        } catch (error) {
            console.error('❌ 无法加载 kernel32.dll:', error.message);
            process.exit(1);
        }
        
        this.running = false;
        this.period = 0;        // 唤醒周期（毫秒）
        this.flags = '';        // 唤醒标志
        this.timerInterval = null;
        this.stopTimer = null;
    }
    
    /**
     * 设置线程执行状态 - 调用 Windows API
     * @param {number} state - 执行状态标志
     * @returns {boolean} 成功返回 true
     */
    setState(state) {
        try {
            const result = this.kernel32.SetThreadExecutionState(state);
            if (result === 0) {
                throw new Error('SetThreadExecutionState failed');
            }
            return true;
        } catch (error) {
            console.error('❌ 错误:', error.message);
            return false;
        }
    }
    
    /**
     * 周期性执行循环 - 定期更新系统唤醒状态
     */
    runLoop() {
        let state;
        
        // 根据标志选择执行状态
        if (this.flags === 'DisplayOn') {
            // 保持屏幕开启模式
            state = EXECUTION_STATE.CONTINUOUS | 
                    EXECUTION_STATE.SYSTEM_REQUIRED | 
                    EXECUTION_STATE.DISPLAY_REQUIRED;
        } else if (this.flags === 'AwayMode') {
            // 离开模式（当前未使用）
            state = EXECUTION_STATE.CONTINUOUS | 
                    EXECUTION_STATE.SYSTEM_REQUIRED | 
                    EXECUTION_STATE.AWAYMODE_REQUIRED;
        } else {
            // 默认模式 - 只保持系统唤醒，允许屏幕关闭
            state = EXECUTION_STATE.CONTINUOUS | 
                    EXECUTION_STATE.SYSTEM_REQUIRED;
        }
        
        this.setState(state);
    }
    
    /**
     * 启动唤醒循环
     */
    start() {
        if (this.running) {
            console.log('⚠️  已经在运行中');
            return;
        }
        
        this.running = true;
        
        // 启动周期性计时器（每60秒运行一次）
        this.timerInterval = setInterval(() => this.runLoop(), 60000);
        
        // 立即执行一次
        this.runLoop();
        
        // 如果设置了有限的唤醒时间
        if (this.period > 0) {
            this.stopTimer = setTimeout(() => this.stop(), this.period);
        }
        
        console.log(`✅ Stay Awake 已启动 (周期: ${this.period}ms, 标志: ${this.flags})`);
        this.emit('started');
    }
    
    /**
     * 停止唤醒循环
     */
    stop() {
        if (!this.running) {
            return;
        }
        
        this.running = false;
        
        // 清理计时器
        if (this.timerInterval) {
            clearInterval(this.timerInterval);
            this.timerInterval = null;
        }
        
        if (this.stopTimer) {
            clearTimeout(this.stopTimer);
            this.stopTimer = null;
        }
        
        // 恢复系统正常状态
        this.setState(EXECUTION_STATE.CONTINUOUS);
        
        console.log('⏹️  Stay Awake 已停止');
        this.emit('stopped');
    }
}

/**
 * 应用程序主类 - 处理菜单和用户交互
 */
class StayAwakeApp {
    constructor() {
        this.awake = new StayAwake();
        this.mode = 'passive';  // passive, indefinite, temporary
        this.rl = readline.createInterface({
            input: process.stdin,
            output: process.stdout
        });
    }
    
    /**
     * 显示主菜单
     */
    showMenu() {
        console.clear();
        console.log('\n' + '='.repeat(50));
        console.log('         🌙 Stay Awake - Node.js 版本');
        console.log('='.repeat(50));
        console.log(`\n当前状态: ${this.awake.running ? '已启用' : '已禁用'}`);
        console.log(`当前模式: ${this.getModeName()}`);
        console.log(`屏幕保持: ${this.awake.flags === 'DisplayOn' ? '开启' : '关闭'}`);
        console.log('\n---- 主菜单 ----');
        console.log('1. 切换启用/禁用');
        console.log('2. 选择模式');
        console.log('   a) 被动模式（不保持唤醒）');
        console.log('   b) 无限保持唤醒');
        console.log('   c) 临时保持唤醒');
        console.log('3. 保持屏幕开启');
        console.log('4. 退出应用');
        console.log('-'.repeat(50));
    }
    
    /**
     * 获取当前模式名称
     */
    getModeName() {
        const modes = {
            'passive': '被动模式',
            'indefinite': '无限保持',
            'temporary': '临时保持'
        };
        return modes[this.mode] || '未知';
    }
    
    /**
     * 提示用户输入
     */
    prompt(question) {
        return new Promise(resolve => {
            this.rl.question(question, answer => {
                resolve(answer.trim());
            });
        });
    }
    
    /**
     * 设置临时保持模式
     */
    async setModeTemporary() {
        try {
            const hours = parseInt(await this.prompt('输入小时数 (0-1192): '), 10) || 1;
            const minutes = parseInt(await this.prompt('输入分钟数 (0-71568): '), 10) || 0;
            
            if (!(0 <= hours && hours <= 1192 && 0 <= minutes && minutes <= 71568)) {
                console.log('❌ 输入超出范围');
                return;
            }
            
            const totalSeconds = hours * 3600 + minutes * 60;
            this.awake.period = totalSeconds * 1000;  // 转换为毫秒
            this.mode = 'temporary';
            await this.startAwake();
        } catch (error) {
            console.log('❌ 输入无效');
        }
    }
    
    /**
     * 启动保持唤醒
     */
    async startAwake() {
        if (this.mode === 'passive') {
            this.awake.stop();
            this.awake.period = -1;
        } else if (this.mode === 'indefinite') {
            this.awake.period = 0;
            const keepScreen = await this.prompt('保持屏幕开启? (y/n): ');
            this.awake.flags = keepScreen.toLowerCase() === 'y' ? 'DisplayOn' : '';
            this.awake.start();
        } else if (this.mode === 'temporary') {
            const keepScreen = await this.prompt('保持屏幕开启? (y/n): ');
            this.awake.flags = keepScreen.toLowerCase() === 'y' ? 'DisplayOn' : '';
            this.awake.start();
        }
    }
    
    /**
     * 运行应用
     */
    async run() {
        console.log('\n🚀 Stay Awake 应用已启动');
        
        let running = true;
        while (running) {
            this.showMenu();
            const choice = await this.prompt('请选择 (1-4): ');
            
            switch (choice) {
                case '1':
                    if (this.awake.running) {
                        this.awake.stop();
                    } else {
                        await this.startAwake();
                    }
                    break;
                
                case '2':
                    console.log('\n选择模式:');
                    console.log('a) 被动模式（不保持唤醒）');
                    console.log('b) 无限保持唤醒');
                    console.log('c) 临时保持唤醒');
                    const modeChoice = await this.prompt('请选择 (a/b/c): ');
                    
                    if (modeChoice === 'a') {
                        this.mode = 'passive';
                        this.awake.stop();
                    } else if (modeChoice === 'b') {
                        this.mode = 'indefinite';
                        await this.startAwake();
                    } else if (modeChoice === 'c') {
                        this.mode = 'temporary';
                        await this.setModeTemporary();
                    }
                    break;
                
                case '3':
                    if (this.awake.running) {
                        this.awake.flags = this.awake.flags === 'DisplayOn' ? '' : 'DisplayOn';
                        console.log(`✅ 屏幕保持: ${this.awake.flags === 'DisplayOn' ? '开启' : '关闭'}`);
                    } else {
                        console.log('⚠️  请先启用 Stay Awake');
                    }
                    break;
                
                case '4':
                    console.log('\n👋 正在退出...');
                    this.awake.stop();
                    running = false;
                    break;
                
                default:
                    console.log('❌ 无效选择');
            }
            
            if (running) {
                await this.prompt('按 Enter 继续...');
            }
        }
        
        this.rl.close();
        process.exit(0);
    }
}

/**
 * 主函数
 */
async function main() {
    try {
        const app = new StayAwakeApp();
        await app.run();
    } catch (error) {
        console.error('❌ 应用错误:', error.message);
        process.exit(1);
    }
}

// 处理进程中断
process.on('SIGINT', () => {
    console.log('\n\n🛑 应用被中断');
    process.exit(0);
});

// 启动应用
main();

// 导出给其他模块使用
module.exports = { StayAwake, EXECUTION_STATE };
