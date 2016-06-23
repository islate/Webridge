//
//  ViewController.m
//  Webridge
//
//  Created by linyize on 16-6-23.
//  Copyright (c) 2016年 islate. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <SlateWebViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // for unit test
    _webViewLoaded = NO;
    
    self.webView = [[SlateWebView alloc] initWithFrame:self.view.bounds];
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"html.bundle"];
    NSURL *url = [NSURL fileURLWithPath:htmlPath];
    
    // test html5
    //url = [NSURL URLWithString:@"http://106.186.123.223/icalendar"];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

#pragma mark - SlateWebViewDelegate

- (void)domReady:(id)params webView:(SlateWebView *)webView
{
    [self.webView evalJSCommand:@"wbTest.jsGetPerson" jsParams:@{@"name":@"linyize"} completionHandler:^(id object, NSError *error) {
        NSLog(@"object:%@ error:%@", object, error);
    }];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    // for unit test
    _webViewLoaded = YES;
    if (self.webViewFinishedBlock) {
        self.webViewFinishedBlock();
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    SlateWebViewShouldLoadType type = [self.webView shouldStartLoadWithRequest:request navigationType:navigationType];
    if (type == SlateWebViewShouldLoadTypeBuiltin)
    {
        return YES;
    }
    else if (type == SlateWebViewShouldLoadTypeCustom)
    {
        return NO;
    }
    else if (type == SlateWebViewShouldLoadTypeAction)
    {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
    return YES;
}

@end
