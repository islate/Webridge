//
//  TestURIHandler.m
//  Webridge
//
//  Created by linyize on 14/12/18.
//  Copyright (c) 2014年 eletech. All rights reserved.
//

#import "TestURIHandler.h"


@implementation TestURIHandler

- (NSString *)scheme
{
    return @"slate";
}

- (void)unknownURI:(NSString *)uri
{
    NSLog(@"未能识别的uri %@", uri);
    
    _status = TestURIHandlerStatusUnknownURI;
    _currentCommand = nil;
    _currentParams = nil;
    _currentParamsArray = nil;
}

- (void)unknownCommand:(NSString *)command params:(NSString *)params paramsArray:(NSArray *)paramsArray
{
    NSLog(@"未能识别的command %@\n params %@\n paramsArray %@", command, params, paramsArray);
    
    _status = TestURIHandlerStatusUnknownCommand;
    _currentCommand = command;
    _currentParams = params;
    _currentParamsArray = paramsArray;
}

- (void)webCommand:(NSString *)command params:(NSString *)params paramsArray:(NSArray *)paramsArray
{
    NSLog(@"识别webCommand  params %@\n paramsArray %@", params, paramsArray);
    
    _status = TestURIHandlerStatusWebCommand;
    _currentCommand = command;
    _currentParams = params;
    _currentParamsArray = paramsArray;
}

- (void)articleCommand:(NSString *)command params:(NSString *)params paramsArray:(NSArray *)paramsArray
{
    NSLog(@"识别articleCommand  params %@\n paramsArray %@", params, paramsArray);
    
    _status = TestURIHandlerStatusArticleCommand;
    _currentCommand = command;
    _currentParams = params;
    _currentParamsArray = paramsArray;
}

@end
