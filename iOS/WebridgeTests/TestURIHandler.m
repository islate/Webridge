//
//  TestURIHandler.m
//  Webridge
//
//  Created by linyize on 16-6-23.
//  Copyright (c) 2016年 islate. All rights reserved.
//

#import "TestURIHandler.h"


@implementation TestURIHandler

- (void)webCommand:(NSString *)command
            params:(NSString *)params
       paramsArray:(NSArray *)paramsArray
        completion:(SlateURICompletionBlock)completion
{
    NSLog(@"识别webCommand  params %@\n paramsArray %@", params, paramsArray);
    
    _status = TestURIHandlerStatusWebCommand;
    _currentCommand = command;
    _currentParams = params;
    _currentParamsArray = paramsArray;
}

- (void)articleCommand:(NSString *)command
                params:(NSString *)params
           paramsArray:(NSArray *)paramsArray
            completion:(SlateURICompletionBlock)completion
{
    NSLog(@"识别articleCommand  params %@\n paramsArray %@", params, paramsArray);
    
    _status = TestURIHandlerStatusArticleCommand;
    _currentCommand = command;
    _currentParams = params;
    _currentParamsArray = paramsArray;
}

@end
