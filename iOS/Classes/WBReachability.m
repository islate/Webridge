//
//  WBReachability.m
//  Webridge
//
//  Created by yize lin on 15-3-25.
//

#import "WBReachability.h"

#import "AFNetworkReachabilityManager.h"

NSString * const WBReachabilityDidChangeNotification = @"webridge.networking.reachability.change";

@interface WBReachability ()

@property (nonatomic, strong) AFNetworkReachabilityManager *reachabilityManager;

@end

@implementation WBReachability

+ (instancetype)sharedReachability
{
    static id               _sharedInstance = nil;
    static dispatch_once_t  once = 0;
    
    dispatch_once(&once, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.reachabilityManager = [AFNetworkReachabilityManager sharedManager];
        [self.reachabilityManager startMonitoring];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reachabilityChanged:(NSNotification *)note
{
    [[NSNotificationCenter defaultCenter] postNotificationName:WBReachabilityDidChangeNotification object:nil];
}

- (BOOL)isNetworkWiFi
{
    return [self.reachabilityManager isReachableViaWiFi];
}

- (BOOL)isNetwork3Gor2G
{
    return [self.reachabilityManager isReachableViaWWAN];
}

- (BOOL)isNetworkBroken
{
    if (self.reachabilityManager.networkReachabilityStatus == AFNetworkReachabilityStatusUnknown)
    {
        return NO;
    }
    return ![self.reachabilityManager isReachable];
}

- (BOOL)isNetworkOK
{
    return [self.reachabilityManager isReachable];
}

@end
