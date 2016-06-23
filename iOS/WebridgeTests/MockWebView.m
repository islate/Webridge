//
//  MockWebView.m
//  Webridge
//
//  Created by linyize on 16-6-23.
//  Copyright (c) 2016年 islate. All rights reserved.
//

#import "MockWebView.h"

@implementation MockWKWebView

- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)javaScriptString
{
    NSLog(@"MockWKWebView evaluateJavaScript %@ ", javaScriptString);
    
    _javaScriptString = javaScriptString;
    
    if (self.didEvaluateJavaScript) {
        self.didEvaluateJavaScript();
    }
    
    return @"";
}

@end
