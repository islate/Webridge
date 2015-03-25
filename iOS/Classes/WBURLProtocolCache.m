//
//  WBURLProtocolCache.m
//  Webridge
//
//  Created by yize lin on 12-7-19.
//

#import "WBURLProtocolCache.h"

#import "WBURLProtocol.h"
#import "WBUtils.h"

@interface WBURLProtocolCache ()

@property (nonatomic, strong) NSString *urlCacheFolderName;
@property (nonatomic, strong) NSString *urlCachePath;

@end

@implementation WBURLProtocolCache

+ (instancetype)defaultCache
{
    static id               _sharedInstance = nil;
    static dispatch_once_t  once = 0;
    
    dispatch_once(&once, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _urlCacheFolderName = @"URLCache";
        _urlCachePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:_urlCacheFolderName];
    }
    return self;
}

- (NSString *)cachePathWithURL:(NSURL *)url
{
    if (url == nil)
    {
        return @"";
    }

    // 通用存储路径
    NSString *cachePath = [_urlCachePath stringByAppendingPathComponent:url.host];
    return [cachePath stringByAppendingPathComponent:[url.absoluteString md5]];
}

- (BOOL)hasCacheWithURL:(NSURL *)url
{
    NSString *cachePath = [self cachePathWithURL:url];
    return [self hasCacheWithPath:cachePath];
}

- (NSData *)readCacheWithURL:(NSURL *)url
{
    NSString *cachePath = [self cachePathWithURL:url];
    return [self readCacheWithPath:cachePath];
}

- (BOOL)hasCacheWithPath:(NSString *)cachePath
{
    return [[NSFileManager defaultManager] fileExistsAtPath:cachePath];
}

- (NSData *)readCacheWithPath:(NSString *)cachePath
{
    return [NSData dataWithContentsOfFile:cachePath];
}

- (BOOL)writeCacheWithPath:(NSString *)cachePath data:(NSData *)data responseHeaders:(NSDictionary *)responseHeaders requestURL:(NSURL *)requestURL redirectRequestURL:(NSURL *)redirectRequestURL
{
    if (cachePath && data && responseHeaders && requestURL)
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:[cachePath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
        
        if ([data writeToFile:cachePath atomically:YES])
        {
            [self writeCacheHeader:responseHeaders cachePath:cachePath requestURL:requestURL redirectRequestURL:redirectRequestURL];
            return YES;
        }
    }
    return NO;
}

- (void)writeCacheHeader:(NSDictionary *)responseHeaders cachePath:(NSString *)cachePath requestURL:(NSURL *)requestURL redirectRequestURL:(NSURL *)redirectRequestURL
{
    if (responseHeaders && cachePath && requestURL
        && [responseHeaders isKindOfClass:[NSDictionary class]]
        && [cachePath isKindOfClass:[NSString class]]
        && [requestURL isKindOfClass:[NSURL class]])
    {
        NSMutableDictionary *mutableResponseHeaders = [NSMutableDictionary dictionaryWithDictionary:responseHeaders];
        
        if ([[self class] isResponseCompressed:mutableResponseHeaders])
        {
            [mutableResponseHeaders removeObjectForKey:@"Content-Encoding"];
        }
        
        NSString *date = [[[self class] rfc1123DateFormatter] stringFromDate:[NSDate date]];
        if (date)
        {
            [mutableResponseHeaders setObject:date forKey:WBURLProtocolFetchDateHeader];
        }
        if (requestURL.absoluteString)
        {
            [mutableResponseHeaders setObject:requestURL.absoluteString forKey:WBURLProtocolFetchURLHeader];
        }
        if (redirectRequestURL.absoluteString)
        {
            [mutableResponseHeaders setObject:redirectRequestURL.absoluteString forKey:WBURLProtocolRedirectURLHeader];
        }
        [mutableResponseHeaders writeToFile:[cachePath stringByAppendingString:@".header"] atomically:YES];
    }
}

- (void)clearCache
{
    [[NSFileManager defaultManager] removeItemAtPath:_urlCachePath error:nil];
}


#pragma mark - HTTP协议

// response是否gzip
+ (BOOL)isResponseCompressed:(NSDictionary *)responseHeaders
{
	NSString *encoding = [responseHeaders objectForKey:@"Content-Encoding"];
	return encoding && [encoding rangeOfString:@"gzip"].location != NSNotFound;
}

// 将时间转化为GMT rfc1123格式的字符串
+ (NSDateFormatter *)rfc1123DateFormatter
{
	static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
		[dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
		[dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss 'GMT'"];
    });
	return dateFormatter;
}

@end
