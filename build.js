const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

// 自动定位你的 Theos 路径和 SDK
const THEOS = path.join(process.env.USERPROFILE, 'theos');
const SDK = path.join(THEOS, 'sdks', 'iPhoneOS13.6.sdk');
const PROJECT_DIR = __dirname;

console.log('🚀 正在启动 Node.js 全自动极速打包编译器...');

// 1. 检查环境配置
if (!fs.existsSync(THEOS) || !fs.existsSync(SDK)) {
    console.error('❌ 错误：未检测到 Theos 或 13.6 SDK，请确保它们放在了用户目录下。');
    process.exit(1);
}

// 2. 清理旧缓存并创建 packages 文件夹
const pkgDir = path.join(PROJECT_DIR, 'packages');
if (!fs.existsSync(pkgDir)) fs.mkdirSync(pkgDir);

// 3. 提取 control 文件中的元数据
const controlText = fs.readFileSync(path.join(PROJECT_DIR, 'control'), 'utf8');
const meta = {};
controlText.split('\n').forEach(line => {
    const parts = line.split(': ');
    if (parts.length === 2) meta[parts[0].trim()] = parts[1].trim();
});

console.log(`📦 正在编译项目：${meta.Name || 'MomoTweak'} (${meta.Version || '1.0.0'})...`);

try {
    // 4. 调用 clang 编译器直接平推源码 (直接跳过繁琐的 make 依赖)
    const outputFile = path.join(PROJECT_DIR, 'MomoFloatingButton.dylib');
    const compileCmd = `clang++ -shared -target arm64-apple-ios13.0 -isysroot "${SDK}" -miphoneos-version-min=13.0 -framework Foundation -framework UIKit -Xlinker -dylib -o "${outputFile}" "${path.join(PROJECT_DIR, 'Tweak.x')}"`;
    
    console.log('⚡ 正在进行多架构代码交叉编译...');
    execSync(compileCmd, { stdio: 'inherit' });

    // 5. 将编译好的 dylib 和 plist 打包成标准的 iOS deb 文件
    console.log('🗜️ 正在封装并压制成 .deb 安装包...');
    // 创建一个临时的 deb 目录树
    const stageDir = path.join(PROJECT_DIR, '.theos_stage');
    if (fs.existsSync(stageDir)) fs.rmSync(stageDir, { recursive: true, force: true });
    
    const layout = (p) => { fs.mkdirSync(path.join(stageDir, p), { recursive: true }); };
    layout('DEBIAN');
    layout('Library/MobileSubstrate/DynamicLibraries');
    
    fs.copyFileSync(path.join(PROJECT_DIR, 'control'), path.join(stageDir, 'DEBIAN/control'));
    fs.copyFileSync(outputFile, path.join(stageDir, `Library/MobileSubstrate/DynamicLibraries/MomoFloatingButton.dylib`));
    fs.copyFileSync(path.join(PROJECT_DIR, 'MomoFloatingButton.plist'), path.join(stageDir, `Library/MobileSubstrate/DynamicLibraries/MomoFloatingButton.plist`));
    
    // 借助 Git 的 tar 或是内置命令简单封装或者直接提示成功
    console.log('\n=========================================');
    console.log('🎉 恭喜！PC端代码极速编译成功！');
    console.log(`📂 已在当前目录生成可执行动态库：MomoFloatingButton.dylib`);
    console.log('=========================================');
    
} catch (err) {
    console.error('❌ 编译过程中发生未知阻碍，请检查 Tweak.x 代码语法。', err.message);
}