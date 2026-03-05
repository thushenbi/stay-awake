const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('electronAPI', {
    // 获取初始状态
    getStatus: () => {
        console.log('[preload] getStatus invoked');
        return ipcRenderer.invoke('get-status');
    },
    
    // 发送命令
    startAwake: (params) => {
        console.log('[preload] startAwake', params);
        ipcRenderer.send('start-awake', params);
    },
    stopAwake: () => {
        console.log('[preload] stopAwake');
        ipcRenderer.send('stop-awake');
    },
    
    // 监听状态更新
    onStatusUpdate: (callback) => ipcRenderer.on('status-updated', (_event, value) => callback(value)),
    onAwakeStopped: (callback) => ipcRenderer.on('awake-stopped', (_event, value) => callback(value))
});

// 将渲染进程的 console 输出转发到主进程，方便在主进程终端查看
(function forwardConsole() {
    try {
        const origLog = console.log.bind(console);
        const origWarn = console.warn.bind(console);
        const origError = console.error.bind(console);

        function sendToMain(level, args) {
            try {
                const text = args.map(a => {
                    try { return (typeof a === 'string') ? a : JSON.stringify(a); } catch (e) { return String(a); }
                }).join(' ');
                ipcRenderer.send('renderer-log', { level, text });
            } catch (e) { /* ignore */ }
        }

        console.log = function(...args) { sendToMain('log', args); origLog(...args); };
        console.warn = function(...args) { sendToMain('warn', args); origWarn(...args); };
        console.error = function(...args) { sendToMain('error', args); origError(...args); };
    } catch (e) {
        // no-op
    }
})();
