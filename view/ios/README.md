# Buyan-Captcha iOS 接入指南

## 简介

本目录包含 Buyan-Captcha 行为验证组件的 iOS 接入示例。

**注意**：iOS 客户端当前仅支持通过 WebView 引入 H5 页面进行接入。

## 接入流程

### iOS 接入主要流程

1. 在 iOS 中打开 WebView，通过 JSBridge 触发 HTML 页面，同时注入方法，供 HTML 调用传入验证结果
2. 在 HTML 页面中接入验证码，详细请参见 [Web 客户端接入](../html/README.md)，通过调用验证码 JS，渲染验证页面，并调用 iOS 注入的方法传入验证结果
3. 通过 JSBridge 将验证结果返回到 iOS，并把相关参数（票据 ticket、随机数等）传入业务侧后端服务进行票据验证

## iOS 接入详细步骤

### 步骤一：导入 WebKit 库

在控制器或 view 中导入 WebKit 库：

```objective-c
#import <WebKit/WebKit.h>
```

### 步骤二：创建 WebView 并渲染

```objective-c
- (WKWebView *)webView {
    if (_webView == nil) {
        // 创建网页配置对象
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        // 创建设置对象
        WKPreferences *preference = [[WKPreferences alloc] init];
        // 设置是否支持 javaScript 默认是支持的
        preference.javaScriptEnabled = YES;
        // 在 iOS 上默认为 NO，表示是否允许不经过用户交互由 javaScript 自动打开窗口
        preference.javaScriptCanOpenWindowsAutomatically = YES;
        config.preferences = preference;
        
        // 这个类主要用来做 native 与 JavaScript 的交互管理
        WKUserContentController *wkUController = [[WKUserContentController alloc] init];
        // 注册一个name为jsToOcNoPrams的js方法 设置处理接收JS方法的对象
        [wkUController addScriptMessageHandler:self name:@"jsToOcNoPrams"];
        [wkUController addScriptMessageHandler:self name:@"jsToOcWithPrams"];
        config.userContentController = wkUController;
        
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) configuration:config];
        // UI 代理
        _webView.UIDelegate = self;
        // 导航代理
        _webView.navigationDelegate = self;
        
        // 此处即需要渲染的网页
        NSString *path = [[NSBundle mainBundle] pathForResource:@"captcha" ofType:@"html"];
        NSString *htmlString = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        [_webView loadHTMLString:htmlString baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
    }
    return _webView;
}

[self.view addSubview:self.webView];
```

### 步骤三：实现代理方法

代理方法，处理一些响应事件：

```objective-c
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
}

// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    
}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
}

// 提交发生错误时调用
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
}

// 接收到服务器跳转请求即服务重定向时之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    
}
```

### 步骤四：JS 将参数传给 OC

在 H5 页面中，JS 将参数传给 OC：

```html
<script>
function jsToOcFunction() {
    window.webkit.messageHandlers.jsToOcWithPrams.postMessage({"params": "res.randstr"});
}
</script>
```

### 步骤五：接收 JS 传回的数据

将渲染好的 WebView 展示在视图上，调用验证码服务，将数据传给客户端：

```objective-c
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    // 此处message.body即传给客户端的json数据
    // 用message.body获得JS传出的参数体
    NSDictionary *parameter = message.body;
    
    // JS调用OC
    if ([message.name isEqualToString:@"jsToOcWithPrams"]) {
        // 在此处客户端得到js透传数据 并对数据进行后续操作
        NSLog(@"验证票据：%@", parameter[@"params"]);
    }
}
```

### 步骤六：H5 页面接入验证码

在 H5 页面中接入验证码，并使用 JSBridge 传回验证数据：

```html
<script>
buyanBehaviorCaptcha({
    token: '',
    click: 'none',
    insertion: '#captcha-div',
    success: function(params, reset) {
        if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.jsToOcWithPrams) {
            window.webkit.messageHandlers.jsToOcWithPrams.postMessage({"params": params});
        }
        console.log('验证成功，票据：', params);
    },
    fail: function() {
        console.log('验证失败');
    },
    update: function() {
        console.log('Token已过期，请刷新');
    }
});
</script>
```

## 注意事项

1. **票据校验**：业务客户端完成验证码接入后，服务端需二次核查验证码票据结果（未接入票据校验，会导致黑产轻易伪造验证结果，失去验证码人机对抗效果）

2. **JavaScript 支持**：必须开启 JavaScript 支持 `preference.javaScriptEnabled = YES`

3. **消息处理器**：需要注册消息处理器来接收 JS 传回的数据

4. **本地 HTML**：可以将 HTML 文件放到项目的 Bundle 中加载

5. **WKWebView**：建议使用 WKWebView 替代 UIWebView，性能更好

## 相关文档

- [官方文档](https://qaqbuyan.com:88/buyan_captcha_intro.html)
- [隐私协议](https://qaqbuyan.com:88/buyan_captcha_privacy.html)