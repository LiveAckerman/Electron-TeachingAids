// preload.js
const { contextBridge, ipcRenderer } = require('electron');
contextBridge.exposeInMainWorld('electron', {
    sendMenuCommand: command => ipcRenderer.send('menu-command', command),
    maximizeWindow: () => ipcRenderer.send('maximize-window'),
    minimizeWindow: () => ipcRenderer.send('minimize-window'),
    closeWindow: () => ipcRenderer.send('close-window'),
});
