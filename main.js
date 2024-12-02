const { app, BrowserWindow, Menu, ipcMain, BrowserView } = require('electron');
const path = require('path');
const fs = require('fs');

/* 设置菜单按钮 */
Menu.setApplicationMenu(null); // null值取消顶部菜单栏
const contextMenu = Menu.buildFromTemplate([
    { role: 'appMenu', label: '应用' },
    { role: 'fileMenu', label: '文件' },
    { role: 'editMenu', label: '设置' },
    { role: 'viewMenu', label: '视图' },
    { role: 'windowMenu', label: '窗口' },
    {
        role: 'help',
        label: '帮助',
        submenu: [
            {
                label: '关于',
                click: async () => {
                    const { shell } = require('electron');
                    await shell.openExternal('http://119.23.104.214/');
                },
            },
        ],
    },
]);

function initSet(win) {
    win.setIcon(path.join(root_path, '/assets/logo-white.png'));
    const wc = win.webContents;
    // 点击右键时弹窗菜单
    wc.on('context-menu', (e, params) => {
        contextMenu.popup({ window: win, x: params.x, y: params.y });
    });
}

/* 读取配置 */
let config = {};
let root_path = app.isPackaged ? process.resourcesPath : app.getAppPath();
const configPath = path.join(root_path, '/assets/config.json');
fs.readFile(configPath, 'utf8', (err, rawData) => {
    if (err) {
        console.error(`加载配置文件错误: ${err}`);
        return;
    }
    try {
        config = eval(`(${rawData})`);
        config = config[app.isPackaged ? 'prod' : 'dev'];
    } catch (parseError) {
        console.error(`转换配置文件错误: ${parseError}`);
    }

    const createWindow = () => {
        const win = new BrowserWindow({
            fullscreen: true,
            webPreferences: {
                nodeIntegration: false, // 关闭节点集成
                preload: path.join(__dirname, './scripts/preload.js'),
            },
        });

        setTimeout(() => {
            initSet(win);
        }, 1);

        // electron 判断是否是生产环境
        win.loadURL(config['system-web-url'])
            .then(() => {
                // 写入localStorage
                win.webContents.session.cookies.set({
                    url: config['system-web-url'],
                    name: 'IS_ELECTRON',
                    value: '1',
                });

                ipcMain.on('maximize-window', () => {
                    if (win.isMaximized()) {
                        win.restore(); // 如果窗口已经最大化，则恢复原始大小
                    } else {
                        win.maximize(); // 否则，最大化窗口
                    }
                });
                // 最小化
                ipcMain.on('minimize-window', () => {
                    win.minimize();
                });
                // 关闭窗口
                ipcMain.on('close-window', () => {
                    win.close();
                });
            })
            .catch(err => {
                win.loadFile(path.join(root_path, '/assets/404.html'));
            });
    };

    app.whenReady().then(createWindow);
});
