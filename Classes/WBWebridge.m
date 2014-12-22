//
//  WBWebridge.m
//  Webridge
//
//  Created by linyize on 14/12/8.
//  Copyright (c) 2014年 eletech. All rights reserved.
//

#import "WBWebridge.h"

@interface NSInvocation (webridge)
- (id)returnValueAsObject;
@end

@interface NSObject (webridge)
- (NSString *)JSONString;
@end

@interface WBWebridge ()

- (void)callback:(NSString *)callback result:(id)result error:(NSString *)error message:(WKScriptMessage *)message;

@end

@implementation WBWebridge

+ (instancetype)bridge
{
    return [[self alloc] init];
}

- (void)executeFromMessage:(WKScriptMessage *)message
{
    if (self.delegate == nil)
    {
        return;
    }
    
    if (![message.body isKindOfClass:[NSDictionary class]])
    {
        return;
    }

    NSDictionary *body = [message.body objectForKey:@"body"];
    if (![body isKindOfClass:[NSDictionary class]])
    {
        return;
    }
    
    NSString *command = [body objectForKey:@"command"];
    id params = [body objectForKey:@"params"];
    NSString *callback = [body objectForKey:@"callback"];
    
    if ([self asyncExecuteForCommand:command params:params callback:callback message:message])
    {
        // 异步返回
        return;
    }
    
    // 同步返回
    [self executeForCommand:command params:params callback:callback message:message];
}

- (BOOL)asyncExecuteForCommand:(NSString *)command params:(id)params callback:(NSString *)callback message:(WKScriptMessage *)message
{
    NSInvocation *invocation = nil;
    
    NSString *methodName = [NSString stringWithFormat:@"%@:completion:", command];
    SEL selector = NSSelectorFromString(methodName);
    NSMethodSignature *signature = [[self.delegate class] instanceMethodSignatureForSelector:selector];
    
    if (signature == nil)
    {
        return NO;
    }
    
    __weak typeof(self) weakSelf = self;
    WBWebridgeCompletionBlock block = ^(id result, NSError *error) {
        [weakSelf callback:callback result:result error:error.localizedDescription message:message];
    };
    
    invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation retainArguments];
    invocation.selector = selector;
    invocation.target = self.delegate;
    [invocation setArgument:&params atIndex:2];
    [invocation setArgument:&block atIndex:3];
    
    if (invocation == nil || ![self.delegate respondsToSelector:selector])
    {
        return NO;
    }

    @try {
        [invocation invoke];
        NSLog(@"Webridge: %@ %@ %@", self.delegate, methodName, params);
    }
    @catch(NSException *exception) {
        NSLog (@"WebBridge exception on %@ %@", self.delegate, methodName);
        NSLog (@"%@ %@", [exception name], [exception reason]);
        NSLog (@"%@", [[exception callStackSymbols] componentsJoinedByString:@"\n"]);
        
        if (self.delegate)
        {
            NSString *error = [NSString stringWithFormat:@"%@ exception on method: %@",
                               NSStringFromClass([self.delegate class]),
                               methodName];
            error = [error stringByAppendingFormat:@"\nexception name:%@ reason:%@",
                     [exception name],
                     [exception reason]];
            
            [self callback:callback result:nil error:error message:message];
        }
    }
    
    return YES;
}

- (void)executeForCommand:(NSString *)command params:(id)params callback:(NSString *)callback message:(WKScriptMessage *)message
{
    NSInvocation *invocation = nil;
    
    NSString *methodName = [NSString stringWithFormat:@"%@:", command];
    SEL selector = NSSelectorFromString(methodName);
    NSMethodSignature *signature = [[self.delegate class] instanceMethodSignatureForSelector:selector];
    
    if (signature)
    {
        invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation retainArguments];
        invocation.selector = selector;
        invocation.target = self.delegate;
        [invocation setArgument:&params atIndex:2];
    }
    
    if (invocation && [self.delegate respondsToSelector:selector])
    {
        @try {
            [invocation invoke];
            NSLog(@"Webridge: %@ %@ %@", self.delegate, methodName, params);
            
            id result = [invocation returnValueAsObject];
            
            NSLog(@"result: %@", result);
            
            [self callback:callback result:result error:nil message:message];
        }
        @catch(NSException *exception) {
            NSLog (@"WebBridge exception on %@ %@", self.delegate, methodName);
            NSLog (@"%@ %@", [exception name], [exception reason]);
            NSLog (@"%@", [[exception callStackSymbols] componentsJoinedByString:@"\n"]);
            
            if (self.delegate)
            {
                NSString *error = [NSString stringWithFormat:@"%@ exception on method: %@",
                                   NSStringFromClass([self.delegate class]),
                                   methodName];
                error = [error stringByAppendingFormat:@"\nexception name:%@ reason:%@",
                         [exception name],
                         [exception reason]];
                
                [self callback:callback result:nil error:error message:message];
            }
        }
    }
    else
    {
        NSLog (@"WebBridge controller doesn't know how to run method: %@ %@", self.delegate, methodName);
        
        if (self.delegate)
        {
            NSString *error = [NSString stringWithFormat:@"%@ doesn't know method: %@",
                               NSStringFromClass([self.delegate class]),
                               methodName];
            [self callback:callback result:nil error:error message:message];
        }
    }
}

- (void)callback:(NSString *)callback result:(id)result error:(NSString *)error message:(WKScriptMessage *)message
{
    if (!message.webView || !callback || ![callback isKindOfClass:[NSString class]] || callback.length == 0)
    {
        return;
    }
    if (!result)
    {
        result = @"";
    }
    if (!error)
    {
        error = @"";
    }
    NSDictionary *resultDict = @{@"result": result, @"error": error};
    NSString *callbackJS = nil;
    @try {
        callbackJS = [NSString stringWithFormat:@"%@(%@)", callback, [resultDict JSONString]];
    }
    @catch (NSException *exception) {
        NSLog (@"Webridge generate callbackJS exception name:%@ reason:%@", [exception name], [exception reason]);
    }
    @finally {
        if (callbackJS.length > 0)
        {
            [message.webView evaluateJavaScript:callbackJS completionHandler:^(id object, NSError *error) {
                NSLog(@"object:%@ error:%@", object, error);
            }];
        }
    }
}

@end

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
