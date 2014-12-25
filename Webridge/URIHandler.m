//
//  URIHandler.m
//  Webridge
//
//  Created by linyize on 14/12/12.
//  Copyright (c) 2014年 eletech. All rights reserved.
//

#import "URIHandler.h"

@implementation URIHandler

#pragma mark - WBURIHandler

- (NSString *)scheme
{
    return @"slate";
}

- (void)unknownURI:(NSURL *)uri
{
    NSLog(@"未能识别的uri %@", uri);
}

- (void)unknownCommand:(NSString *)command params:(NSString *)params paramsArray:(NSArray *)paramsArray
{
    NSLog(@"未能识别的command %@\n params %@\n paramsArray %@", command, params, paramsArray);
}

- (void)webCommand:(NSString *)command params:(NSString *)params paramsArray:(NSArray *)paramsArray
{
    NSLog(@"识别webCommand\n  params %@\n paramsArray %@", params, paramsArray);
    
    NSString *message = [NSString stringWithFormat:@"识别webCommand\n  params %@\n paramsArray %@", params, paramsArray];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"测试结果" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)articleCommand:(NSString *)command params:(NSString *)params paramsArray:(NSArray *)paramsArray
{
    NSLog(@"识别articleCommand\n  params %@\n paramsArray %@", params, paramsArray);
    
    NSString *message = [NSString stringWithFormat:@"识别articleCommand\n  params %@\n paramsArray %@", params, paramsArray];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"测试结果" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

@end
