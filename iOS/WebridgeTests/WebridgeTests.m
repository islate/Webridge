//
//  WebridgeTests.m
//  WebridgeTests
//
//  Created by linyize on 16-6-23.
//  Copyright (c) 2016年 islate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "TestURIHandler.h"
#import "TestWebridgeDelegate.h"
#import "MockWebView.h"
#import "MockWKScriptMessage.h"
#import "SlateUtils.h"
#import "ViewController.h"
#import "AppDelegate.h"
#import "NSObject+webridge.h"

@interface WebridgeTests : XCTestCase

@property (nonatomic, strong) SlateWebridge *bridge;
@property (nonatomic, strong) TestURIHandler *handler;
@property (nonatomic, strong) TestWebridgeDelegate *bridgeDelegate;

@end

@implementation WebridgeTests

- (void)setUp {
    [super setUp];
    
    _handler = [[TestURIHandler alloc] init];
    [SlateURI setPriorHandler:_handler];
    
    _bridge = [SlateWebridge sharedBridge];
    _bridgeDelegate = [TestWebridgeDelegate new];

    [_bridge setPriorHandler:_bridgeDelegate];
}

- (void)tearDown {
    
    _handler = nil;
    _bridge = nil;
    _bridgeDelegate = nil;
    
    [super tearDown];
}

- (NSString *)bigParam
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *str = [[NSString alloc] initWithContentsOfFile:[bundle pathForResource:@"bigParam" ofType:@"txt"]
                                                    encoding:NSUTF8StringEncoding
                                                       error:nil];
    NSString *bigParam = @"";
    
    for (int i = 0; i < 10; i ++)
    {
        // 循环一次多100k
        bigParam = [bigParam stringByAppendingString:str];
    }
    
    return bigParam;
}

- (void)testStringForJavascript_nsstring
{
    NSString *object = @"123";
    NSString *jsonString = [object stringForJavascript];
    
    if (![jsonString isEqualToString:@"'123'"])
    {
        XCTAssert(NO, @"string wrong");
        return;
    }
    
    XCTAssert(YES, @"Pass");
}

- (void)testStringForJavascript_nsnumber
{
    NSNumber *object = @(123);
    NSString *jsonString = [object stringForJavascript];
    
    if (![jsonString isEqualToString:@"123"])
    {
        XCTAssert(NO, @"string wrong");
        return;
    }
    
    XCTAssert(YES, @"Pass");
}

- (void)testURI_web_1 {
    
    [SlateURI openURI:[NSURL URLWithString:@"slate://web/http://www.baidu.com/"]];
    
    if (_handler.status != TestURIHandlerStatusWebCommand)
    {
        XCTAssert(NO, @"status not match");
        return;
    }
    
    if (![_handler.currentCommand isEqualToString:@"web"])
    {
        XCTAssert(NO, @"command not match");
        return;
    }
    
    if (![_handler.currentParams isEqualToString:@"http://www.baidu.com/"])
    {
        XCTAssert(NO, @"Params not match");
        return;
    }
    
    XCTAssert(YES, @"Pass");
}

- (void)testURI_web_2 {
    
    [SlateURI openURI:[NSURL URLWithString:@"slate://web/http://www.baidu.com/index.php?data1=abc&data2=bbb#ttttt=1"]];
    
    if (_handler.status != TestURIHandlerStatusWebCommand)
    {
        XCTAssert(NO, @"status not match");
        return;
    }
    
    if (![_handler.currentCommand isEqualToString:@"web"])
    {
        XCTAssert(NO, @"command not match");
        return;
    }
    
    if (![_handler.currentParams isEqualToString:@"http://www.baidu.com/index.php?data1=abc&data2=bbb#ttttt=1"])
    {
        XCTAssert(NO, @"Params not match");
        return;
    }
    
    XCTAssert(YES, @"Pass");
}

- (void)testURI_article_1 {
    
    [SlateURI openURI:[NSURL URLWithString:@"slate://article/123/456/789/"]];
    
    if (_handler.status != TestURIHandlerStatusArticleCommand)
    {
        XCTAssert(NO, @"status not match");
        return;
    }
    
    if (![_handler.currentCommand isEqualToString:@"article"])
    {
        XCTAssert(NO, @"command not match");
        return;
    }
    
    if (![_handler.currentParams isEqualToString:@"123/456/789/"])
    {
        XCTAssert(NO, @"Params not match");
        return;
    }
    
    if ([_handler.currentParamsArray count] != 3)
    {
        XCTAssert(NO, @"ParamsArray count not match");
        return;
    }
    
    if (![[_handler.currentParamsArray objectAtIndex:0] isEqualToString:@"123"])
    {
        XCTAssert(NO, @"ParamsArray[0] not match");
        return;
    }
    
    if (![[_handler.currentParamsArray objectAtIndex:1] isEqualToString:@"456"])
    {
        XCTAssert(NO, @"ParamsArray[1] not match");
        return;
    }
    
    if (![[_handler.currentParamsArray objectAtIndex:2] isEqualToString:@"789"])
    {
        XCTAssert(NO, @"ParamsArray[2] not match");
        return;
    }
    
    XCTAssert(YES, @"Pass");
}

