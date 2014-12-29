//
//  WBWebView.h
//  Webridge
//
//  Created by linyize on 14/12/8.
//  Copyright (c) 2014年 eletech. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface WBWebView : WKWebView

- (instancetype)initWithFrame:(CGRect)frame webridgeDelegate:(id)webridgeDelegate;

// 原生代码 调用 js
- (void)evalJSCommand:(NSString *)jsCommand jsParams:(id)jsParams completionHandler:(void (^)(id, NSError *))completionHandler;

// 触发JSToNative测试
- (void)triggerJSToNativeTest:(NSString *)jsCommand completionHandler:(void (^)(id, NSError *))completionHandler;

@end
