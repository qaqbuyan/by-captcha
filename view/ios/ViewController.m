#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.webView];
}

- (WKWebView *)webView {
    if (_webView == nil) {
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        WKPreferences *preference = [[WKPreferences alloc] init];
        preference.javaScriptEnabled = YES;
        preference.javaScriptCanOpenWindowsAutomatically = YES;
        config.preferences = preference;
        
        WKUserContentController *wkUController = [[WKUserContentController alloc] init];
        [wkUController addScriptMessageHandler:self name:@"jsToOcNoPrams"];
        [wkUController addScriptMessageHandler:self name:@"jsToOcWithPrams"];
        config.userContentController = wkUController;
        
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) configuration:config];
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"captcha" ofType:@"html"];
        NSString *htmlString = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        [_webView loadHTMLString:htmlString baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
    }
    return _webView;
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    
}

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSDictionary *parameter = message.body;
    
    if ([message.name isEqualToString:@"jsToOcWithPrams"]) {
        NSLog(@"验证票据：%@", parameter[@"params"]);
    }
    
    if ([message.name isEqualToString:@"jsToOcNoPrams"]) {
        NSLog(@"无参数调用");
    }
}

@end
