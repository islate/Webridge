//
//  MockWebView.h
//  Webridge
//
//  Created by linyize on 14/12/18.
//  Copyright (c) 2014年 eletech. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^MockWKWebViewDidEvaluateJavaScriptBlock)(void);

@interface MockWKWebView : NSObject

@property (nonatomic, copy) MockWKWebViewDidEvaluateJavaScriptBlock didEvaluateJavaScript;
@property (nonatomic, strong) NSString *javaScriptString;

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *))completionHandler;

@end
