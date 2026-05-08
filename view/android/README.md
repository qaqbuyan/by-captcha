# Buyan-Captcha Android 接入指南

## 简介

本目录包含 Buyan-Captcha 行为验证组件的 Android 接入示例。

**注意**：Android 客户端当前仅支持通过 WebView 引入 H5 页面进行接入。

## 接入流程

### Android 接入主要流程

1. 在 Android 端利用 WebView 引入 H5 页面。H5 页面接入验证码，详情请参见 [Web 客户端接入](../html/README.md)
2. 在 H5 页面中，通过调用验证码 JS，渲染验证页面，并将 JS 返回的参数值传到 Android App 业务端
3. Android App 业务端把相关参数（票据）传入业务侧后端服务进行票据验证

## Android 接入详细步骤

### 步骤一：导入 WebView 组件所需的包

在项目的工程中，新建一个 Activity 并导入 WebView 组件所需的包：

```java
import android.webkit.WebView;
import android.webkit.WebSettings;
import android.webkit.WebViewClient;
import android.webkit.WebChromeClient;
```

### 步骤二：添加相关权限

添加相关权限，如开启网络访问权限以及允许 App 进行非 HTTPS 请求等：

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<application android:usesCleartextTraffic="true">
    ...
</application>
```

### 步骤三：添加 WebView 组件

在 Activity 的布局文件中，添加 WebView 组件：

```xml
<WebView
    android:id="@+id/webview"
    android:layout_height="match_parent"
    android:layout_width="match_parent" />
```

### 步骤四：创建 JavascriptInterface 文件

在项目的工程中，添加自定义 JavascriptInterface 文件，并定义一个方法用来获取相关数据：

```java
import android.webkit.JavascriptInterface;

public class JsBridge {
    @JavascriptInterface
    public void getData(String data) {
        System.out.println(data);
    }
}
```

### 步骤五：加载 H5 业务页面

在 Activity 文件中，加载相关 H5 业务页面：

```java
public class MainActivity extends AppCompatActivity {
    private WebView webview;
    private WebSettings webSettings;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        initView();
    }

    private void initView() {
        webview = (WebView) findViewById(R.id.webview);
        webSettings = webview.getSettings();
        webSettings.setUseWideViewPort(true);
        webSettings.setLoadWithOverviewMode(true);
        // 禁用缓存
        webSettings.setCacheMode(WebSettings.LOAD_NO_CACHE);
        webview.setWebViewClient(new WebViewClient() {
            @Override
            public boolean shouldOverrideUrlLoading(WebView view, String url) {
                view.loadUrl(url);
                return true;
            }
        });
        // 开启js支持
        webSettings.setJavaScriptEnabled(true);
        webview.addJavascriptInterface(new JsBridge(), "jsBridge");
        // 也可以加载本地html(webView.loadUrl("file:///android_asset/xxx.html"))
        webview.loadUrl("https://x.x.x/x/");
    }
}
```

### 步骤六：H5 页面接入验证码

在 H5 业务页面中接入验证码，详情请参见 [Web 客户端接入](../html/README.md) 文档，并使用 JSBridge 传回验证数据给具体业务端：

```html
<script>
buyanBehaviorCaptcha({
    token: '',
    click: 'none',
    insertion: '#captcha-div',
    success: function(params, reset) {
        if (window.jsBridge && window.jsBridge.getData) {
            window.jsBridge.getData(params);
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

2. **网络权限**：确保已添加网络访问权限

3. **HTTPS 支持**：如需支持非 HTTPS 请求，需配置 `android:usesCleartextTraffic="true"`

4. **JS 支持**：必须开启 JavaScript 支持 `webSettings.setJavaScriptEnabled(true)`

5. **缓存控制**：建议禁用缓存 `webSettings.setCacheMode(WebSettings.LOAD_NO_CACHE)`

6. **本地 HTML**：也可以加载本地 HTML 文件 `webView.loadUrl("file:///android_asset/xxx.html")`

## 相关文档

- [官方文档](https://qaqbuyan.com:88/buyan_captcha_intro.html)
- [隐私协议](https://qaqbuyan.com:88/buyan_captcha_privacy.html)