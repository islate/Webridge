//
//  WebridgeDelegate.m
//  Webridge
//
//  Created by linyize on 14/12/12.
//  Copyright (c) 2014年 eletech. All rights reserved.
//

#import "WebridgeDelegate.h"

@interface WebridgeDelegate ()

@property (nonatomic, strong) NSDictionary *personDict;

@end

@implementation WebridgeDelegate

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

- (NSString *)nativeGetPerson:(id)params
{
    NSString *name = [params objectForKey:@"name"];
    id person = [_personDict objectForKey:name];
    return person;
}

- (void)nativeShowAlert:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

@end
