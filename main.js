const { app, BrowserWindow, Menu, ipcMain, BrowserView, shell } = require('electron');
const path = require('path');
const fs = require('fs');

/* 静态文件根路径 */
let root_path = app.isPackaged ? process.resourcesPath : app.getAppPath();
let win;
/* 设置菜单按钮 */
Menu.setApplicationMenu(null); // null值取消顶部菜单栏
const contextMenu = Menu.buildFromTemplate([
    // { role: 'appMenu', label: '应用' },
    // { role: 'fileMenu', label: '文件' },
    // { role: 'editMenu', label: '设置' },
    // { role: 'viewMenu', label: '视图' },
    // { role: 'windowMenu', label: '窗口' },

    { role: 'reload', label: '刷新' },
    { role: 'forcereload', label: '强制刷新' },
    { role: 'toggledevtools', label: '开发者工具' },
    { role: 'togglefullscreen', label: '全屏' },
    { role: 'minimize', label: '最小化' },
    {
        label: 'web服务操作',
        submenu: [
            {
                label: '更新web程序',
                click: () => {
                    // 假设你的.bat文件路径是'path/to/your/script.bat'
                    const batPath = path.join(root_path, '/assets/update_1.bat');
                    shell
                        .openPath(batPath)
                        .then((res, a, b) => {
                            console.log('执行成功');
                        })
                        .catch(err => {
                            console.log('执行失败');
                            console.log(err);
                        });
                },
            },
            {
                label: '更新web配置文件',
                click: () => {
                    // 假设你的.bat文件路径是'path/to/your/script.bat'
                    const batPath = path.join(root_path, '/assets/update_3.bat');
                    shell
                        .openPath(batPath)
                        .then((res, a, b) => {
                            console.log('执行成功');
                        })
                        .catch(err => {
                            console.log('执行失败');
                            console.log(err);
                        });
                },
            },
        ],
    },
    {
        role: 'help',
        label: '帮助',
        submenu: [
            {
                label: '关于',
                click: async () => {
                    await shell.openExternal('http://119.23.104.214/');
                },
            },
        ],
    },
    { role: 'quit', label: '退出' },
]);

function initSet(win) {
    win.setIcon(path.join(root_path, '/assets/logo-white.png'));
    const wc = win.webContents;
    // 点击右键时弹窗菜单
    wc.on('context-menu', (e, params) => {
        contextMenu.popup({ window: win, x: params.x, y: params.y });
    });
}

const createWindow = () => {
    win = new BrowserWindow({
        fullscreen: true,
        webPreferences: {
            nodeIntegration: true, // 关闭节点集成
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

/* 读取配置 */
let config = {};

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

    const gotTheLock = app.requestSingleInstanceLock();
    if (!gotTheLock) {
        app.quit();
    } else {
        app.on('second-instance', event => {
            if (win) {
                if (win.isMinimized()) win.restore();
                win.focus();
            }
        });
        app.whenReady().then(createWindow);
    }
});
