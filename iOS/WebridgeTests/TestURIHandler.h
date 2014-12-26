//
//  TestURIHandler.h
//  Webridge
//
//  Created by linyize on 14/12/18.
//  Copyright (c) 2014年 eletech. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WBURI.h"

typedef NS_ENUM(NSInteger, TestURIHandlerStatus) {
    TestURIHandlerStatusUnknownURI = 0,
    TestURIHandlerStatusUnknownCommand,
    TestURIHandlerStatusWebCommand,
    TestURIHandlerStatusArticleCommand,
};

@interface TestURIHandler : NSObject <WBURIHandler>

@property (nonatomic, assign) TestURIHandlerStatus status;
@property (nonatomic, strong) NSString *currentCommand;
@property (nonatomic, strong) NSString *currentParams;
@property (nonatomic, strong) NSArray *currentParamsArray;

@end
