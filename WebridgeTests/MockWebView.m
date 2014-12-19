//
//  MockWebView.m
//  Webridge
//
//  Created by linyize on 14/12/18.
//  Copyright (c) 2014年 eletech. All rights reserved.
//

#import "MockWebView.h"

@implementation MockWKWebView

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *))completionHandler
{
    NSLog(@"MockWKWebView evaluateJavaScript %@ ", javaScriptString);
    
    _javaScriptString = javaScriptString;
    
    if (completionHandler) {
        completionHandler(@"123", nil);
    }
}

@end
