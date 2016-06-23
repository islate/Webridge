//
//  TestWebridgeDelegate.m
//  Webridge
//
//  Created by linyize on 16-6-23.
//  Copyright (c) 2016年 islate. All rights reserved.
//

#import "TestWebridgeDelegate.h"

#import "SlateWebView.h"

@implementation TestWebridgeDelegate

- (instancetype)init
{
    self = [super init];
    if (self) {
        _personDict = @{ @"peter":@{@"name": @"peter", @"year":@(18), @"gender":@"male"},
                         @"jane":@{@"name": @"jane", @"year":@(21), @"gender":@"female"}};
    }
    return self;
}

#pragma mark - WBWebridgeDelegate

- (NSString *)testGetPerson:(NSDictionary *)params webView:(SlateWebView *)webView
{
    _params = params;
    
    NSString *name = [params objectForKey:@"name"];
    id person = [_personDict objectForKey:name];
    return person;
}

- (void)testGetPersonAsync:(NSDictionary *)params completion:(SlateWebridgeCompletionBlock)completion webView:(SlateWebView *)webView
{
    _params = params;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSString *name = [params objectForKey:@"name"];
        id person = [_personDict objectForKey:name];
        
        if (completion) {
            completion(person, nil);
        }
    });
}

- (id)testPassParam:(id)params
{
    return params;
}

- (void)testPassParamAsync:(id)params completion:(SlateWebridgeCompletionBlock)completion webView:(SlateWebView *)webView
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (completion) {
            completion(params, nil);
        }
    });
}

@end
