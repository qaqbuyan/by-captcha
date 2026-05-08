import React, { useRef, useCallback } from 'react';
import { View, StyleSheet, Alert } from 'react-native';
import { WebView } from 'react-native-webview';

/**
 * Buyan-Captcha React Native 验证码组件
 * 
 * 使用 WebView 加载 H5 页面来展示验证码
 * 需要安装依赖: npm install react-native-webview
 */

// H5 页面内容，也可以将 captcha.html 部署到服务器后通过 url 加载
const CAPTCHA_HTML = `
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>验证码</title>
    <script src="https://qaqbuyan.com:88/buyan_captcha?js" type="text/javascript"></script>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            display: flex; 
            justify-content: center; 
            align-items: center; 
            min-height: 100vh; 
            background: #f5f5f5;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
        }
        .container {
            width: 100%;
            max-width: 400px;
            padding: 20px;
        }
        #captcha-div {
            background: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
    </style>
</head>
<body>
    <div class="container">
        <div id="captcha-div"></div>
    </div>
    <script>
        // 初始化验证码
        buyanBehaviorCaptcha({
            token: '', // 请替换为您的验证码 token
            click: "none", // 监听模式：none 自动显示
            insertion: "#captcha-div", // 插入位置
            success: function (params, reset) {
                // 验证成功，通过 postMessage 将票据发送给 React Native
                window.ReactNativeWebView.postMessage(JSON.stringify({
                    type: 'success',
                    params: params
                }));
            },
            fail: function () {
                // 验证失败
                window.ReactNativeWebView.postMessage(JSON.stringify({
                    type: 'fail'
                }));
            },
            update: function () {
                // Token 过期
                window.ReactNativeWebView.postMessage(JSON.stringify({
                    type: 'update'
                }));
            }
        });
    </script>
</body>
</html>
`;

/**
 * 验证码 WebView 组件
 * 
 * @param {Object} props
 * @param {string} props.token - 验证码 Token（可选，默认为空）
 * @param {function} props.onSuccess - 验证成功回调 (params) => void
 * @param {function} props.onFail - 验证失败回调 () => void
 * @param {function} props.onUpdate - Token 过期回调 () => void
 * @param {string} props.sourceUrl - 外部 H5 页面 URL（可选，默认使用内置 HTML）
 */
const CaptchaWebView = ({
    token = '',
    onSuccess,
    onFail,
    onUpdate,
    sourceUrl,
}) => {
    const webViewRef = useRef(null);

    // 处理 WebView 消息
    const handleMessage = useCallback((event) => {
        try {
            const data = JSON.parse(event.nativeEvent.data);
            
            switch (data.type) {
                case 'success':
                    onSuccess?.(data.params);
                    break;
                case 'fail':
                    onFail?.();
                    break;
                case 'update':
                    onUpdate?.();
                    break;
                default:
                    console.log('Unknown message type:', data.type);
            }
        } catch (error) {
            console.error('Failed to parse message:', error);
        }
    }, [onSuccess, onFail, onUpdate]);

    // 注入更新 Token 的脚本
    const injectedJavaScript = `
        (function() {
            // 如果需要动态更新 token，可以在这里处理
            window.updateCaptchaToken = function(newToken) {
                // 更新 token 逻辑
            };
        })();
        true;
    `;

    // 配置 WebView 加载源
    const webViewSource = sourceUrl
        ? { uri: sourceUrl }
        : { html: CAPTCHA_HTML };

    return (
        <View style={styles.container}>
            <WebView
                ref={webViewRef}
                source={webViewSource}
                style={styles.webview}
                onMessage={handleMessage}
                injectedJavaScript={injectedJavaScript}
                javaScriptEnabled={true}
                domStorageEnabled={true}
                cacheEnabled={false}
                // Android 配置
                androidHardwareAccelerationDisabled={false}
                // iOS 配置
                allowsInlineMediaPlayback={true}
                // 安全相关
                originWhitelist={['*']}
                mixedContentMode="always"
            />
        </View>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
    },
    webview: {
        flex: 1,
    },
});

export default CaptchaWebView;
