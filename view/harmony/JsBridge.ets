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
