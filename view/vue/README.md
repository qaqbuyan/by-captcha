# Buyan-Captcha Vue 接入指南

## 简介

本目录包含 Buyan-Captcha 行为验证组件的 Vue 接入示例。

## 快速开始

### 1. 引入脚本

在项目的 `index.html` 或入口文件中引入验证码脚本：

```html
<script src="https://qaqbuyan.com:88/buyan_captcha?js" type="text/javascript"></script>
```

**注意事项：**

- 验证码 JS 加载尽量前置，目的是采集更完整的环境和设备信息
- 避免下载到项目本地，必须从上方显示的准确 URL 获取该文件
- 如果使用代理或缓存方式访问此文件，后续更新策略可能会导致脚本无法正常工作

### 2. 使用组件

将 `demo.vue` 组件引入到您的项目中：

```vue
<template>
  <div>
    <BuyanCaptcha />
  </div>
</template>

<script>
import BuyanCaptcha from './demo.vue'

export default {
  components: {
    BuyanCaptcha
  }
}
</script>
```

### 3. 配置 Token

在 `demo.vue` 中替换 `token` 为您的实际 Token：

```javascript
buyanBehaviorCaptcha({
    token: 'your_token_here',
    // ...
})
```

## 组件示例

### 方法一：JS API 校验

```vue
<template>
  <div>
    <div id="captcha-div"></div>
    <button id="login">登录</button>
  </div>
</template>

<script>
export default {
  name: 'BuyanCaptcha',
  mounted() {
    this.initCaptcha()
  },
  methods: {
    initCaptcha() {
      buyanBehaviorCaptcha({
        token: '',
        click: 'none',
        insertion: '#captcha-div',
        success: (params, reset) => {
          console.log('验证成功，票据：', params)
        },
        fail: () => {
          console.log('验证失败')
        },
        update: () => {
          console.log('Token已过期，请刷新')
        }
      })
    }
  }
}
</script>
```

### 方法二：Data API 校验

Buyan-Captcha 支持通过自定义属性 `buyan-captcha-config` 自动初始化 UI 控件。

在需要的元素上添加 `buyan-captcha-config` 属性，属性值为 JSON 格式的配置信息，Buyan-Captcha 会自动解析配置信息并初始化 UI 控件。

```vue
<template>
  <div>
    <div id="captcha-div"></div>
    <button id="getting">获取验证码</button>
    <div
      buyan-captcha-config='{"token":"","click":"#getting","insertion":"#captcha-div","success":function(code,reset){console.log("验证成功，票据：",code);},"update":function(){console.log("Token已过期，请刷新");},"fail":function(){console.log("验证失败");}}'
    ></div>
  </div>
</template>

<script>
export default {
  name: 'BuyanCaptchaDataAPI'
}
</script>
```

## 参数说明

| 名称 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `token` | String | 是 | 请求验证信息的 Token |
| `click` | String | 是 | 监听按钮元素的点击事件，支持 `#id`、`.class`、`none`、`auto` |
| `insertion` | String | 是 | 插入的 DOM，仅支持 `#id` 跟 `.class` |
| `logo` | Boolean | 否 | 是否显示 logo，默认为 `true` |
| `darkmode` | Boolean | 否 | 深夜模式，默认为 `false` |
| `success` | Function | 是 | 验证成功的回调，接收 `params` 和 `reset` 两个参数 |
| `fail` | Function | 否 | 验证失败的回调 |
| `update` | Function | 否 | 令牌过期的回调 |
| `ready` | Function | 否 | 验证码初始化成功回调 |
| `error` | Function | 否 | 验证码初始化失败回调 |

## 注意事项

1. **生命周期**：在 `mounted` 钩子中初始化验证码，确保 DOM 已渲染
2. **箭头函数**：回调函数使用箭头函数，避免 `this` 指向问题
3. **Token 获取**：需要先获取 App Id，再通过 App Id 获取 Token
4. **Token 有效期**：Token 一般 24 小时后失效，需要使用 App Id 进行更新

## 更多信息

- [官方文档](https://qaqbuyan.com:88/buyan_captcha_intro.html)
- [隐私协议](https://qaqbuyan.com:88/buyan_captcha_privacy.html)