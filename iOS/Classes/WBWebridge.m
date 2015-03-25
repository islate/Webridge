//
//  WBWebridge.m
//  Webridge
//
//  Created by linyize on 14/12/8.
//

#import "WBWebridge.h"

#import "WBUtils.h"
#import "WBWebView.h"

@interface WBWebridge ()

@property (nonatomic, assign) int sequence;
@property (nonatomic, strong) NSMutableDictionary *callbackDict;

- (void)nativeToJSCallback:(NSDictionary *)returnDict webView:(WKWebView *)webView;
- (void)jsToNative:(NSDictionary *)evalDict webView:(WKWebView *)webView;
- (BOOL)asyncExecuteForCommand:(NSString *)command params:(id)params sequence:(NSNumber *)sequence webView:(WKWebView *)webView;
- (void)executeForCommand:(NSString *)command params:(id)params sequence:(NSNumber *)sequence webView:(WKWebView *)webView;
- (void)callbackWithResult:(id)result error:(NSString *)error sequence:(NSNumber *)sequence webView:(WKWebView *)webView;

@end

@implementation WBWebridge

+ (instancetype)bridge
{
    return [[self alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _sequence = 0;
        _callbackDict = [NSMutableDictionary new];
    }
    return self;
}

- (NSNumber *)sequenceOfNativeToJSCallback:(WBWebridgeCompletionBlock)callback
{
    if (!callback)
    {
        return @(0);
    }
    
    @synchronized(self)
    {
        _sequence += 1;
        [_callbackDict setObject:callback forKey:@(_sequence)];
        return @(_sequence);
    }
}

- (void)removeSequence:(NSNumber *)sequence
{
    if (!sequence)
    {
        return;
    }
    
    @synchronized(self)
    {
        [_callbackDict removeObjectForKey:sequence];
    }
}

- (void)handleMessage:(WKScriptMessage *)message
{
    if (![message.body isKindOfClass:[NSDictionary class]])
    {
        return;
    }
    
    id returnDict = [message.body objectForKey:@"return"];
    if ([returnDict isKindOfClass:[NSDictionary class]])
    {
        // js返回值
        [self nativeToJSCallback:returnDict webView:message.webView];
        return;
    }
    
    id evalDict = [message.body objectForKey:@"eval"];
    if ([evalDict isKindOfClass:[NSDictionary class]])
    {
        // 执行原生方法
        [self jsToNative:evalDict webView:message.webView];
        return;
    }
}

- (void)nativeToJSCallback:(NSDictionary *)returnDict webView:(WKWebView *)webView
{
//    WBWebView *wbWebView = (WBWebView *)webView;
//    if (![wbWebView isKindOfClass:[WBWebView class]])
//    {
//        return;
//    }
    
    NSNumber *sequence = [returnDict objectForKey:@"sequence"];
    id result = [returnDict objectForKey:@"result"];
    
    if (!sequence || !result || sequence.integerValue == 0)
    {
        return;
    }
    
    WBWebridgeCompletionBlock callback = nil;
    @synchronized(self)
    {
        callback = [_callbackDict objectForKey:sequence];
        [_callbackDict removeObjectForKey:sequence];
    }
    
    if (callback)
    {
        callback(result, nil);
    }
}

- (void)jsToNative:(NSDictionary *)evalDict webView:(WKWebView *)webView
{
    NSString *command = [evalDict objectForKey:@"command"];
    id params = [evalDict objectForKey:@"params"];
    NSNumber *sequence = [evalDict objectForKey:@"sequence"];

    if (!command || !params)
    {
        return;
    }
    
    if (![self asyncExecuteForCommand:command params:params sequence:sequence webView:webView])
    {
        // 异步调用失败，尝试同步调用
        [self executeForCommand:command params:params sequence:sequence webView:webView];
    }
}

- (BOOL)asyncExecuteForCommand:(NSString *)command params:(id)params sequence:(NSNumber *)sequence webView:(WKWebView *)webView
{
    if (self.delegate == nil)
    {
        return NO;
    }
    
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
        [weakSelf callbackWithResult:result error:error.localizedDescription sequence:sequence webView:webView];
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
            
            [self callbackWithResult:nil error:error sequence:sequence webView:webView];
        }
    }
    
    return YES;
}

- (void)executeForCommand:(NSString *)command params:(id)params sequence:(NSNumber *)sequence webView:(WKWebView *)webView
{
    if (self.delegate == nil)
    {
        NSString *error = @"Webridge delegate is nil.";
        [self callbackWithResult:nil error:error sequence:sequence webView:webView];
        return;
    }
    
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
            
            [self callbackWithResult:result error:nil sequence:sequence webView:webView];
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
                
                [self callbackWithResult:nil error:error sequence:sequence webView:webView];
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
            [self callbackWithResult:nil error:error sequence:sequence webView:webView];
        }
    }
}

- (void)callbackWithResult:(id)result error:(NSString *)error sequence:(NSNumber *)sequence webView:(WKWebView *)webView
{
    if (!webView || !sequence)
    {
        return;
    }
    NSString *jsonResult = @"''";
    if (result)
    {
        jsonResult = [result stringForJavascript];
    }
    if (!error)
    {
        error = @"";
    }
    NSString *callbackJS = nil;
    @try {
        callbackJS = [NSString stringWithFormat:@"webridge.jsToNativeCallback(%@, %@, '%@')", sequence, jsonResult, error];
    }
    @catch (NSException *exception) {
        NSLog (@"Webridge generate callbackJS exception name:%@ reason:%@", [exception name], [exception reason]);
    }
    @finally {
        if (callbackJS.length > 0)
        {
            [webView evaluateJavaScript:callbackJS completionHandler:^(id object, NSError *error) {
                NSLog(@"object:%@ error:%@", object, error);
            }];
        }
    }
}

@end
