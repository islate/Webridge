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

- (void)unknownURI:(NSString *)uri
{
    NSLog(@"未能识别的uri %@", uri);
}

- (void)unknownCommand:(NSString *)command params:(NSString *)params paramsArray:(NSArray *)paramsArray
{
    NSLog(@"未能识别的command %@ %@ %@", command, params, paramsArray);
}

- (void)webCommand:(NSString *)command params:(NSString *)params paramsArray:(NSArray *)paramsArray
{
    NSLog(@"识别webCommand  params %@\n paramsArray %@", params, paramsArray);
}

- (void)articleCommand:(NSString *)command params:(NSString *)params paramsArray:(NSArray *)paramsArray
{
    NSLog(@"识别articleCommand  params %@\n paramsArray %@", params, paramsArray);
}

@end
