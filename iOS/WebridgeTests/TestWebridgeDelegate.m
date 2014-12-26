//
//  TestWebridgeDelegate.m
//  Webridge
//
//  Created by linyize on 14/12/18.
//  Copyright (c) 2014年 eletech. All rights reserved.
//

#import "TestWebridgeDelegate.h"

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

- (NSString *)testGetPerson:(NSDictionary *)params
{
    _params = params;
    
    NSString *name = [params objectForKey:@"name"];
    id person = [_personDict objectForKey:name];
    return person;
}

- (void)testGetPersonAsync:(NSDictionary *)params completion:(WBWebridgeCompletionBlock)completion
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

@end
