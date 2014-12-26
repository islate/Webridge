//
//  TestWebridgeDelegate.h
//  Webridge
//
//  Created by linyize on 14/12/18.
//  Copyright (c) 2014年 eletech. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WBWebridge.h"

@interface TestWebridgeDelegate : NSObject <WBWebridgeDelegate>

@property (nonatomic, strong) NSDictionary *personDict;
@property (nonatomic, strong) NSDictionary *params;

@end
