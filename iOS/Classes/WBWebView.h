//
//  WBWebView.h
//  Webridge
//
//  Created by linyize on 14/12/8.
//

#import <WebKit/WebKit.h>

@interface WBWebView : WKWebView

- (instancetype)initWithFrame:(CGRect)frame webridgeDelegate:(id)webridgeDelegate;

// 原生代码 调用 js
- (void)evalJSCommand:(NSString *)jsCommand jsParams:(id)jsParams completionHandler:(void (^)(id, NSError *))completionHandler;

@end
