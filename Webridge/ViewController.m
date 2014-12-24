//
//  ViewController.m
//  Webridge
//
//  Created by linyize on 14/12/10.
//  Copyright (c) 2014年 eletech. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <WKNavigationDelegate>

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

    self.webView = [[WBWebView alloc] initWithFrame:self.view.bounds webridgeDelegate:self.webridgeDelegate];
    self.webView.navigationDelegate = self;
    [self.view addSubview:self.webView];
    
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"html.bundle"];
    NSURL *url = [NSURL fileURLWithPath:htmlPath];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [self.webView loadRequest:request];
}

@end
