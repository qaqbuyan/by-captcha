# Buyan-Captcha React Native 接入指南

## 简介

本目录包含 Buyan-Captcha 行为验证组件的 React Native 接入示例。

**注意**：React Native 客户端当前仅支持通过 WebView 引入 H5 页面进行接入。

## 接入流程

### React Native 接入主要流程

1. 在 React Native 端利用 WebView 引入 H5 页面
2. 在 H5 页面中，通过调用验证码 JS，渲染验证页面，并将 JS 返回的参数值传到 React Native App 业务端
3. React Native App 业务端把相关参数（票据）传入业务侧后端服务进行票据验证

## 环境要求

- React Native >= 0.60
- react-native-webview >= 11.0

## 快速开始

### 步骤一：安装依赖

```bash
npm install react-native-webview
# 或
yarn add react-native-webview
```

**iOS 额外配置：**
```bash
cd ios && pod install
```

### 步骤二：使用 CaptchaWebView 组件

```jsx
import React from 'react';
import { View, Button, Alert } from 'react-native';
import CaptchaWebView from './CaptchaWebView';

const LoginScreen = () => {
    const [showCaptcha, setShowCaptcha] = React.useState(false);

    // 验证成功回调
    const handleCaptchaSuccess = (params) => {
        console.log('验证成功，票据：', params);
        
        // TODO: 将票据提交到您的后端进行二次校验
        // 校验通过后执行登录操作
        
        setShowCaptcha(false);
        Alert.alert('成功', '验证码验证通过');
    };

    // 验证失败回调
    const handleCaptchaFail = () => {
        console.log('验证失败');
        Alert.alert('提示', '验证失败，请重试');
    };

    // Token 过期回调
    const handleCaptchaUpdate = () => {
        console.log('Token 已过期');
        Alert.alert('提示', '验证已过期，请重新验证');
    };

    return (
        <View style={{ flex: 1 }}>
            <Button 
                title="显示验证码" 
                onPress={() => setShowCaptcha(true)} 
            />
            
            {showCaptcha && (
                <View style={{ flex: 1 }}>
                    <CaptchaWebView
                        token="your_token_here"  // 替换为您的验证码 token
                        onSuccess={handleCaptchaSuccess}
                        onFail={handleCaptchaFail}
                        onUpdate={handleCaptchaUpdate}
                    />
                </View>
            )}
        </View>
    );
};

export default LoginScreen;
```

### 步骤三：部署 H5 页面（可选）

如果您希望使用外部 URL 加载验证码页面，可以将 [Captcha.html](./Captcha.html) 部署到您的服务器：

```jsx
<CaptchaWebView
    sourceUrl="https://your-domain.com/captcha.html?token=xxx"
    onSuccess={handleCaptchaSuccess}
    onFail={handleCaptchaFail}
    onUpdate={handleCaptchaUpdate}
/>
```

## CaptchaWebView 组件参数

| 参数名 | 类型 | 必填 | 默认值 | 说明 |
|--------|------|------|--------|------|
| token | string | 否 | '' | 验证码 Token |
| onSuccess | function | 否 | - | 验证成功回调，参数为验证票据 |
| onFail | function | 否 | - | 验证失败回调 |
| onUpdate | function | 否 | - | Token 过期回调 |
| sourceUrl | string | 否 | - | 外部 H5 页面 URL，不传则使用内置 HTML |

## 完整集成示例

### 登录页集成示例

```jsx
import React, { useState } from 'react';
import {
    View,
    TextInput,
    Button,
    StyleSheet,
    Modal,
    Alert,
    ActivityIndicator
} from 'react-native';
import CaptchaWebView from './CaptchaWebView';

const LoginPage = () => {
    const [username, setUsername] = useState('');
    const [password, setPassword] = useState('');
    const [showCaptcha, setShowCaptcha] = useState(false);
    const [loading, setLoading] = useState(false);

    // 处理登录
    const handleLogin = () => {
        if (!username || !password) {
            Alert.alert('提示', '请输入用户名和密码');
            return;
        }
        // 显示验证码
        setShowCaptcha(true);
    };

    // 验证码验证成功
    const handleCaptchaSuccess = async (params) => {
        setShowCaptcha(false);
        setLoading(true);

        try {
            // 调用登录接口，传入票据进行二次验证
            const response = await fetch('https://your-api.com/login', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    username,
                    password,
                    captchaTicket: params  // 验证码票据
                }),
            });

            const result = await response.json();
            
            if (result.success) {
                Alert.alert('成功', '登录成功');
                // TODO: 跳转到首页
            } else {
                Alert.alert('失败', result.message || '登录失败');
            }
        } catch (error) {
            Alert.alert('错误', '网络请求失败');
        } finally {
            setLoading(false);
        }
    };

    return (
        <View style={styles.container}>
            <TextInput
                style={styles.input}
                placeholder="用户名"
                value={username}
                onChangeText={setUsername}
            />
            <TextInput
                style={styles.input}
                placeholder="密码"
                secureTextEntry
                value={password}
                onChangeText={setPassword}
            />
            <Button title="登录" onPress={handleLogin} />

            {loading && (
                <View style={styles.loading}>
                    <ActivityIndicator size="large" />
                </View>
            )}

            {/* 验证码弹窗 */}
            <Modal
                visible={showCaptcha}
                animationType="slide"
                transparent={true}
            >
                <View style={styles.modalContainer}>
                    <View style={styles.modalContent}>
                        <CaptchaWebView
                            token="your_token_here"
                            onSuccess={handleCaptchaSuccess}
                            onFail={() => Alert.alert('提示', '验证失败')}
                            onUpdate={() => Alert.alert('提示', '请重新验证')}
                        />
                        <Button
                            title="取消"
                            onPress={() => setShowCaptcha(false)}
                        />
                    </View>
                </View>
            </Modal>
        </View>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
        padding: 20,
        justifyContent: 'center',
    },
    input: {
        height: 50,
        borderWidth: 1,
        borderColor: '#ddd',
        borderRadius: 8,
        marginBottom: 15,
        paddingHorizontal: 15,
    },
    loading: {
        ...StyleSheet.absoluteFillObject,
        backgroundColor: 'rgba(255,255,255,0.8)',
        justifyContent: 'center',
        alignItems: 'center',
    },
    modalContainer: {
        flex: 1,
        backgroundColor: 'rgba(0,0,0,0.5)',
        justifyContent: 'center',
        padding: 20,
    },
    modalContent: {
        backgroundColor: '#fff',
        borderRadius: 12,
        overflow: 'hidden',
        height: 400,
    },
});

export default LoginPage;
```

## 注意事项

1. **JS 加载**：验证码 JS 必须从官方 URL 加载，避免下载到本地，否则会导致验证码无法正常更新
2. **HTTPS**：确保 WebView 加载的页面使用 HTTPS 协议
3. **跨域**：如果从本地 HTML 加载，可能需要处理跨域相关配置
4. **Token 获取**：生产环境中建议从后端服务器动态获取验证码 Token
5. **二次验证**：前端验证成功后，务必将票据传到后端进行二次校验

## 参考文档

- [Buyan-Captcha 官方文档](https://qaqbuyan.com:88/buyan_captcha_intro.html)
- [React Native WebView 文档](https://github.com/react-native-webview/react-native-webview)