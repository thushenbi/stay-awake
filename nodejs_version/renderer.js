/**
 * renderer.js - 渲染进程 UI 逻辑
 * 处理用户交互并通过 electronAPI 与主进程通信
 */

// ─── DOM 元素 ─────────────────────────────────────────────────────────────────

const cbEnable   = document.getElementById('cb-enable');
const cbDisplay  = document.getElementById('cb-display');

const rbPassive   = document.getElementById('rb-passive');
const rbIndefinite = document.getElementById('rb-indefinite');
const rbTemporary  = document.getElementById('rb-temporary');

const rowPassive   = document.getElementById('row-passive');
const rowIndefinite = document.getElementById('row-indefinite');
const rowTemporary  = document.getElementById('row-temporary');

const edHours   = document.getElementById('ed-hours');
const edMinutes = document.getElementById('ed-minutes');

const stEnabled = document.getElementById('st-enabled');
const stMode    = document.getElementById('st-mode');
const stScreen  = document.getElementById('st-screen');

// ─── 工具函数 ─────────────────────────────────────────────────────────────────

const MODE_NAMES = {
    passive:    '被动模式 (Inactive)',
    indefinite: '无限保持',
    temporary:  '临时保持',
};

/** 根据最新状态刷新状态栏显示 */
function refreshStatus(status) {
    // 状态标签
    if (status.enabled) {
        stEnabled.textContent = '已启用';
        stEnabled.className = 'status-val on';
    } else {
        stEnabled.textContent = '已禁用';
        stEnabled.className = 'status-val off';
    }

    // 模式标签
    stMode.textContent = status.enabled ? (MODE_NAMES[status.mode] || status.mode) : '—';

    // 屏幕标签
    if (status.enabled && status.flags === 'DisplayOn') {
        stScreen.textContent = '保持开启';
        stScreen.className = 'status-val on';
    } else {
        stScreen.textContent = '关闭';
        stScreen.className = 'status-val off';
    }
}

/** 根据启用状态切换模式行的可交互性 */
function setModeRowsEnabled(enabled) {
    const rows = [rowPassive, rowIndefinite, rowTemporary];
    const radios = [rbPassive, rbIndefinite, rbTemporary];

    rows.forEach((row) => {
        if (enabled) row.classList.remove('disabled');
        else row.classList.add('disabled');
    });
    radios.forEach((rb) => { rb.disabled = !enabled; });
    cbDisplay.disabled = !enabled;
}

/** 根据所选模式切换时间输入框的可交互性 */
function setTimeInputEnabled(enabled) {
    edHours.disabled   = !enabled;
    edMinutes.disabled = !enabled;
}

/** 读取当前 UI 选项并发送启动指令 */
function applyAwake() {
    const mode  = document.querySelector('input[name="mode"]:checked').value;
    const flags = cbDisplay.checked ? 'DisplayOn' : '';

    let period = 0;
    if (mode === 'temporary') {
        // 上限与 AHK 版本保持一致：最多约 49.7 天（1192 小时 / 71568 分钟）
        const hours   = Math.max(0, Math.min(1192,  parseInt(edHours.value,   10) || 0));
        const minutes = Math.max(0, Math.min(71568, parseInt(edMinutes.value, 10) || 0));
        period = (hours * 3600 + minutes * 60) * 1000;  // 转换为毫秒
    }

    if (mode === 'passive') {
        window.electronAPI.stopAwake();
    } else {
        window.electronAPI.startAwake({ mode, flags, period });
    }
}

// ─── 事件处理 ─────────────────────────────────────────────────────────────────

/** 主开关切换 */
cbEnable.addEventListener('change', () => {
    setModeRowsEnabled(cbEnable.checked);
    if (!cbEnable.checked) {
        // 关闭 → 停止唤醒，重置 UI
        window.electronAPI.stopAwake();
        cbDisplay.checked = false;
        rbPassive.checked = true;
        setTimeInputEnabled(false);
    } else {
        // 打开 → 根据当前模式应用
        applyAwake();
    }
});

/** 屏幕保持切换 */
cbDisplay.addEventListener('change', () => {
    if (cbEnable.checked) applyAwake();
});

/** 模式单选按钮变化 */
document.querySelectorAll('input[name="mode"]').forEach((rb) => {
    rb.addEventListener('change', () => {
        const isTmp = rbTemporary.checked;
        setTimeInputEnabled(isTmp);
        if (cbEnable.checked) applyAwake();
    });
});

/** 时间输入框变化（临时模式） */
[edHours, edMinutes].forEach((el) => {
    el.addEventListener('change', () => {
        if (cbEnable.checked && rbTemporary.checked) applyAwake();
    });
});

/** 主进程通知：临时模式到期自动停止 */
window.electronAPI.onAwakeStopped(() => {
    cbEnable.checked = false;
    setModeRowsEnabled(false);
    cbDisplay.checked = false;
    rbPassive.checked = true;
    setTimeInputEnabled(false);
    refreshStatus({ enabled: false, mode: 'passive', flags: '' });
});

/** 主进程状态更新（start/stop 操作后同步） */
window.electronAPI.onStatusUpdated((status) => {
    refreshStatus(status);
});

// ─── 初始化 ───────────────────────────────────────────────────────────────────

(async () => {
    const status = await window.electronAPI.getStatus();

    // 同步主进程已有状态到 UI
    cbEnable.checked = status.enabled;
    cbDisplay.checked = status.flags === 'DisplayOn';

    if (status.mode === 'indefinite') rbIndefinite.checked = true;
    else if (status.mode === 'temporary') {
        rbTemporary.checked = true;
        setTimeInputEnabled(true);
    } else {
        rbPassive.checked = true;
    }

    setModeRowsEnabled(status.enabled);
    refreshStatus(status);
})();
