//
//  ViewController.m
//  Webridge
//
//  Created by linyize on 14/12/10.
//  Copyright (c) 2014年 eletech. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <WKNavigationDelegate, UIWebViewDelegate>

@end

@implementation ViewController

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSURL *url = navigationAction.request.URL;
    if ([WBURI canOpenURI:url]) {
        if (decisionHandler) {
            [WBURI openURI:url];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    
    //this is a 'new window action' (aka target="_blank") > open this URL externally. If we´re doing nothing here, WKWebView will also just do nothing. Maybe this will change in a later stage of the iOS 8 Beta
    if (!navigationAction.targetFrame) {
        NSURL *url = navigationAction.request.URL;
        UIApplication *app = [UIApplication sharedApplication];
        if ([app canOpenURL:url]) {
            [app openURL:url];
            if (decisionHandler) {
                decisionHandler(WKNavigationActionPolicyCancel);
            }
            return;
        }
    }
    
    if (decisionHandler) {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [self.webView evalJSCommand:@"wbTest.jsGetPerson" jsParams:@{@"name":@"linyize"} completionHandler:^(id object, NSError *error) {
        NSLog(@"object:%@ error:%@", object, error);
    }];
    
    // for unit test
    _webViewLoaded = YES;
    if (self.webViewFinishedBlock) {
        self.webViewFinishedBlock();
    }
}

#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _webViewLoaded = NO;
    _webridgeDelegate = [WebridgeDelegate new];
    
    BOOL useWKWebView = YES;
    if (useWKWebView)
    {
        self.webView = [[WBWebView alloc] initWithFrame:self.view.bounds webridgeDelegate:self.webridgeDelegate];
        self.webView.navigationDelegate = self;
        [self.view addSubview:self.webView];
        
        NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"html.bundle"];
        NSURL *url = [NSURL fileURLWithPath:htmlPath];
        
        // test html5
        //url = [NSURL URLWithString:@"http://106.186.123.223/icalendar"];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        [self.webView loadRequest:request];
    }
    else // uiwebview
    {
        self.uiWebView = [[WBUIWebView alloc] initWithFrame:self.view.bounds];
        [self.uiWebView setWebridgeDelegate:self.webridgeDelegate];
        self.uiWebView.delegate = self;
        [self.view addSubview:self.uiWebView];
        
        NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"html.bundle"];
        NSURL *url = [NSURL fileURLWithPath:htmlPath];
        
        // test html5
        //url = [NSURL URLWithString:@"http://106.186.123.223/icalendar"];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.uiWebView loadRequest:request];
    }
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    // todo: startAnimating
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    // todo: stopAnimating
    
    [self.uiWebView evalJSCommand:@"wbTest.jsGetPerson" jsParams:@{@"name":@"linyize"} completionHandler:^(id object, NSError *error) {
        NSLog(@"object:%@ error:%@", object, error);
    }];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    // todo: stopAnimating  and  showError / retry button
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL    clickNavType = (navigationType == UIWebViewNavigationTypeLinkClicked);
    BOOL    otherNavType = (navigationType == UIWebViewNavigationTypeOther);
    
    if (request.URL.fragment && webView.request.mainDocumentURL)
    {
        NSURL *oldURL = [[NSURL alloc] initWithScheme:webView.request.mainDocumentURL.scheme host:webView.request.mainDocumentURL.host path:webView.request.mainDocumentURL.path];
        NSURL *anchorURL = [[NSURL alloc] initWithScheme:request.URL.scheme host:request.URL.host path:request.URL.path];
        if ([oldURL.absoluteString isEqualToString:anchorURL.absoluteString])
        {
            // 打开本页锚点  linyize 2014.09.15
            return YES;
        }
    }
    
    if (clickNavType || otherNavType)
    {
        if ([[request.URL.scheme lowercaseString] isEqualToString:@"tel"])
        {
            // 拨打电话
            return YES;
        }
        
        if ([[request.URL.scheme lowercaseString] isEqualToString:@"mailto"])
        {
            // todo: 写邮件
            return NO;
        }
        
        if ([[request.URL.host lowercaseString] isEqualToString:@"itunes.apple.com"])
        {
            // 苹果商店链接
            [[UIApplication sharedApplication] openURL:request.URL];
            return NO;
        }
        
        if (otherNavType && [self.uiWebView isiFrameURL:request.URL])
        {
            // 加载iframe
            return YES;
        }
        
        if ([self.uiWebView isWebridgeMessage:request.URL])
        {
            // webridge 消息
            [self.uiWebView handleWebridgeMessage:request.URL];
            return NO;
        }
        
        if ([WBURI canOpenURI:request.URL])
        {
            // 自定义uri
            [WBURI openURI:request.URL];
            return NO;
        }
    }
    
    return YES;
}

@end
