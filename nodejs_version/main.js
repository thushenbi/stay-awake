/**
 * Stay Awake - Node.js / Electron GUI 版本
 * 防止系统进入休眠状态
 *
 * Author: JavaScript/Electron Implementation
 * License: MIT
 */

const { app, BrowserWindow, ipcMain, powerSaveBlocker } = require('electron');
const path = require('path');

let mainWindow = null;
let powerSaveId = -1;
let awakeEnabled = false;
let awakeMode = 'passive';   // 'passive' | 'indefinite' | 'temporary'
let awakeFlags = '';          // '' | 'DisplayOn'
let stopTimer = null;

// ─── 核心功能 ─────────────────────────────────────────────────────────────────

function startAwake(mode, flags, period) {
    stopAwake();

    awakeMode = mode;
    awakeFlags = flags;
    awakeEnabled = true;

    // 选择合适的阻止类型：DisplayOn 保持屏幕常亮，否则只阻止系统挂起
    const blocker = flags === 'DisplayOn' ? 'prevent-display-sleep' : 'prevent-app-suspension';
    powerSaveId = powerSaveBlocker.start(blocker);

    // 临时模式：到期后自动停止
    if (period > 0) {
        stopTimer = setTimeout(() => {
            stopAwake();
            if (mainWindow && !mainWindow.isDestroyed()) {
                mainWindow.webContents.send('awake-stopped');
            }
        }, period);
    }
}

function stopAwake() {
    if (stopTimer) {
        clearTimeout(stopTimer);
        stopTimer = null;
    }
    if (powerSaveId !== -1) {
        powerSaveBlocker.stop(powerSaveId);
        powerSaveId = -1;
    }
    awakeEnabled = false;
}

// ─── 窗口创建 ─────────────────────────────────────────────────────────────────

function createWindow() {
    mainWindow = new BrowserWindow({
        width: 420,
        height: 600,
        resizable: false,
        maximizable: false,
        title: 'Stay Awake',
        webPreferences: {
            preload: path.join(__dirname, 'preload.js'),
            contextIsolation: true,
            nodeIntegration: false,
        },
    });

    // 隐藏菜单栏
    mainWindow.setMenuBarVisibility(false);

    mainWindow.loadFile(path.join(__dirname, 'index.html'));

    mainWindow.on('closed', () => {
        mainWindow = null;
    });
}

// ─── 应用生命周期 ─────────────────────────────────────────────────────────────

app.whenReady().then(() => {
    createWindow();

    app.on('activate', () => {
        if (BrowserWindow.getAllWindows().length === 0) {
            createWindow();
        }
    });
});

app.on('window-all-closed', () => {
    stopAwake();
    if (process.platform !== 'darwin') {
        app.quit();
    }
});

// ─── IPC 处理 ─────────────────────────────────────────────────────────────────

/** 获取当前状态（渲染进程初始化时调用） */
ipcMain.handle('get-status', () => ({
    enabled: awakeEnabled,
    mode: awakeMode,
    flags: awakeFlags,
}));

/** 启动唤醒 */
ipcMain.on('start-awake', (event, { mode, flags, period }) => {
    startAwake(mode, flags, period);
    event.reply('status-updated', {
        enabled: awakeEnabled,
        mode: awakeMode,
        flags: awakeFlags,
    });
});

/** 停止唤醒 */
ipcMain.on('stop-awake', (event) => {
    stopAwake();
    event.reply('status-updated', {
        enabled: awakeEnabled,
        mode: awakeMode,
        flags: awakeFlags,
    });
});
