//
//  WBWebView.m
//  Webridge
//
//  Created by linyize on 14/12/8.
//  Copyright (c) 2014年 eletech. All rights reserved.
//

#import "WBWebView.h"

#import "WBWebridge.h"

@interface WBWebView () <WKScriptMessageHandler>

@property (nonatomic, strong) WBWebridge *bridge;

@end

@implementation WBWebView

- (instancetype)initWithFrame:(CGRect)frame webridgeDelegate:(id)webridgeDelegate
{
    WKWebViewConfiguration *conf = [[WKWebViewConfiguration alloc] init];
    WKUserContentController *controller = [[WKUserContentController alloc] init];
    [controller addScriptMessageHandler:self name:@"webridge"];
    [conf setUserContentController:controller];
    
    self = [super initWithFrame:frame configuration:conf];
    if (self) {
        
        _bridge = [WBWebridge bridge];
        _bridge.delegate = webridgeDelegate;
    }
    return self;
}

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    [_bridge executeFromMessage:message];
}

@end
