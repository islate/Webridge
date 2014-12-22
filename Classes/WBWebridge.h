//
//  WBWebridge.h
//  Webridge
//
//  Created by linyize on 14/12/8.
//  Copyright (c) 2014年 eletech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

typedef void (^WBWebridgeCompletionBlock)(id result, NSError *error);

@protocol WBWebridgeDelegate <NSObject>
@end

@interface WBWebridge : NSObject

@property (nonatomic, weak) id<WBWebridgeDelegate> delegate;

+ (instancetype)bridge;

- (void)executeFromMessage:(WKScriptMessage *)message;

@end