- (void)testURI_article_2 {
    
    [SlateURI openURI:[NSURL URLWithString:@"slate://article/123/456/789/1111()()"]];
    
    if (_handler.status != TestURIHandlerStatusArticleCommand)
    {
        XCTAssert(NO, @"status not match");
        return;
    }
    
    if (![_handler.currentCommand isEqualToString:@"article"])
    {
        XCTAssert(NO, @"command not match");
        return;
    }
    
    if (![_handler.currentParams isEqualToString:@"123/456/789/1111()()"])
    {
        XCTAssert(NO, @"Params not match");
        return;
    }
    
    if ([_handler.currentParamsArray count] != 4)
    {
        XCTAssert(NO, @"ParamsArray count not match");
        return;
    }
    
    if (![[_handler.currentParamsArray objectAtIndex:0] isEqualToString:@"123"])
    {
        XCTAssert(NO, @"ParamsArray[0] not match");
        return;
    }
    
    if (![[_handler.currentParamsArray objectAtIndex:1] isEqualToString:@"456"])
    {
        XCTAssert(NO, @"ParamsArray[1] not match");
        return;
    }
    
    if (![[_handler.currentParamsArray objectAtIndex:2] isEqualToString:@"789"])
    {
        XCTAssert(NO, @"ParamsArray[2] not match");
        return;
    }
    
    if (![[_handler.currentParamsArray objectAtIndex:3] isEqualToString:@"1111()()"])
    {
        XCTAssert(NO, @"ParamsArray[3] not match");
        return;
    }
    
    XCTAssert(YES, @"Pass");
}

- (void)testURI_http_unknown_scheme {
    
    [SlateURI openURI:[NSURL URLWithString:@"http://www.bbwc.cn/ddddd/article/123/456/789/"]];
    
    if (_handler.status == TestURIHandlerStatusUnknownURI)
    {
        XCTAssert(YES, @"Pass");
    }
    else
    {
        XCTAssert(NO, @"Fail");
    }
}

- (void)testURI_chinese {
    
    [SlateURI openURI:[NSURL URLWithString:[@"slate://article/汉字1/汉字2/汉字3" stringEscapedAsURI]]];
    
    if (_handler.status != TestURIHandlerStatusArticleCommand)
    {
        XCTAssert(NO, @"status not match");
        return;
    }
    
    if (![_handler.currentCommand isEqualToString:@"article"])
    {
        XCTAssert(NO, @"command not match");
        return;
    }
    
    if (![_handler.currentParams isEqualToString:@"汉字1/汉字2/汉字3"])
    {
        XCTAssert(NO, @"Params not match");
        return;
    }
    
    if ([_handler.currentParamsArray count] != 3)
    {
        XCTAssert(NO, @"ParamsArray count not match");
        return;
    }
    
    if (![[_handler.currentParamsArray objectAtIndex:0] isEqualToString:@"汉字1"])
    {
        XCTAssert(NO, @"ParamsArray[0] not match");
        return;
    }
    
    if (![[_handler.currentParamsArray objectAtIndex:1] isEqualToString:@"汉字2"])
    {
        XCTAssert(NO, @"ParamsArray[1] not match");
        return;
    }
    
    if (![[_handler.currentParamsArray objectAtIndex:2] isEqualToString:@"汉字3"])
    {
        XCTAssert(NO, @"ParamsArray[2] not match");
        return;
    }
    
    XCTAssert(YES, @"Pass");
}

/*
 * 要点：
 * 1、使用Mock方式进行单元测试
 *
 */
- (void)handleMessage:(MockWKScriptMessage *)mockMessage
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"webridge://%@", [[mockMessage.body JSONString] stringEscapedAsURIComponent]]];
    [_bridge handleWebridgeMessage:url webView:(UIWebView *)mockMessage.webView];
}

- (void)testBridge_jsToNative_peter {
    
    NSString *name = @"peter";
    
    MockWKWebView *webView = [MockWKWebView new];
    
    MockWKScriptMessage *mockMessage = [MockWKScriptMessage new];
    mockMessage.body = @{@"eval":@{@"command":@"testGetPerson",@"params":@{@"name":name},@"sequence":@(1)}};
    mockMessage.webView = webView;

    [self handleMessage:mockMessage];
    
    if (![[_bridgeDelegate.params objectForKey:@"name"] isEqualToString:name])
    {
        XCTAssert(NO, @"params name not match");
        return;
    }
    
    NSString *jsString = @"webridge.jsToNativeCallback(1, {\"name\":\"peter\",\"year\":18,\"gender\":\"male\"}, '')";
    if (![webView.javaScriptString isEqualToString:jsString])
    {
        XCTAssert(NO, @"callback not match");
        return;
    }
    
    XCTAssert(YES, @"Pass");
}

- (void)testBridge_jsToNative_jane {
    
    NSString *name = @"jane";
    
    MockWKWebView *webView = [MockWKWebView new];
    
    MockWKScriptMessage *mockMessage = [MockWKScriptMessage new];
    mockMessage.body = @{@"eval":@{@"command":@"testGetPerson",@"params":@{@"name":name},@"sequence":@(2)}};
    mockMessage.webView = webView;
    
    [self handleMessage:mockMessage];
    
    if (![[_bridgeDelegate.params objectForKey:@"name"] isEqualToString:name])
    {
        XCTAssert(NO, @"params name not match");
        return;
    }
    
    NSString *jsString = @"webridge.jsToNativeCallback(2, {\"name\":\"jane\",\"year\":21,\"gender\":\"female\"}, '')";
    if (![webView.javaScriptString isEqualToString:jsString])
    {
        XCTAssert(NO, @"callback not match");
        return;
    }
    
    XCTAssert(YES, @"Pass");
}

