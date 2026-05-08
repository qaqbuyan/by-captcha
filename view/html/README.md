# Buyan-Captcha HTML 接入指南

## 简介

本目录包含 Buyan-Captcha 行为验证组件的 HTML 接入示例和文档。

## 快速开始

### 1. 引入脚本

在页面中引入验证码脚本（建议放在 `<head>` 标签中）：

```html
<script src="https://qaqbuyan.com:88/buyan_captcha?js" type="text/javascript"></script>
```

**注意事项：**

- 验证码 JS 加载尽量前置，目的是采集更完整的环境和设备信息
- 避免下载到项目本地，必须从上方显示的准确 URL 获取该文件
- 如果使用代理或缓存方式访问此文件，后续更新策略可能会导致脚本无法正常工作
- Buyan-Captcha 要求初始化在业务页面加载时同时进行初始化

### 2. 引入样式（可选）

正常情况下，组件会自动植入样式表。如需手动引入：

```html
<link rel="stylesheet" href="https://qaqbuyan.com:88/buyan_captcha?css" type="text/css" />
```

### 3. 创建容器

在页面中预留验证码容器和触发按钮：

```html
<div id="captcha-div"></div>
<input type="button" id="submit" value="登入">
```

**注意事项：**

- 触发验证码的元素不要使用带 `id="buyan-captcha"` 开头的元素
- 如果配置为 `none` 模式，则无需创建触发按钮

## 调用方法

### 方法一：JS API 校验

```javascript
buyanBehaviorCaptcha({
    token: "your_token_here",
    click: "#button",
    insertion: "#captcha-div",
    logo: false,
    darkmode: true,
    modalbox: true,
    success: function(params, reset) {
        console.log('验证成功', params);
    },
    fail: function() {
        console.log('验证失败');
    },
    update: function() {
        console.log('刷新令牌');
    },
    ready: function() {
        console.log('初始化成功');
    },
    error: function() {
        console.log('初始化失败');
    }
});
```

### 方法二：Data API 校验

通过自定义属性 `buyan-captcha-config` 自动初始化：

```html
<div buyan-captcha-config='{
    "token": "your_token_here",
    "click": "#showCaptchaButton",
    "insertion": "#captcha-div",
    "success": function(params) {
        console.log("服务器返回的参数:", params);
    },
    "update": function() {
        console.log("刷新令牌");
    },
    "fail": function() {
        console.log("验证失败");
    }
}'></div>
```

## 参数说明

| 名称 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `token` | String | 是 | 请求验证信息的 Token |
| `click` | String | 是 | 监听按钮元素的点击事件，支持 `#id`、`.class`、`none`（自动显示）、`auto`（非交互式） |
| `insertion` | String | 是 | 插入的 DOM，仅支持 `#id` 跟 `.class` |
| `logo` | Boolean | 否 | 是否显示 logo，默认为 `true` |
| `darkmode` | Boolean | 否 | 深夜模式，默认为 `false` |
| `success` | Function | 是 | 验证成功的回调，接收 `params`（通过码）和 `reset`（重置函数）两个参数 |
| `fail` | Function | 否 | 验证失败的回调 |
| `update` | Function | 否 | 令牌过期的回调 |
| `ready` | Function | 否 | 验证码初始化成功回调 |
| `error` | Function | 否 | 验证码初始化失败回调 |
| `open` | Function | 否 | 验证码弹框弹出前的回调 |
| `close` | Function | 否 | 验证码弹框关闭后的回调 |
| `refresh` | Function | 否 | 刷新验证的回调 |

## click 参数说明

| 值 | 说明 |
|---|---|
| `#id` | 监听指定 id 元素的点击事件 |
| `.class` | 监听指定 class 元素的点击事件 |
| `none` | 自动显示验证界面，用户勾选控件复选框进行验证 |
| `auto` | 非交互式模式，无需用户交互，验证失败时才需要额外验证 |

## 注意事项

1. **Token 获取**：需要先获取 App Id，再通过 App Id 获取 Token
2. **Token 有效期**：Token 一般 24 小时后失效，需要使用 App Id 进行更新
3. **安全性**：切勿在客户端代码、Git 仓库或公共 URL 中暴露 App Key 和 App Id
4. **回调函数**：所有回调都支持箭头函数写法

## 更多信息

- [官方文档](https://qaqbuyan.com:88/buyan_captcha_intro.html)
- [隐私协议](https://qaqbuyan.com:88/buyan_captcha_privacy.html)