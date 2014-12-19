//
//  MockWKScriptMessage.h
//  Webridge
//
//  Created by linyize on 14/12/18.
//  Copyright (c) 2014年 eletech. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MockWebView.h"

@interface MockWKScriptMessage : NSObject

@property (nonatomic, strong) id body;

@property (nonatomic, weak) MockWKWebView *webView;

@end