- (void)testBridge_jsToNative_nobody {
    
    NSString *name = @"nobody";
    
    MockWKWebView *webView = [MockWKWebView new];
    
    MockWKScriptMessage *mockMessage = [MockWKScriptMessage new];
    mockMessage.body = @{@"eval":@{@"command":@"testGetPerson",@"params":@{@"name":name},@"sequence":@(3)}};
    mockMessage.webView = webView;
    
    [self handleMessage:mockMessage];
    
    if (![[_bridgeDelegate.params objectForKey:@"name"] isEqualToString:name])
    {
        XCTAssert(NO, @"params name not match");
        return;
    }
    
    NSString *jsString = @"webridge.jsToNativeCallback(3, '', '')";
    if (![webView.javaScriptString isEqualToString:jsString])
    {
        XCTAssert(NO, @"callback not match");
        return;
    }
    
    XCTAssert(YES, @"Pass");
}

- (void)testBridge_jsToNative_nullCommandName {
    
    NSString *name = @"peter";
    
    MockWKWebView *webView = [MockWKWebView new];
    
    MockWKScriptMessage *mockMessage = [MockWKScriptMessage new];
    mockMessage.body = @{@"eval":@{@"command":@"",@"params":@{@"name":name},@"sequence":@(4)}};
    mockMessage.webView = webView;
    
    [self handleMessage:mockMessage];
    
    NSString *jsString = @"webridge.jsToNativeCallback(4, '', 'TestWebridgeDelegate doesn't know method: :')";
    if (![webView.javaScriptString isEqualToString:jsString])
    {
        XCTAssert(NO, @"callback not match");
        return;
    }
    
    XCTAssert(YES, @"Pass");
}

- (void)testBridge_jsToNative_wrongCommandName {
    
    NSString *name = @"peter";
    
    MockWKWebView *webView = [MockWKWebView new];
    
    MockWKScriptMessage *mockMessage = [MockWKScriptMessage new];
    mockMessage.body = @{@"eval":@{@"command":@"testGetPerson1",@"params":@{@"name":name},@"sequence":@(5)}};
    mockMessage.webView = webView;
    
    [self handleMessage:mockMessage];
    
    NSString *jsString = @"webridge.jsToNativeCallback(5, '', 'TestWebridgeDelegate doesn't know method: testGetPerson1:')";
    //NSLog(@"%@", webView.javaScriptString);
    if (![webView.javaScriptString isEqualToString:jsString])
    {
        XCTAssert(NO, @"callback not match");
        return;
    }
    
    XCTAssert(YES, @"Pass");
}

- (void)testBridge_jsToNative_wrongParams_exception {
    
    MockWKWebView *webView = [MockWKWebView new];
    
    MockWKScriptMessage *mockMessage = [MockWKScriptMessage new];
    mockMessage.body = @{@"eval":@{@"command":@"testGetPerson",@"params":@(111),@"sequence":@(6)}};
    mockMessage.webView = webView;
    
    [self handleMessage:mockMessage];
    
    NSString *jsStringPrefix = @"webridge.jsToNativeCallback(6, '', 'TestWebridgeDelegate exception on method: testGetPerson:";
    if (![webView.javaScriptString hasPrefix:jsStringPrefix])
    {
        XCTAssert(NO, @"callback not match");
        return;
    }
    
    XCTAssert(YES, @"Pass");
}

