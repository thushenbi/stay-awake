/**
 * Stay Awake - 渲染进程逻辑
 * 处理 UI 交互并更新视图状态
 */

// 元素引用
const elEnable = document.getElementById('cb-enable');
const elDisplay = document.getElementById('cb-display'); // 保持屏幕开启
const rbPassive = document.getElementById('rb-passive');
const rbIndefinite = document.getElementById('rb-indefinite');
const rbTemporary = document.getElementById('rb-temporary');

// 临时模式的时间输入
const inpHours = document.getElementById('ed-hours');
const inpMinutes = document.getElementById('ed-minutes');

// 状态显示
const stEnabled = document.getElementById('st-enabled');
const stMode = document.getElementById('st-mode');
const stScreen = document.getElementById('st-screen');
// 容器引用（用于禁用/启用样式）
const rowPassive = document.getElementById('row-passive');
const rowIndefinite = document.getElementById('row-indefinite');
const rowTemporary = document.getElementById('row-temporary');

// 初始化
window.addEventListener('DOMContentLoaded', async () => {
    console.log('[renderer] DOMContentLoaded - requesting status');
    const status = await window.electronAPI.getStatus();
    console.log('[renderer] initial status received', status);

    // 初始状态下解锁UI以便用户操作
    updateUIStateOnly(false); // 传入 false 表示未运行，允许编辑配置
    updateStatusBar(status);
});

// 监听后端状态更新
window.electronAPI.onStatusUpdate((status) => {
    console.log('[renderer] status-updated', status);
    updateUI(status);
});

// 监听自动停止事件（定时器结束）
window.electronAPI.onAwakeStopped(() => {
    elEnable.checked = false;
    // 停止后，允许用户再次编辑
    updateUIStateOnly(false); 
    updateStatusBar({ enabled: false, mode: 'passive', flags: '' });
});

// 主开关变更事件
elEnable.addEventListener('change', () => {
    if (elEnable.checked) {
        // 开启前先检查是否有模式被选中，如果没有默认选中无限
        if (!rbIndefinite.checked && !rbTemporary.checked && !rbPassive.checked) {
            rbIndefinite.checked = true;
        }
        applySettings();
    } else {
        window.electronAPI.stopAwake();
        updateUIStateOnly(false); // 停止运行，解锁配置
    }
});

// 其他控件变更事件
[elDisplay, rbPassive, rbIndefinite, rbTemporary, inpHours, inpMinutes].forEach(el => {
    if(el) el.addEventListener('change', handleControlChange);
    // 针对输入框增加 input 事件以实时响应
    if(el && (el.type === 'number' || el.type === 'text')) {
        el.addEventListener('input', handleControlChange);
    }
});

function handleControlChange() {
    // 只有在运行时修改参数才需要实时 apply
    // 如果是未运行状态，只需要更新本地UI逻辑（如显示/隐藏时间框）
    updateTimeInputsVisibility();

    if (elEnable.checked) {
        applySettings();
    }
}

function updateTimeInputsVisibility() {
    const isTemp = rbTemporary.checked;
    inpHours.disabled = !isTemp;
    inpMinutes.disabled = !isTemp;
    
    // 视觉反馈
    const timeRow = document.getElementById('time-row');
    if (timeRow) timeRow.style.opacity = isTemp ? '1' : '0.4';
}

// 应用当前设置并发送给后端
function applySettings() {
    let mode = 'passive';
    if (rbIndefinite.checked) mode = 'indefinite';
    if (rbTemporary.checked) mode = 'temporary';

    const flags = elDisplay.checked ? 'DisplayOn' : '';
    
    // 计算毫秒
    const h = parseInt(inpHours.value) || 0;
    const m = parseInt(inpMinutes.value) || 0;
    const period = (h * 3600 + m * 60) * 1000;

    window.electronAPI.startAwake({
        mode,
        flags,
        period
    });
    
    // 运行时更新状态
    updateUIStateOnly(true);
}

// 统一更新 UI
function updateUI(status) {
    // 同步开关状态
    elEnable.checked = status.enabled;
    
    // 同步选项状态（以后端为准）
    if (status.mode === 'indefinite') rbIndefinite.checked = true;
    else if (status.mode === 'temporary') rbTemporary.checked = true;
    
    // 同步标志
    elDisplay.checked = status.flags === 'DisplayOn';

    updateUIStateOnly(status.enabled);
    updateStatusBar(status);
    updateTimeInputsVisibility();
}

/**
 * 设置控件的启用/禁用状态
 * @param {boolean} isRunning - 当前是否处于“防止休眠”运行中
 */
function updateUIStateOnly(isRunning) {
    // 策略：
    // 1. 如果正在运行 (isRunning = true)，通常我们允许实时修改参数，除了可能需要锁定的部分。
    //    这里我们允许实时修改，所以控件保持 enabled。
    // 2. 如果未运行 (isRunning = false)，同样允许修改参数以便下次启动。
    
    // 这里唯一需要联动的是 "临时模式" 下的时间输入框是否可用，这由 updateTimeInputsVisibility 处理。
    // 以及主标题栏的状态，或者如果想要“运行时锁定配置”，则在这里禁用 inputs。
    
    // 用户的需求是“操作后能够看到现在的状态”，这意味着交互要清晰。
    // 我们让所有配置项始终可用，变更即生效（若已运行）。
    
    // 视觉上区分：
    const cards = [rowPassive, rowIndefinite, rowTemporary].filter(e => e);
    cards.forEach(c => c.classList.remove('disabled')); // 移除之前的禁用样式，保持常亮
}

// 更新底部状态栏文字
function updateStatusBar(status) {
    if (status.enabled) {
        stEnabled.innerText = "运行中 (Active)";
        stEnabled.className = "status-val on";
        stEnabled.style.color = "#107c10"; // 绿色
        
        let modeText = "未知";
        if (status.mode === 'indefinite') modeText = "无限常亮";
        if (status.mode === 'temporary') modeText = "临时常亮";
        if (status.mode === 'passive') modeText = "被动模式";
        stMode.innerText = modeText;

        if (status.flags === 'DisplayOn') {
            stScreen.innerText = "保持开启";
            stScreen.className = "status-val on";
            stScreen.style.color = "#107c10";
        } else {
            stScreen.innerText = "允许关闭";
            stScreen.className = "status-val"; // 默认色
            stScreen.style.color = "#666";
        }

    } else {
        stEnabled.innerText = "已停止 (Inactive)";
        stEnabled.className = "status-val off";
        stEnabled.style.color = "#d13438"; // 红色
        
        stMode.innerText = "—";
        stScreen.innerText = "关闭";
        stScreen.className = "status-val off";
        stScreen.style.color = "#d13438";
    }
}
