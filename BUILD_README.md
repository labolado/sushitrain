# Sushitrain Build Script

自动构建并安装 Sushitrain 到连接的 iOS 设备。

## 功能特性

✅ **自动检测设备** - 自动扫描并选择第一个可用的 iOS 设备
✅ **一键构建** - 支持 Debug 和 Release 两种配置
✅ **自动安装** - 构建完成后自动安装到设备
✅ **自动启动** - 安装后自动启动应用
✅ **美化输出** - 彩色终端输出，清晰显示进度

## 使用方法

### 前置要求

1. **连接 iOS 设备**
   - 使用 USB 线连接 iPhone/iPad 到 Mac
   - 解锁设备
   - 如果提示信任此电脑，请点击"信任"

2. **确认 Bundle ID**
   - 项目的 Bundle ID: `com.labolado.test.Sushitrain`
   - 已配置 wildcard provisioning profile: `com.labolado.test.*`
   - 无需修改配置即可使用

### 构建命令

#### Debug 构建（默认）
```bash
./build.sh
```

#### Release 构建
```bash
./build.sh Release
```

## 构建流程

脚本会自动执行以下步骤：

1. 🔍 **扫描设备** - 查找连接的 iOS 设备
2. 🧹 **清理构建** - 删除旧的构建文件
3. 🔨 **编译项目** - 使用 Xcode 构建项目
4. 📦 **验证 Bundle** - 检查 Bundle ID 是否正确
5. 📱 **安装到设备** - 使用 xcrun devicectl 或 ios-deploy 安装
6. 🚀 **启动应用** - 在设备上启动应用

## 输出文件

构建完成后，以下文件会生成：

- `build/DerivedData/` - Xcode 派生数据
- `build/build.log` - 构建日志

## 故障排除

### 设备未检测到

```bash
# 检查连接的设备
xcrun devicectl list devices

# 或使用 Xcode 查看设备
# Window -> Devices and Simulators
```

### 代码签名问题

确保以下设置正确：
1. Bundle ID: `com.labolado.test.Sushitrain`
2. Wildcard App ID: `com.labolado.test.*`
3. Provisioning Profile 包含该 Bundle ID

### 安装失败

可以尝试安装 `ios-deploy`（更好的安装体验）：
```bash
brew install ios-deploy
```

### 查看详细日志

```bash
less build/build.log
```

## 高级用法

### 只构建不安装

如果想只构建不安装到设备：

```bash
xcodebuild -project Sushitrain.xcodeproj \
    -scheme Synctrain \
    -configuration Debug \
    -sdk iphoneos \
    build
```

### 手动安装 .ipa 文件

构建完成后，可以创建 .ipa 文件：
```bash
# 进入构建目录
cd build/DerivedData/Build/Products/Debug-iphoneos/

# 创建 Payload 目录结构
mkdir -p Payload
cp -R Synctrain.app Payload/

# 压缩为 .ipa
zip -r Synctrain.ipa Payload
```

然后使用 Apple Configurator 或 ios-deploy 安装：
```bash
ios-deploy --bundle Synctrain.ipa --install
```

## 配置说明

### 修改 Bundle ID

如需修改 Bundle ID，编辑以下文件：
- `Sushitrain/Sushitrain-Info.plist` 或
- Xcode 项目设置

### 修改 Scheme

脚本默认使用 `Synctrain` scheme，如需修改：
```bash
# 编辑 build.sh
SCHEME="YourSchemeName"
```

## 技术细节

- **SDK**: iphoneos (真实设备，非模拟器)
- **架构**: arm64
- **代码签名**: 使用 wildcard provisioning profile
- **安装方式**: xcrun devicectl 或 ios-deploy (回退)
- **最小系统版本**: iOS 17.0

## 许可证

MIT License - 与 Sushitrain 项目相同
