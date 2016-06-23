//
//  TestWebridgeDelegate.h
//  Webridge
//
//  Created by linyize on 16-6-23.
//  Copyright (c) 2016年 islate. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SlateWebridge.h"

@interface TestWebridgeDelegate : NSObject <SlateWebridgeHandler>

@property (nonatomic, strong) NSDictionary *personDict;
@property (nonatomic, strong) NSDictionary *params;

@end
