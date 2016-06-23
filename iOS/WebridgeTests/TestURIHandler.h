//
//  TestURIHandler.h
//  Webridge
//
//  Created by linyize on 16-6-23.
//  Copyright (c) 2016年 islate. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SlateURI.h"

typedef NS_ENUM(NSInteger, TestURIHandlerStatus) {
    TestURIHandlerStatusUnknownURI = 0,
    TestURIHandlerStatusUnknownCommand,
    TestURIHandlerStatusWebCommand,
    TestURIHandlerStatusArticleCommand,
};

@interface TestURIHandler : NSObject <SlateURIHandler>

@property (nonatomic, assign) TestURIHandlerStatus status;
@property (nonatomic, strong) NSString *currentCommand;
@property (nonatomic, strong) NSString *currentParams;
@property (nonatomic, strong) NSArray *currentParamsArray;

@end
