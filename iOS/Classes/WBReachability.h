//
//  WBReachability.h
//  Webridge
//
//  Created by yize lin on 15-3-25.
//

#import <Foundation/Foundation.h>

extern NSString * const WBReachabilityDidChangeNotification;

/**
 *  网络状态检测
 */
@interface WBReachability : NSObject

+ (instancetype)sharedReachability;

- (BOOL)isNetworkWiFi;
- (BOOL)isNetwork3Gor2G;
- (BOOL)isNetworkBroken;
- (BOOL)isNetworkOK;

@end
