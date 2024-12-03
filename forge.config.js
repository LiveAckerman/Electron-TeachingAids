const { FusesPlugin } = require('@electron-forge/plugin-fuses');
const { FuseV1Options, FuseVersion } = require('@electron/fuses');
const fs = require('fs');
const path = require('path');

/*  certificateFile: './cert.pfx',       certificatePassword: process.env.CERTIFICATE_PASSWORD, */
module.exports = {
    buildIdentifier: 'com.lq.TeachingAids',
    packagerConfig: {
        name: 'TeachingAids',
        asar: true,
        icon: './assets/favicon.ico',
        extraResource: ['./assets'], // 静态文件
    },
    rebuildConfig: {},
    hooks: {
        postPackage: async (forgeConfig, options) => {
            if (options.outputPaths && options.outputPaths.length) {
                // 删除多余的语言包
                const localesDirectory = path.join(options.outputPaths[0], '/locales'); // 路径根据实际情况调整
                const localesFileArr = fs.readdirSync(localesDirectory);
                localesFileArr.forEach(lang => {
                    if (!lang.includes('en-US') && !lang.includes('zh-CN')) {
                        fs.unlink(`${localesDirectory}/${lang}`);
                    }
                });
            }
        },
    },
    makers: [
        {
            name: '@electron-forge/maker-squirrel',
            config: {},
        },
        {
            name: '@electron-forge/maker-zip',
            platforms: ['darwin'],
        },
        {
            name: '@electron-forge/maker-deb',
            config: {},
        },
        {
            name: '@electron-forge/maker-rpm',
            config: {},
        },
    ],
    plugins: [
        {
            name: '@electron-forge/plugin-auto-unpack-natives',
            config: {},
        },
        // Fuses are used to enable/disable various Electron functionality
        // at package time, before code signing the application
        new FusesPlugin({
            version: FuseVersion.V1,
            [FuseV1Options.RunAsNode]: false,
            [FuseV1Options.EnableCookieEncryption]: true,
            [FuseV1Options.EnableNodeOptionsEnvironmentVariable]: false,
            [FuseV1Options.EnableNodeCliInspectArguments]: false,
            [FuseV1Options.EnableEmbeddedAsarIntegrityValidation]: true,
            [FuseV1Options.OnlyLoadAppFromAsar]: true,
        }),
    ],
};
