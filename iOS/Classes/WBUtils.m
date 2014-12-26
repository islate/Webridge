//
//  WBUtils.m
//  Webridge
//
//  Created by linyize on 14/12/23.
//  Copyright (c) 2014年 eletech. All rights reserved.
//

#import "WBUtils.h"

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
