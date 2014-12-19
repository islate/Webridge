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

@end
