//
//  MockWKScriptMessage.h
//  Webridge
//
//  Created by linyize on 16-6-23.
//  Copyright (c) 2016年 islate. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MockWebView.h"

@interface MockWKScriptMessage : NSObject

@property (nonatomic, strong) id body;

@property (nonatomic, weak) MockWKWebView *webView;

@end
