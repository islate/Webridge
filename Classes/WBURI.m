//
//  WBURI.m
//  Webridge
//
//  Created by linyize on 14/12/8.
//  Copyright (c) 2014年 eletech. All rights reserved.
//

#import "WBURI.h"

@interface WBURI ()

+ (void)openURIInMainThread:(NSURL *)uri;
+ (void)handleURICommand:(NSString *)command params:(NSString *)params paramsArray:(NSArray *)paramsArray;

@end

@implementation WBURI

static id <WBURIHandler> _handler = nil;

+ (void)registerURIHandler:(id <WBURIHandler>)handler
{
    _handler = handler;
}

+ (id<WBURIHandler>)handler
{
    return _handler;
}

+ (BOOL)canOpenURI:(NSURL *)uri
{
    NSString    *scheme = [uri scheme];
    NSString    *path = [uri path];
    
    return [scheme isEqualToString:[_handler scheme]] ||
    ([scheme isEqualToString:@"http"] && [path hasPrefix:[NSString stringWithFormat:@"/%@", [_handler scheme]]]);
}

// 例子:     url=@"slate://article/4/12/238/" 或 @"http://www.xxx.com/slate/article/4/12/238/"
//          command=@"article"
//          params=@"/4/12/238"

+ (void)openURI:(NSURL *)uri
{

    if (_handler == nil)
    {
        return;
    }
    
    if ([NSThread isMainThread])
    {
        [self openURIInMainThread:uri];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           [self openURIInMainThread:uri];
                       });
    }
}

+ (void)openURIInMainThread:(NSURL *)uri
{
    NSString *scheme = [uri scheme];
    NSString *path = [uri path];
    NSString *command = @"";
    NSString *params = @"";
    
    if ([scheme isEqualToString:[_handler scheme]])
    {
        // 形如 slate://article/4/12/238/
        command = [uri host];
        params = [uri path];
    }
    else if ([scheme isEqualToString:@"http"] && [path hasPrefix:[NSString stringWithFormat:@"/%@", [_handler scheme]]])
    {
        // 形如 http://www.xxx.com/slate/article/4/12/238/
        NSArray *pathArray = [[uri path] componentsSeparatedByString:@"/"];
        
        if ([pathArray count] < 3)
        {
            return;
        }
        
        command = [pathArray objectAtIndex:2];
        NSUInteger from = [[_handler scheme] length] + command.length + 2;
        
        if ([uri path].length > from)
        {
            params = [[uri path] substringFromIndex:from];
        }
    }
    else
    {
        [_handler unknownURI:uri];
        return;
    }
    
    NSMutableArray *paramsArray = [NSMutableArray arrayWithArray:[params componentsSeparatedByString:@"/"]];
    for (NSString *param in [paramsArray copy])
    {
        if (param.length == 0)
        {
            [paramsArray removeObject:param];
        }
    }
    
    if ([params rangeOfString:@"/"].location == 0)
    {
        params = [params substringFromIndex:1];
    }
    
    // open uri
    [self handleURICommand:command params:params paramsArray:paramsArray];
}

+ (void)handleURICommand:(NSString *)command params:(NSString *)params paramsArray:(NSArray *)paramsArray
{
    NSString *commandSelectorString = [NSString stringWithFormat:@"%@Command:params:paramsArray:",command];
    SEL commandSelector = NSSelectorFromString (commandSelectorString);
    NSMethodSignature *signature = [[_handler class] instanceMethodSignatureForSelector:commandSelector];
    NSInvocation *invocation = nil;
    NSArray *args = [NSArray arrayWithObjects:command ? command : @"",
                     params ? params : @"",
                     paramsArray ? paramsArray : @"",
                     nil];
    
    if (signature)
    {
        invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation retainArguments];
        invocation.selector = commandSelector;
        invocation.target = _handler;
        [args enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
            [invocation setArgument:&obj atIndex:idx + 2];
        }];
    }
    
    if (invocation && [_handler respondsToSelector:commandSelector])
    {
        @try {
            [invocation invoke];
        }
        @catch(NSException *exception) {
            NSLog (@"NSInvocation exception on %@ %@", _handler, commandSelectorString);
            NSLog (@"%@ %@", [exception name], [exception reason]);
            NSLog (@"%@", [[exception callStackSymbols] componentsJoinedByString:@"\n"]);
        }
    }
    else
    {
        NSLog (@"NSInvocation doesn't know how to run method: %@ %@", _handler, commandSelectorString);
        
        [_handler unknownCommand:command params:params paramsArray:paramsArray];
    }
}

@end
