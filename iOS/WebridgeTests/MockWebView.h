//
//  MockWebView.h
//  Webridge
//
//  Created by linyize on 16-6-23.
//  Copyright (c) 2016年 islate. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^MockWKWebViewDidEvaluateJavaScriptBlock)(void);

@interface MockWKWebView : NSObject

@property (nonatomic, copy) MockWKWebViewDidEvaluateJavaScriptBlock didEvaluateJavaScript;
@property (nonatomic, strong) NSString *javaScriptString;

- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)javaScriptString;

@end