- (void)testBridge_jsToNativeAsync_jane {
    
    XCTestExpectation *jsExpectation = [self expectationWithDescription:@"jsToNativeAsync"];
    
    NSString *name = @"jane";
    
    MockWKWebView *webView = [MockWKWebView new];
    __weak typeof(webView) weakWebView = webView;
    webView.didEvaluateJavaScript = ^ {
        
        [jsExpectation fulfill];
        
        if (![[_bridgeDelegate.params objectForKey:@"name"] isEqualToString:name])
        {
            XCTAssert(NO, @"params name not match");
            return;
        }
        
        NSString *jsString = @"webridge.jsToNativeCallback(7, {\"name\":\"jane\",\"year\":21,\"gender\":\"female\"}, '')";
        if (![weakWebView.javaScriptString isEqualToString:jsString])
        {
            XCTAssert(NO, @"callback not match");
            return;
        }
        
        XCTAssert(YES, @"Pass");
    };
    
    MockWKScriptMessage *mockMessage = [MockWKScriptMessage new];
    mockMessage.body = @{@"eval":@{@"command":@"testGetPersonAsync",@"params":@{@"name":name},@"sequence":@(7)}};
    mockMessage.webView = webView;
    
    [self handleMessage:mockMessage];
    
    [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

- (void)testBridge_jsToNative_allKindsParam
{
    MockWKWebView *webView = [MockWKWebView new];
    
    MockWKScriptMessage *mockMessage = [MockWKScriptMessage new];
    mockMessage.webView = webView;
    
    // 无参数
    mockMessage.body = @{@"eval":@{@"command":@"testPassParam",@"params":@"",@"sequence":@(8)}};
    [self handleMessage:mockMessage];
    NSString *jsString = @"webridge.jsToNativeCallback(8, '', '')";
    if (![webView.javaScriptString isEqualToString:jsString])
    {
        XCTAssert(NO, @"empty param fault");
    }
    
    // 字符串参数
    mockMessage.body = @{@"eval":@{@"command":@"testPassParam",@"params":@"1111",@"sequence":@(8)}};
    [self handleMessage:mockMessage];
    jsString = @"webridge.jsToNativeCallback(8, '1111', '')";
    if (![webView.javaScriptString isEqualToString:jsString])
    {
        XCTAssert(NO, @"string param fault");
    }
    
    // 数值参数
    mockMessage.body = @{@"eval":@{@"command":@"testPassParam",@"params":@1111,@"sequence":@(8)}};
    [self handleMessage:mockMessage];
    jsString = @"webridge.jsToNativeCallback(8, 1111, '')";
    if (![webView.javaScriptString isEqualToString:jsString])
    {
        XCTAssert(NO, @"number param fault");
    }
    
    // 数组参数
    mockMessage.body = @{@"eval":@{@"command":@"testPassParam",@"params":@[@1,@2,@3,@4],@"sequence":@(8)}};
    [self handleMessage:mockMessage];
    jsString = @"webridge.jsToNativeCallback(8, [1,2,3,4], '')";
    if (![webView.javaScriptString isEqualToString:jsString])
    {
        XCTAssert(NO, @"array param fault");
    }
    
    // 字典参数
    mockMessage.body = @{@"eval":@{@"command":@"testPassParam",@"params":@{@"1":@1,@"2":@2},@"sequence":@(8)}};
    [self handleMessage:mockMessage];
    jsString = @"webridge.jsToNativeCallback(8, {\"1\":1,\"2\":2}, '')";
    if (![webView.javaScriptString isEqualToString:jsString])
    {
        XCTAssert(NO, @"dictionary param fault");
    }
    
    // 中文参数
    mockMessage.body = @{@"eval":@{@"command":@"testPassParam",@"params":@"中文",@"sequence":@(8)}};
    [self handleMessage:mockMessage];
    jsString = @"webridge.jsToNativeCallback(8, '中文', '')";
    if (![webView.javaScriptString isEqualToString:jsString])
    {
        XCTAssert(NO, @"chinese param fault");
    }
    
    // 超长参数
    NSString *bigParam = [self bigParam];
    mockMessage.body = @{@"eval":@{@"command":@"testPassParam",@"params":bigParam,@"sequence":@(8)}};
    [self handleMessage:mockMessage];
    jsString = [NSString stringWithFormat:@"webridge.jsToNativeCallback(8, '%@', '')",bigParam];
    if (![webView.javaScriptString isEqualToString:jsString])
    {
        XCTAssert(NO, @"chinese param fault");
    }
}

- (void)testBridge_jsToNativeAsync_nilParam
{
    XCTestExpectation *jsExpectation = [self expectationWithDescription:@"jsToNativeAsync_nilParam"];
    
    MockWKWebView *webView = [MockWKWebView new];
    __weak typeof(webView) weakWebView = webView;
    webView.didEvaluateJavaScript = ^ {
        
        [jsExpectation fulfill];
        
        NSString *jsString = @"webridge.jsToNativeCallback(9, '', '')";
        if (![weakWebView.javaScriptString isEqualToString:jsString])
        {
            XCTAssert(NO, @"callback not match");
            return;
        }
        
        XCTAssert(YES, @"Pass");
    };
    
    MockWKScriptMessage *mockMessage = [MockWKScriptMessage new];
    mockMessage.body = @{@"eval":@{@"command":@"testPassParamAsync",@"params":@"",@"sequence":@(9)}};
    mockMessage.webView = webView;
    
    [self handleMessage:mockMessage];
    
    [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

- (void)testBridge_jsToNativeAsync_stringParam
{
    XCTestExpectation *jsExpectation = [self expectationWithDescription:@"jsToNativeAsync_stringParam"];
    
    MockWKWebView *webView = [MockWKWebView new];
    __weak typeof(webView) weakWebView = webView;
    webView.didEvaluateJavaScript = ^ {
        
        [jsExpectation fulfill];
        
        NSString *jsString = @"webridge.jsToNativeCallback(9, '1111', '')";
        if (![weakWebView.javaScriptString isEqualToString:jsString])
        {
            XCTAssert(NO, @"callback not match");
            return;
        }
        
        XCTAssert(YES, @"Pass");
    };
    
    MockWKScriptMessage *mockMessage = [MockWKScriptMessage new];
    mockMessage.body = @{@"eval":@{@"command":@"testPassParamAsync",@"params":@"1111",@"sequence":@(9)}};
    mockMessage.webView = webView;
    
    [self handleMessage:mockMessage];
    
    [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

- (void)testBridge_jsToNativeAsync_numberParam
{
    XCTestExpectation *jsExpectation = [self expectationWithDescription:@"jsToNativeAsync_numberParam"];
    
    MockWKWebView *webView = [MockWKWebView new];
    __weak typeof(webView) weakWebView = webView;
    webView.didEvaluateJavaScript = ^ {
        
        [jsExpectation fulfill];
        
        NSString *jsString = @"webridge.jsToNativeCallback(9, 1111, '')";
        if (![weakWebView.javaScriptString isEqualToString:jsString])
        {
            XCTAssert(NO, @"callback not match");
            return;
        }
        
        XCTAssert(YES, @"Pass");
    };
    
    MockWKScriptMessage *mockMessage = [MockWKScriptMessage new];
    mockMessage.body = @{@"eval":@{@"command":@"testPassParamAsync",@"params":@1111,@"sequence":@(9)}};
    mockMessage.webView = webView;
    
    [self handleMessage:mockMessage];
    
    [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

- (void)testBridge_jsToNativeAsync_arrayParam
{
    XCTestExpectation *jsExpectation = [self expectationWithDescription:@"jsToNativeAsync_arrayParam"];
    
    MockWKWebView *webView = [MockWKWebView new];
    __weak typeof(webView) weakWebView = webView;
    webView.didEvaluateJavaScript = ^ {
        
        [jsExpectation fulfill];
        
        NSString *jsString = @"webridge.jsToNativeCallback(9, [1,2,3,4], '')";
        if (![weakWebView.javaScriptString isEqualToString:jsString])
        {
            XCTAssert(NO, @"callback not match");
            return;
        }
        
        XCTAssert(YES, @"Pass");
    };
    
    MockWKScriptMessage *mockMessage = [MockWKScriptMessage new];
    mockMessage.body = @{@"eval":@{@"command":@"testPassParamAsync",@"params":@[@1,@2,@3,@4],@"sequence":@(9)}};
    mockMessage.webView = webView;
    
    [self handleMessage:mockMessage];
    
    [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

- (void)testBridge_jsToNativeAsync_dictParam
{
    XCTestExpectation *jsExpectation = [self expectationWithDescription:@"jsToNativeAsync_dictParam"];
    
    MockWKWebView *webView = [MockWKWebView new];
    __weak typeof(webView) weakWebView = webView;
    webView.didEvaluateJavaScript = ^ {
        
        [jsExpectation fulfill];
        
        NSString *jsString = @"webridge.jsToNativeCallback(9, {\"1\":1,\"2\":2}, '')";
        if (![weakWebView.javaScriptString isEqualToString:jsString])
        {
            XCTAssert(NO, @"callback not match");
            return;
        }
        
        XCTAssert(YES, @"Pass");
    };
    
    MockWKScriptMessage *mockMessage = [MockWKScriptMessage new];
    mockMessage.body = @{@"eval":@{@"command":@"testPassParamAsync",@"params":@{@"1":@1,@"2":@2},@"sequence":@(9)}};
    mockMessage.webView = webView;
    
    [self handleMessage:mockMessage];
    
    [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

- (void)testBridge_jsToNativeAsync_chineseParam
{
    XCTestExpectation *jsExpectation = [self expectationWithDescription:@"jsToNativeAsync_chineseParam"];
    
    AppDelegate* appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    ViewController *viewController = (ViewController *)appDelegate.window.rootViewController;
    __weak typeof(viewController) weakViewController = viewController;
    
    WebViewFinishedBlock block = ^ {
        
        [weakViewController.webView evalJSCommand:@"wbTest.jsToNative"
                                         jsParams:nil
                                completionHandler:^(id param, NSError *error) {
                                    
                                    [jsExpectation fulfill];
                                    
                                    if (![param isEqualToString:@"中文"])
                                    {
                                        XCTAssert(NO, @"chinese param fault");
                                        return;
                                    }
                                    
                                    XCTAssert(YES, @"Pass");
                                }];
        
    };
    if (viewController.webViewLoaded)
    {
        block();
    }
    else
    {
        viewController.webViewFinishedBlock = block;
    }

    
    [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

- (void)testBridge_jsToNative_chineseParam
{
    XCTestExpectation *jsExpectation = [self expectationWithDescription:@"jsToNative_chineseParam"];
    
    AppDelegate* appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    ViewController *viewController = (ViewController *)appDelegate.window.rootViewController;
    __weak typeof(viewController) weakViewController = viewController;
    
    WebViewFinishedBlock block = ^ {
        
        [weakViewController.webView evalJSCommand:@"wbTest.jsToNative"
                                         jsParams:nil
                                completionHandler:^(id param, NSError *error) {
                                    
                                    [jsExpectation fulfill];
                                    
                                    if (![param isEqualToString:@"中文"])
                                    {
                                        XCTAssert(NO, @"chinese param fault");
                                        return;
                                    }
                                    
                                    XCTAssert(YES, @"Pass");
                                }];
        
    };
    if (viewController.webViewLoaded)
    {
        block();
    }
    else
    {
        viewController.webViewFinishedBlock = block;
    }
    
    [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

- (void)testBridge_jsToNativeAsync_longParam
{
    XCTestExpectation *jsExpectation = [self expectationWithDescription:@"jsToNativeAsync_longParam"];
    
    MockWKWebView *webView = [MockWKWebView new];
    __weak typeof(webView) weakWebView = webView;
    NSString *bigParam = [self bigParam];
    webView.didEvaluateJavaScript = ^ {
        
        [jsExpectation fulfill];
        
        NSString *jsString = [NSString stringWithFormat:@"webridge.jsToNativeCallback(9, '%@', '')",bigParam];
        if (![weakWebView.javaScriptString isEqualToString:jsString])
        {
            XCTAssert(NO, @"callback not match");
            return;
        }
        
        XCTAssert(YES, @"Pass");
    };
    
    MockWKScriptMessage *mockMessage = [MockWKScriptMessage new];
    mockMessage.body = @{@"eval":@{@"command":@"testPassParamAsync",@"params":bigParam,@"sequence":@(9)}};
    mockMessage.webView = webView;
    
    [self handleMessage:mockMessage];
    
    [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

/*
 * 要点：
 * 1、测试异步操作
 * 2、测试宿主App中的对象
 *
 */
- (void)testBridge_nativeToJS_ok {
    
    XCTestExpectation *jsExpectation = [self expectationWithDescription:@"nativeToJS"];
    
    AppDelegate* appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    ViewController *viewController = (ViewController *)appDelegate.window.rootViewController;
    __weak typeof(viewController) weakViewController = viewController;
    
    WebViewFinishedBlock block = ^ {
        
        [weakViewController.webView evalJSCommand:@"wbTest.jsGetPerson" jsParams:@{@"name":@"linyize"} completionHandler:^(id object, NSError *error) {
            
            [jsExpectation fulfill];
            
            if (![[object objectForKey:@"name"] isEqualToString:@"linyize"]) {
                XCTAssert(NO, @"name not match");
                return;
            }
            
            if (![[object objectForKey:@"gender"] isEqualToString:@"male"]) {
                XCTAssert(NO, @"gender not match");
                return;
            }
            
            if ([[object objectForKey:@"year"] integerValue] != 31) {
                XCTAssert(NO, @"year not match");
                return;
            }
            
            XCTAssert(YES, @"Pass");
        }];
    };
    if (viewController.webViewLoaded)
    {
        block();
    }
    else
    {
        viewController.webViewFinishedBlock = block;
    }
    
    [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

- (void)testBridge_nativeToJS_wrongJSCommand {
    
    XCTestExpectation *jsExpectation = [self expectationWithDescription:@"nativeToJS_wrongJSCommand"];
    
    AppDelegate* appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    ViewController *viewController = (ViewController *)appDelegate.window.rootViewController;
    __weak typeof(viewController) weakViewController = viewController;
    
    WebViewFinishedBlock block = ^ {
        
        [weakViewController.webView evalJSCommand:@"wbTest.jsGetPerson1" jsParams:@{@"name":@"linyize"} completionHandler:^(id object, NSError *error) {
            
            [jsExpectation fulfill];
            
            NSLog(@"object:%@  error:%@", object, error);
            
            if (object != nil) {
                XCTAssert(NO, @"object should be nil");
                return;
            }
            
            if (error.code != 4) {
                XCTAssert(NO, @"error code should be Code=4 \"A JavaScript exception occurred\"");
                return;
            }
            
            XCTAssert(YES, @"Pass");
        }];
    };
    if (viewController.webViewLoaded)
    {
        block();
    }
    else
    {
        viewController.webViewFinishedBlock = block;
    }
    
    [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

- (void)testBridge_nativeToJS_nullJSParams {
    
    XCTestExpectation *jsExpectation = [self expectationWithDescription:@"nativeToJS_nullJSParams"];
    
    AppDelegate* appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    ViewController *viewController = (ViewController *)appDelegate.window.rootViewController;
    __weak typeof(viewController) weakViewController = viewController;
    
    WebViewFinishedBlock block = ^ {
        
        [weakViewController.webView evalJSCommand:@"wbTest.jsGetPerson" jsParams:nil completionHandler:^(id object, NSError *error) {
            
            [jsExpectation fulfill];
            
            NSLog(@"object:%@  error:%@", object, error);
            
            if ([object objectForKey:@"name"] != nil) {
                XCTAssert(NO, @"name should be nil");
                return;
            }
            
            XCTAssert(YES, @"Pass");
        }];
    };
    if (viewController.webViewLoaded)
    {
        block();
    }
    else
    {
        viewController.webViewFinishedBlock = block;
    }
    
    [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

- (void)testBridge_nativeToJS_wrongJSParams {
    
    XCTestExpectation *jsExpectation = [self expectationWithDescription:@"nativeToJS_wrongJSParams"];
    
    AppDelegate* appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    ViewController *viewController = (ViewController *)appDelegate.window.rootViewController;
    __weak typeof(viewController) weakViewController = viewController;
    
    WebViewFinishedBlock block = ^ {
        
        [weakViewController.webView evalJSCommand:@"wbTest.jsGetPerson" jsParams:@"eeee" completionHandler:^(id object, NSError *error) {
            
            [jsExpectation fulfill];
            
            NSLog(@"object:%@  error:%@", object, error);
            
            if ([object objectForKey:@"name"] != nil) {
                XCTAssert(NO, @"name should be nil");
                return;
            }
            
            XCTAssert(YES, @"Pass");
        }];
    };
    if (viewController.webViewLoaded)
    {
        block();
    }
    else
    {
        viewController.webViewFinishedBlock = block;
    }
    
    [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

- (void)testBridge_nativeToJS_allKindsParam {
    
    XCTestExpectation *jsExpectation = [self expectationWithDescription:@"nativeToJS_allKindsParam"];
    
    AppDelegate* appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    ViewController *viewController = (ViewController *)appDelegate.window.rootViewController;
    __weak typeof(viewController) weakViewController = viewController;
    
    WebViewFinishedBlock block = ^ {
        
        [weakViewController.webView evalJSCommand:@"wbTest.jsSendParam" jsParams:@"" completionHandler:^(id object, NSError *error) {
            
            NSLog(@"object:%@  error:%@", object, error);
            
            if ([object length] != 0) {
                XCTAssert(NO, @"length should be 0");
                return;
            }
            
            XCTAssert(YES, @"Pass");
        }];
        
        [weakViewController.webView evalJSCommand:@"wbTest.jsSendParam" jsParams:@"1111" completionHandler:^(id object, NSError *error) {
            
            NSLog(@"object:%@  error:%@", object, error);
            
            if (![object isEqualToString:@"1111"]) {
                XCTAssert(NO, @"string should be '1111'");
                return;
            }
            
            XCTAssert(YES, @"Pass");
        }];
        
        [weakViewController.webView evalJSCommand:@"wbTest.jsSendParam" jsParams:@1111 completionHandler:^(id object, NSError *error) {
            
            NSLog(@"object:%@  error:%@", object, error);
            
            if ([object integerValue] != 1111) {
                XCTAssert(NO, @"number should be 1111");
                return;
            }
            
            XCTAssert(YES, @"Pass");
        }];
        
        [weakViewController.webView evalJSCommand:@"wbTest.jsSendParam" jsParams:@[@1,@2,@3,@4] completionHandler:^(id object, NSError *error) {
            
            NSLog(@"object:%@  error:%@", object, error);
            
            if ([object count] != 4 || [object[0] integerValue] != 1) {
                XCTAssert(NO, @"array should be [1,2,3,4]");
                return;
            }
            
            XCTAssert(YES, @"Pass");
        }];
        
        [weakViewController.webView evalJSCommand:@"wbTest.jsSendParam" jsParams:@{@"1":@1,@"2":@2} completionHandler:^(id object, NSError *error) {
            
            NSLog(@"object:%@  error:%@", object, error);
            
            if ([object count] != 2 || [object[@"1"] integerValue] != 1) {
                XCTAssert(NO, @"dict should be {1:1,2:2}");
                return;
            }
            
            XCTAssert(YES, @"Pass");
        }];
        
        NSString *bigParam = [self bigParam];
        [weakViewController.webView evalJSCommand:@"wbTest.jsSendParam" jsParams:bigParam completionHandler:^(id object, NSError *error) {
            
            NSLog(@"object:%@  error:%@", object, error);
            
            if (![object isEqualToString:bigParam]) {
                XCTAssert(NO, @"bigParam fault");
                return;
            }
            
            XCTAssert(YES, @"Pass");
        }];
        
        [weakViewController.webView evalJSCommand:@"wbTest.jsSendParam" jsParams:@"中文" completionHandler:^(id object, NSError *error) {
            
            [jsExpectation fulfill];
            
            NSLog(@"object:%@  error:%@", object, error);
            
            if (![object isEqualToString:@"中文"]) {
                XCTAssert(NO, @"chinese should be 中文");
                return;
            }
            
            XCTAssert(YES, @"Pass");
        }];
        
    };
    if (viewController.webViewLoaded)
    {
        block();
    }
    else
    {
        viewController.webViewFinishedBlock = block;
    }
    
    [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

- (void)testBridge_nativeToJSAsync_nilParam {
    
    XCTestExpectation *jsExpectation = [self expectationWithDescription:@"nativeToJSAsync_nilParam"];
    
    AppDelegate* appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    ViewController *viewController = (ViewController *)appDelegate.window.rootViewController;
    __weak typeof(viewController) weakViewController = viewController;
    
    WebViewFinishedBlock block = ^ {
        
        [weakViewController.webView evalJSCommand:@"wbTest.asyncJSSendParam" jsParams:@"" completionHandler:^(id object, NSError *error) {
            
            [jsExpectation fulfill];
            
            NSLog(@"object:%@  error:%@", object, error);
            
            if ([object length] != 0) {
                XCTAssert(NO, @"length should be 0");
                return;
            }
            
            XCTAssert(YES, @"Pass");
        }];
        
    };
    if (viewController.webViewLoaded)
    {
        block();
    }
    else
    {
        viewController.webViewFinishedBlock = block;
    }
    
    [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

- (void)testBridge_nativeToJSAsync_stringParam {
    
    XCTestExpectation *jsExpectation = [self expectationWithDescription:@"nativeToJSAsync_stringParam"];
    
    AppDelegate* appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    ViewController *viewController = (ViewController *)appDelegate.window.rootViewController;
    __weak typeof(viewController) weakViewController = viewController;
    
    WebViewFinishedBlock block = ^ {
        
        [weakViewController.webView evalJSCommand:@"wbTest.asyncJSSendParam" jsParams:@"1111" completionHandler:^(id object, NSError *error) {
            
            [jsExpectation fulfill];
            
            NSLog(@"object:%@  error:%@", object, error);
            
            if (![object isEqualToString:@"1111"]) {
                XCTAssert(NO, @"string should be '1111'");
                return;
            }
            
            XCTAssert(YES, @"Pass");
        }];
        
    };
    if (viewController.webViewLoaded)
    {
        block();
    }
    else
    {
        viewController.webViewFinishedBlock = block;
    }
    
    [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

- (void)testBridge_nativeToJSAsync_numberParam {
    
    XCTestExpectation *jsExpectation = [self expectationWithDescription:@"nativeToJSAsync_numberParam"];
    
    AppDelegate* appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    ViewController *viewController = (ViewController *)appDelegate.window.rootViewController;
    __weak typeof(viewController) weakViewController = viewController;
    
    WebViewFinishedBlock block = ^ {
        
        [jsExpectation fulfill];
        
        [weakViewController.webView evalJSCommand:@"wbTest.asyncJSSendParam" jsParams:@1111 completionHandler:^(id object, NSError *error) {
            
            NSLog(@"object:%@  error:%@", object, error);
            
            if ([object integerValue] != 1111) {
                XCTAssert(NO, @"number should be 1111");
                return;
            }
            
            XCTAssert(YES, @"Pass");
        }];
        
    };
    if (viewController.webViewLoaded)
    {
        block();
    }
    else
    {
        viewController.webViewFinishedBlock = block;
    }
    
    [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

- (void)testBridge_nativeToJSAsync_arrayParam {
    
    XCTestExpectation *jsExpectation = [self expectationWithDescription:@"nativeToJSAsync_arrayParam"];
    
    AppDelegate* appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    ViewController *viewController = (ViewController *)appDelegate.window.rootViewController;
    __weak typeof(viewController) weakViewController = viewController;
    
    WebViewFinishedBlock block = ^ {
        
        [weakViewController.webView evalJSCommand:@"wbTest.asyncJSSendParam" jsParams:@[@1,@2,@3,@4] completionHandler:^(id object, NSError *error) {
            
            [jsExpectation fulfill];
            
            NSLog(@"object:%@  error:%@", object, error);
            
            if ([object count] != 4 || [object[0] integerValue] != 1) {
                XCTAssert(NO, @"array should be [1,2,3,4]");
                return;
            }
            
            XCTAssert(YES, @"Pass");
        }];
        
    };
    if (viewController.webViewLoaded)
    {
        block();
    }
    else
    {
        viewController.webViewFinishedBlock = block;
    }
    
    [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

- (void)testBridge_nativeToJSAsync_dictParam {
    
    XCTestExpectation *jsExpectation = [self expectationWithDescription:@"nativeToJSAsync_dictParam"];
    
    AppDelegate* appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    ViewController *viewController = (ViewController *)appDelegate.window.rootViewController;
    __weak typeof(viewController) weakViewController = viewController;
    
    WebViewFinishedBlock block = ^ {
        
        [weakViewController.webView evalJSCommand:@"wbTest.asyncJSSendParam" jsParams:@{@"1":@1,@"2":@2} completionHandler:^(id object, NSError *error) {
            
            [jsExpectation fulfill];
            
            NSLog(@"object:%@  error:%@", object, error);
            
            if ([object count] != 2 || [object[@"1"] integerValue] != 1) {
                XCTAssert(NO, @"length should be 0");
                return;
            }
            
            XCTAssert(YES, @"Pass");
        }];
        
    };
    if (viewController.webViewLoaded)
    {
        block();
    }
    else
    {
        viewController.webViewFinishedBlock = block;
    }
    
    [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

- (void)testBridge_nativeToJSAsync_chineseParam {
    
    XCTestExpectation *jsExpectation = [self expectationWithDescription:@"nativeToJSAsync_chineseParam"];
    
    AppDelegate* appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    ViewController *viewController = (ViewController *)appDelegate.window.rootViewController;
    __weak typeof(viewController) weakViewController = viewController;
    
    WebViewFinishedBlock block = ^ {
        
        [weakViewController.webView evalJSCommand:@"wbTest.asyncJSSendParam" jsParams:@"中文" completionHandler:^(id object, NSError *error) {
            
            [jsExpectation fulfill];
            
            NSLog(@"object:%@  error:%@", object, error);
            
            if (![object isEqualToString:@"中文"]) {
                XCTAssert(NO, @"chinese should be 中文");
                return;
            }
            
            XCTAssert(YES, @"Pass");
        }];
        
    };
    if (viewController.webViewLoaded)
    {
        block();
    }
    else
    {
        viewController.webViewFinishedBlock = block;
    }
    
    [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

- (void)testBridge_nativeToJSAsync_longParam {

    XCTestExpectation *jsExpectation = [self expectationWithDescription:@"nativeToJSAsync_longParam"];

    AppDelegate* appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    ViewController *viewController = (ViewController *)appDelegate.window.rootViewController;
    __weak typeof(viewController) weakViewController = viewController;

    WebViewFinishedBlock block = ^ {

        NSString *bigParam = [self bigParam];
        [weakViewController.webView evalJSCommand:@"wbTest.asyncJSSendParam" jsParams:bigParam completionHandler:^(id object, NSError *error) {

            [jsExpectation fulfill];

            NSLog(@"object:%@  error:%@", object, error);

            if (![object isEqualToString:bigParam]) {
                XCTAssert(NO, @"chinese should be 中文");
                return;
            }

            XCTAssert(YES, @"Pass");
        }];

    };
    if (viewController.webViewLoaded)
    {
        block();
    }
    else
    {
        viewController.webViewFinishedBlock = block;
    }

    [self waitForExpectationsWithTimeout:30.0 handler:nil];
}


//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
