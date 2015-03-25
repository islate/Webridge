//
//  WBURLProtocol.h
//  Webridge
//
//  Created by yize lin on 15-3-25.
//

#import <Foundation/Foundation.h>

NSString* const WBURLProtocolRedirectURLHeader;
NSString* const WBURLProtocolFetchURLHeader;
NSString* const WBURLProtocolFetchDateHeader;
NSString* const WBURLProtocolNoCacheHeader;
NSString* const WBURLProtocolIgnoreCacheControlHeadersHeader;
NSString* const WBURLProtocolCacheNoExpireHeader;

/**
 *  自定义NSURLProtocol
 *  1、拦截HTTP请求
 *  2、实现自己的http缓存逻辑
 */
@interface WBURLProtocol : NSURLProtocol

+ (void) registerClass;

@end
