//
//  WBUtils.m
//  Webridge
//
//  Created by linyize on 14/12/23.
//

#import "WBUtils.h"

#import <CommonCrypto/CommonDigest.h>

@implementation NSInvocation (webridge)

- (id)returnValueAsObject
{
    const char *methodReturnType = [[self methodSignature] methodReturnType];
    switch (*methodReturnType)
    {
        case 'c':
        {
            int8_t value;
            [self getReturnValue:&value];
            return [NSNumber numberWithChar:value];
        }
        case 'C':
        {
            uint8_t value;
            [self getReturnValue:&value];
            return [NSNumber numberWithUnsignedChar:value];
        }
        case 'i':
        {
            int32_t value;
            [self getReturnValue:&value];
            return [NSNumber numberWithInt:value];
        }
        case 'I':
        {
            uint32_t value;
            [self getReturnValue:&value];
            return [NSNumber numberWithUnsignedInt:value];
        }
        case 's':
        {
            int16_t value;
            [self getReturnValue:&value];
            return [NSNumber numberWithShort:value];
        }
        case 'S':
        {
            uint16_t value;
            [self getReturnValue:&value];
            return [NSNumber numberWithUnsignedShort:value];
        }
        case 'f':
        {
            float value;
            [self getReturnValue:&value];
            return [NSNumber numberWithFloat:value];
        }
        case 'd':
        {
            double value;
            [self getReturnValue:&value];
            return [NSNumber numberWithDouble:value];
        }
        case 'B':
        {
            uint8_t value;
            [self getReturnValue:&value];
            return [NSNumber numberWithBool:(BOOL)value];
        }
        case 'l':
        {
            long value;
            [self getReturnValue:&value];
            return [NSNumber numberWithLong:value];
        }
        case 'L':
        {
            unsigned long value;
            [self getReturnValue:&value];
            return [NSNumber numberWithUnsignedLong:value];
        }
        case 'q':
        {
            long long value;
            [self getReturnValue:&value];
            return [NSNumber numberWithLongLong:value];
        }
        case 'Q':
        {
            unsigned long long value;
            [self getReturnValue:&value];
            return [NSNumber numberWithUnsignedLongLong:value];
        }
        case '@':
        {
            __unsafe_unretained id value;
            [self getReturnValue:&value];
            return [value copy];
        }
        case 'v':
        case 'V':
        {
            return nil;
        }
        default:
        {
            return nil;
        }
    }
    return nil;
}

@end

@implementation NSObject (webridge)

- (NSString *)stringForJavascript
{
    if ([self isKindOfClass:[NSString class]])
    {
        return [NSString stringWithFormat:@"'%@'", self];
    }
    else if ([self isKindOfClass:[NSNumber class]])
    {
        return [NSString stringWithFormat:@"%@", self];
    }
    else {
        @try {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:kNilOptions error:nil];
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            return jsonString;
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception);
        }
        return nil;
    }
}

@end

@implementation NSString (webridge)

- (NSString *)encodeWBURI
{
    return (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self,
                                                                                  // NULL, (CFStringRef)@";/?:@&=$+{}<>,",
                                                                                  NULL, (CFStringRef)@";?@$+{}<>,",
                                                                                  CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)));
}

- (NSString *)decodeWBURI
{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef)self, CFSTR("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_.!~*'()"), kCFStringEncodingUTF8)) ;
}

@end

@implementation NSString (MD5)

- (NSString *)md5
{
    const char      *cStr = [self UTF8String];
    unsigned char   result[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(cStr, strlen(cStr), result);
    
    NSMutableString *resultStr = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
    {
        [resultStr appendFormat:@"%02x", result[i]];
    }
    
    return resultStr;
}

@end

@implementation NSString (json)

- (id)JSONObject
{
    if (self.length == 0)
    {
        return nil;
    }
    
    return [[self dataUsingEncoding:NSUTF8StringEncoding] JSONObject];
}

@end

@implementation NSData (json)

- (id)JSONObject
{
    if (self.length == 0)
    {
        return nil;
    }
    
    @try {
        return [NSJSONSerialization JSONObjectWithData:self options:kNilOptions error:nil];
    }
    @catch (NSException *exception) {
    }
    return nil;
}

@end

@implementation NSObject (json)

- (NSString *)JSONString
{
    @try {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:kNilOptions error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return jsonString;
    }
    @catch (NSException *exception) {
    }
    return nil;
}

@end

@implementation UIWebView (slate)

- (NSInteger)getiFrameCount
{
    NSString *script = @"function getiFrameCount() {"
    "  return document.querySelectorAll('iframe').length;"
    "}"
    "getiFrameCount();";
    NSString *result = [self stringByEvaluatingJavaScriptFromString:script];
    return [result integerValue];
}

- (NSString *)getiFrameSrcWithIndex:(NSUInteger)index
{
    NSString *script = [NSString stringWithFormat:
                        @"function getiFrameSrc() {"
                        "  return document.querySelectorAll('iframe')[%lu].src;"
                        "}"
                        "getiFrameSrc();", (unsigned long)index];
    NSString *result = [self stringByEvaluatingJavaScriptFromString:script];
    return result;
}

- (NSString *)metaTag:(NSString *)metaTagName
{
    NSString *getMetaTagJS = [NSString stringWithFormat:
                              @"function getMetaTag() {"
                              @"  var m = document.getElementsByTagName('meta');"
                              @"  for(var i in m) { "
                              @"    if(m[i].name == '%@') {"
                              @"      return m[i].content;"
                              @"    }"
                              @"  }"
                              @"  return '';"
                              @"}"
                              @"getMetaTag();", metaTagName];
    
    return [self stringByEvaluatingJavaScriptFromString:getMetaTagJS];
}

- (NSString *)title
{
    return [self stringByEvaluatingJavaScriptFromString:@"document.title"];
}

@end
