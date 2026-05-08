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
