/**
 * preload.js - 安全桥接脚本
 * 在渲染进程和主进程之间暴露受限 API
 */

const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('electronAPI', {
    /** 获取当前唤醒状态 */
    getStatus: () => ipcRenderer.invoke('get-status'),

    /** 启动唤醒：{ mode, flags, period } */
    startAwake: (config) => ipcRenderer.send('start-awake', config),

    /** 停止唤醒 */
    stopAwake: () => ipcRenderer.send('stop-awake'),

    /** 监听主进程主动停止（临时模式到期） */
    onAwakeStopped: (callback) => {
        ipcRenderer.on('awake-stopped', callback);
    },

    /** 监听状态更新 */
    onStatusUpdated: (callback) => {
        ipcRenderer.on('status-updated', (_event, status) => callback(status));
    },
});
