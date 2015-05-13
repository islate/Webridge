//
//  WBUIWebView.m
//  Webridge
//
//  Created by lin yize on 14-3-21.
//

#import "WBUIWebView.h"

#import "WBURI.h"
#import "WBURLProtocol.h"
#import "WBReachability.h"

@interface FakeWKWebView : NSObject

@property (nonatomic, weak) WBUIWebView *slateWebView;

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *))completionHandler;

@end


@interface FakeWKScriptMessage : NSObject

@property (nonatomic, strong) id body;

@property (nonatomic, weak) FakeWKWebView *webView;

@end

@interface WBUIWebView ()

@property (nonatomic, strong) WBWebridge *bridge;

@end

@implementation WBUIWebView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.allowsInlineMediaPlayback = YES;
        self.mediaPlaybackRequiresUserAction = NO;
        self.dataDetectorTypes = UIDataDetectorTypeNone;
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        //self.backgroundColor = [UIColor clearColor];
        //self.opaque = NO; // 让网页可以透明
        self.scalesPageToFit = YES;
        
        // 去掉默认阴影
        for (UIView *shadowView in self.scrollView.subviews)
        {
            if ([shadowView isKindOfClass:[UIImageView class]])
            {
                shadowView.hidden = YES;
            }
        }
        
        _bridge = [WBWebridge bridge];
    }
    return self;
}

- (void)setWebridgeDelegate:(id<WBWebridgeDelegate>)delegate
{
    _bridge.delegate = delegate;
}

- (BOOL)isWebridgeMessage:(NSURL *)URL
{
    if ([URL.scheme.lowercaseString isEqualToString:@"webridge"]) {
        return YES;
    }
    return NO;
}

- (void)handleWebridgeMessage:(NSURL *)URL
{
    NSString *urlString = URL.absoluteString;
    NSString *messageString = [urlString stringByReplacingOccurrencesOfString:@"webridge://" withString:@""];
    messageString = [messageString decodeWBURI];
    
    FakeWKWebView *webView = [FakeWKWebView new];
    webView.slateWebView = self;
    
    FakeWKScriptMessage *fakeMessage = [FakeWKScriptMessage new];
    fakeMessage.body = [messageString JSONObject];
    fakeMessage.webView = webView;
    
    [_bridge handleMessage:(WKScriptMessage *)fakeMessage];
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

    NSNumber *sequence = [_bridge sequenceOfNativeToJSCallback:completionHandler];
    NSString *javaScriptString = [NSString stringWithFormat:@"webridge.nativeToJS('%@', %@, %@)", jsCommand, jsParamsString, sequence];
    
    [self stringByEvaluatingJavaScriptFromString:javaScriptString];
}

- (BOOL)isiFrameURL:(NSURL *)url
{
    NSInteger count = [self getiFrameCount];
    for (NSInteger i = 0; i < count; i++)
    {
        NSString *iFrameURL = [self getiFrameSrcWithIndex:i];
        if (iFrameURL.length > 0)
        {
            if ([iFrameURL isEqualToString:url.absoluteString])
            {
                if (![WBURI canOpenURI:[NSURL URLWithString:iFrameURL]]
                    && ![url.scheme.lowercaseString isEqualToString:@"webridge"])
                {
                    // 不是wburi 或者 不是webridge消息
                    // 说明是个iFrame，要在webView内打开它
                    return YES;
                }
                break;
            }
        }
    }
    return NO;
}

#pragma mark - 初始化，设置ua

+ (void)initialize
{
    [super initialize];
    
    // 注册自定义NSURLProtocol
    [WBURLProtocol registerClass];
    
    // 开始观察网络状态
    [WBReachability sharedReachability];
    
    // 修改默认UserAgent
    [self setDefaultUserAgent];
    
    // 忽略SIGPIPE，避免SIGPIPE闪退
    signal(SIGPIPE, SIG_IGN);
}

static UIWebView* setDefaultUserAgentWebView = nil;
+ (void)setDefaultUserAgent
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // uiwebview必须在主线程使用
        if (!setDefaultUserAgentWebView)
        {
            setDefaultUserAgentWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
        }
        NSString *originalUserAgent = [setDefaultUserAgentWebView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
        
        if (originalUserAgent)
        {
            NSBundle *bundle = [NSBundle mainBundle];
            NSString *bundleName = [bundle objectForInfoDictionaryKey:@"CFBundleName"];
            NSString *appVersion = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
            NSString *slateUserAgent = [originalUserAgent stringByAppendingString:[NSString stringWithFormat:@" Webridge/1.0 %@/%@", bundleName, appVersion]];
            
            [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent": slateUserAgent}];
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            setDefaultUserAgentWebView = nil;
        });
    });
}

@end

@implementation FakeWKWebView

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *))completionHandler
{
    if (self.slateWebView) {
        NSString *result = [self.slateWebView stringByEvaluatingJavaScriptFromString:javaScriptString];
        if (completionHandler) {
            completionHandler(result, nil);
        }
    }
}

@end

@implementation FakeWKScriptMessage

@end
