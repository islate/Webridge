//
//  WBUtils.h
//  Webridge
//
//  Created by linyize on 14/12/23.
//  Copyright (c) 2014年 eletech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSInvocation (webridge)

- (id)returnValueAsObject;

@end

@interface NSObject (webridge)

- (NSString *)JSONString;

@end
