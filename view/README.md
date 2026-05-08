# 前端接入示例

本目录包含 Buyan-Captcha 行为验证组件的各类前端接入示例和文档。

## 目录结构

```
view/
├── android/       # Android 客户端接入示例
├── harmony/       # HarmonyOS 鸿蒙客户端接入示例
├── html/          # 原生 HTML 接入示例
├── ios/           # iOS 客户端接入示例
├── react-native/  # React Native 客户端接入示例
└── vue/           # Vue 框架接入示例
```

## 各平台接入指南

### [HTML 接入](html/README.md)

原生 HTML/JS 接入方式，适用于各类 Web 项目。

**适用场景：**
- 传统 Web 网站
- 静态 HTML 页面
- 其他框架的基础接入参考

### [Vue 接入](vue/README.md)

Vue 框架专用接入示例。

**适用场景：**
- Vue 2 / Vue 3 项目
- 单页应用（SPA）
- 需要组件化封装的项目

### [Android 接入](android/README.md)

Android 客户端接入示例，通过 WebView 引入 H5 页面。

**适用场景：**
- Android App
- 使用 WebView 方式接入

### [iOS 接入](ios/README.md)

iOS 客户端接入示例，通过 WebView 引入 H5 页面。

**适用场景：**
- iOS App
- 使用 WKWebView 方式接入

### [Harmony 接入](harmony/README.md)

HarmonyOS 鸿蒙客户端接入示例，通过 WebView 引入 H5 页面。

**适用场景：**
- HarmonyOS App
- 鸿蒙系统原生应用

### [React Native 接入](react-native/README.md)

React Native 跨平台客户端接入示例，通过 WebView 引入 H5 页面。

**适用场景：**
- React Native 跨平台应用
- 同时支持 iOS 和 Android
- 使用 WebView 方式接入

## 快速开始

请根据您的项目类型选择对应的接入指南：

1. **Web 项目** → 选择 [HTML](html/README.md) 或 [Vue](vue/README.md)
2. **Android App** → 选择 [Android](android/README.md)
3. **iOS App** → 选择 [iOS](ios/README.md)
4. **HarmonyOS App** → 选择 [Harmony](harmony/README.md)
5. **React Native App** → 选择 [React Native](react-native/README.md)

## 注意事项

- 移动端（Android/iOS/Harmony/React Native）当前仅支持通过 WebView 引入 H5 页面进行接入
- 验证码 JS 必须从官方 URL 加载，避免下载到本地
- 建议将 JS 加载放在页面 `<head>` 中，以采集更完整的环境信息