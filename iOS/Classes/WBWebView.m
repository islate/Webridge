//
//  WBWebView.m
//  Webridge
//
//  Created by linyize on 14/12/8.
//

#import "WBWebView.h"

#import "WBWebridge.h"
#import "WBUtils.h"

@interface WBWebView () <WKScriptMessageHandler>

@property (nonatomic, strong) WBWebridge *bridge;

@end

@implementation WBWebView

- (instancetype)initWithFrame:(CGRect)frame webridgeDelegate:(id)webridgeDelegate
{
    WKWebViewConfiguration *conf = [[WKWebViewConfiguration alloc] init];
    WKUserContentController *controller = [[WKUserContentController alloc] init];
    [controller addScriptMessageHandler:self name:@"webridge"];
    [conf setUserContentController:controller];
    
    self = [super initWithFrame:frame configuration:conf];
    if (self) {
        
        _bridge = [WBWebridge bridge];
        _bridge.delegate = webridgeDelegate;
    }
    return self;
}

- (void)evalJSCommand:(NSString *)jsCommand jsParams:(id)jsParams completionHandler:(void (^)(id, NSError *))completionHandler
{
    if (![NSThread isMainThread])
    {
        // 非主线程不允许调用
        return;
    }
    
    NSString *jsParamsString = @"''";
    if (jsParams)
    {
        jsParamsString = [jsParams stringForJavascript];
    }
    
    __weak typeof(self) weakSelf = self;
    NSNumber *sequence = [_bridge sequenceOfNativeToJSCallback:completionHandler];
    NSString *javaScriptString = [NSString stringWithFormat:@"webridge.nativeToJS('%@', %@, %@)", jsCommand, jsParamsString, sequence];
    [self evaluateJavaScript:javaScriptString completionHandler:^(id result, NSError *error) {
        if (error)
        {
            if (completionHandler)
            {
                completionHandler(nil, error);
            }
            [weakSelf.bridge removeSequence:sequence];
        }
    }];
}

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    [_bridge handleMessage:message];
}

@end
