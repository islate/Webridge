//
//  AppDelegate.m
//  Webridge
//
//  Created by linyize on 16-6-23.
//  Copyright (c) 2016年 islate. All rights reserved.
//

#import "AppDelegate.h"

#import "SlateURI.h"
#import "SlateWebridge.h"
#import "URIHandler.h"
#import "WebridgeHandler.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // 注册uri handler
    [SlateURI setPriorHandler:[URIHandler new]];
    
    // 设置scheme
    [SlateURI setScheme:@"slate"];
    
    // 注册bridge handler
    [[SlateWebridge sharedBridge] setPriorHandler:[WebridgeHandler new]];
    return YES;
}

@end
