# Buyan-Captcha Harmony 接入指南

## 简介

本目录包含 Buyan-Captcha 行为验证组件的 Harmony 接入示例。

**注意**：Harmony 客户端当前仅支持通过 WebView 引入 H5 页面进行接入。

## 接入流程

### Harmony 接入主要流程

1. 在 Harmony 端利用 WebView 引入 H5 页面。H5 页面接入验证码，详情请参见 [Web 客户端接入](../html/README.md)
2. 在 H5 页面中，通过调用验证码 JS，渲染验证页面，并将 JS 返回的参数值传到 Harmony App 业务端
3. Harmony App 业务端把相关参数（票据 ticket、随机数等）传入业务侧后端服务进行票据验证

## Harmony 接入详细步骤

### 步骤一：新建 View 视图并导入 WebView 组件

在项目的工程中，新建一个 View 视图。导入 WebView 组件所需的包并进行初始化：

```typescript
import router from '@ohos.router';
import web_webview from '@ohos.web.webview';
import Logger from '../common/utils/Logger';
import JSBridge from '../common/utils/JsBridge';

@Component
export struct LoginComponent {
  controller: web_webview.WebviewController = new web_webview.WebviewController();
  @State showWebView: boolean = true;
  
  aboutToAppear() {
    web_webview.WebviewController.setWebDebuggingAccess(true);
  }
  
  ports: web_webview.WebMessagePort[] = [];
  private jsBridge: JSBridge = new JSBridge(this.controller, this);
  
  closeWebView(param: string) {
    Logger.info("接收的回调数据", param);
    const jsonObj = JSON.parse(param);
    if (jsonObj.ret == 0) {
      Logger.info("验证成功，票据：", jsonObj.ticket);
      router.pushUrl({ url: 'pages/Success', params: jsonObj });
    } else {
      Logger.info("验证失败或主动关闭");
    }
    this.showWebView = false;
  }
  
  build() {
    Stack() {
      if (this.showWebView) {
        Web({
          src: $rawfile('captcha.html'),
          controller: this.controller
        })
          .domStorageAccess(true)
          .javaScriptAccess(true)
          .javaScriptProxy(this.jsBridge.javaScriptProxy)
          .onPageBegin(() => {
            this.jsBridge.initJsBridge();
          })
          .width('360vp')
          .height('360vp')
          .backgroundColor(Color.Transparent)
          .alignSelf(ItemAlign.Center)
      }
    }
  }
}
```

### 步骤二：添加验证码 HTML 页面文件

添加验证码 HTML 页面文件，放置于 `src/main/resources/rawfile/captcha.html` 中，WebView 需要从这个路径加载文件：

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    body {
      background-color: transparent;
      margin: 0;
      padding: 0;
    }
  </style>
  <title>Buyan Captcha</title>
  <script src="https://qaqbuyan.com:88/buyan_captcha?js" type="text/javascript"></script>
</head>
<body>
  <div id="captcha-div"></div>
  <script type="text/javascript">
    function globalCallback(params) {
      if (window.JSBridgeHandle && window.JSBridgeHandle.call) {
        window.JSBridgeHandle.call('postMessage', JSON.stringify({
          ret: 0,
          ticket: params,
          callID: Date.now()
        }));
      }
    }
    
    window.onload = function() {
      buyanBehaviorCaptcha({
        token: '',
        click: 'none',
        insertion: '#captcha-div',
        success: function(params, reset) {
          globalCallback(params);
        },
        fail: function() {
          // 处理验证失败
        }
      });
    }
  </script>
</body>
</html>
```

### 步骤三：编写 JSBridge 事件通信方法

编写 WebView 页面与 App 端进行事件通信的方法：

```typescript
import WebView from '@ohos.web.webview';
import Logger from './Logger';
import { LoginComponent } from '../../view/LoginComponent';

export default class JsBridge {
  controller: WebView.WebviewController;
  private componentInstance: LoginComponent;
  
  constructor(controller: WebView.WebviewController, componentInstance: LoginComponent) {
    this.controller = controller;
    this.componentInstance = componentInstance;
  }
  
  get javaScriptProxy() {
    let result = {
      object: {
        call: this.call
      },
      name: "JSBridgeHandle",
      methodList: ['call'],
      controller: this.controller
    };
    return result;
  }
  
  initJsBridge(): void {
    this.controller.runJavaScript('window.JSBridgeReady = true;');
  }
  
  postMessage = (params: string): Promise<string> => {
    Logger.info("验证码回调数据,", params);
    this.componentInstance.closeWebView(params);
    return new Promise((resolve) => {
      resolve(params);
    });
  }
  
  call = (func: string, params: string): void => {
    const paramsObject = JSON.parse(params);
    let result: Promise<string> = new Promise((resolve) => resolve(''));
    switch (func) {
      case 'postMessage':
        result = this.postMessage(params);
        break;
      default:
        break;
    }
    result.then((data: string) => {
      this.callback(paramsObject?.callID, data);
    });
  }
  
  callback = (id: number, data: string): void => {
    this.controller.runJavaScript(`JSBridgeCallback("${id}", ${JSON.stringify(data)})`);
  }
}
```

### 步骤四：H5 页面接入验证码

在 H5 业务页面中接入验证码，详情请参见 [Web 客户端接入](../html/README.md) 文档，并使用 JSBridge 传回验证数据给具体业务端。

## 注意事项

1. **票据校验**：业务客户端完成验证码接入后，服务端需二次核查验证码票据结果（未接入票据校验，会导致黑产轻易伪造验证结果，失去验证码人机对抗效果）

2. **WebView 调试**：需要开启调试模式 `web_webview.WebviewController.setWebDebuggingAccess(true)`

3. **JavaScript 支持**：必须开启 JavaScript 支持 `.javaScriptAccess(true)`

4. **本地 HTML**：HTML 文件需放置于 `src/main/resources/rawfile/` 目录下

5. **DOM Storage**：需要开启 DOM Storage `.domStorageAccess(true)`

## 相关文档

- [官方文档](https://qaqbuyan.com:88/buyan_captcha_intro.html)
- [隐私协议](https://qaqbuyan.com:88/buyan_captcha_privacy.html)