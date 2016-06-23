//
//  URIHandler.m
//  Webridge
//
//  Created by linyize on 16-6-23.
//  Copyright (c) 2016年 islate. All rights reserved.
//

#import "URIHandler.h"

@implementation URIHandler

- (void)webCommand:(NSString *)command
            params:(NSString *)params
       paramsArray:(NSArray *)paramsArray
        completion:(SlateURICompletionBlock)completion
{
    NSLog(@"识别webCommand\n  params %@\n paramsArray %@", params, paramsArray);
    
    NSString *message = [NSString stringWithFormat:@"识别webCommand\n  params %@\n paramsArray %@", params, paramsArray];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"测试结果" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)articleCommand:(NSString *)command
                params:(NSString *)params
           paramsArray:(NSArray *)paramsArray
            completion:(SlateURICompletionBlock)completion
{
    NSLog(@"识别articleCommand\n  params %@\n paramsArray %@", params, paramsArray);
    
    NSString *message = [NSString stringWithFormat:@"识别articleCommand\n  params %@\n paramsArray %@", params, paramsArray];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"测试结果" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

@end
