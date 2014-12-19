//
//  WBWebridge.h
//  Webridge
//
//  Created by linyize on 14/12/8.
//  Copyright (c) 2014年 eletech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface WBWebridge : NSObject

@property (nonatomic, weak) id delegate;

+ (instancetype)bridge;

- (void)executeFromMessage:(WKScriptMessage *)message;

@end
