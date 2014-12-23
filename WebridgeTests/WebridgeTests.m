//
//  WebridgeTests.m
//  WebridgeTests
//
//  Created by linyize on 14/12/10.
//  Copyright (c) 2014年 eletech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "WBURI.h"
#import "WBWebridge.h"
#import "TestURIHandler.h"
#import "TestWebridgeDelegate.h"
#import "MockWebView.h"
#import "MockWKScriptMessage.h"

#import "ViewController.h"
#import "AppDelegate.h"

@interface WebridgeTests : XCTestCase

@property (nonatomic, strong) WBWebridge *bridge;
@property (nonatomic, strong) TestURIHandler *handler;
@property (nonatomic, strong) TestWebridgeDelegate *bridgeDelegate;

@end

@implementation WebridgeTests

- (void)setUp {
    [super setUp];
    
    _handler = [[TestURIHandler alloc] init];
    [WBURI registerURIHandler:_handler];
    
    _bridge = [WBWebridge bridge];
    _bridgeDelegate = [TestWebridgeDelegate new];
    _bridge.delegate = _bridgeDelegate;
}

- (void)tearDown {

    _handler = nil;
    _bridge = nil;
    _bridgeDelegate = nil;
    
    [super tearDown];
}

- (void)testURI_web_1 {

    [WBURI openURI:[NSURL URLWithString:@"slate://web/http://www.baidu.com/"]];
    
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
    
    [WBURI openURI:[NSURL URLWithString:@"slate://web/http://www.baidu.com/index.php?data1=abc&data2=bbb#ttttt=1"]];
    
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

    [WBURI openURI:[NSURL URLWithString:@"slate://article/123/456/789/"]];

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
    
    [WBURI openURI:[NSURL URLWithString:@"slate://article/123/456/789/1111()()"]];
    
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

- (void)testURI_unknown_scheme {
    
    [WBURI openURI:[NSURL URLWithString:@"ddddd://article/123/456/789/"]];
    
    if (_handler.status == TestURIHandlerStatusUnknownURI)
    {
        XCTAssert(YES, @"Pass");
    }
    else
    {
        XCTAssert(NO, @"Fail");
    }
}

- (void)testURI_unknown_command {
    
    [WBURI openURI:[NSURL URLWithString:@"slate://ddddd/123/456/789/"]];
    
    if (_handler.status != TestURIHandlerStatusUnknownCommand)
    {
        XCTAssert(NO, @"status not match");
        return;
    }
    
    if (![_handler.currentCommand isEqualToString:@"ddddd"])
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

/*
 * 要点：
 * 1、使用Mock方式进行单元测试
 *
 */
- (void)testBridge_jsToNative_peter {
    
    NSString *name = @"peter";

    MockWKWebView *webView = [MockWKWebView new];
    
    MockWKScriptMessage *mockMessage = [MockWKScriptMessage new];
    mockMessage.body = @{@"body":@{@"command":@"testGetPerson",@"params":@{@"name":name},@"callback":@"testCallback"}};
    mockMessage.webView = webView;
    
    [_bridge executeFromMessage:(WKScriptMessage *)mockMessage];
    
    if (![[_bridgeDelegate.params objectForKey:@"name"] isEqualToString:name])
    {
        XCTAssert(NO, @"params name not match");
        return;
    }
    
    NSString *jsString = @"testCallback({\"result\":{\"name\":\"peter\",\"year\":18,\"gender\":\"male\"},\"error\":\"\"})";
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
    mockMessage.body = @{@"body":@{@"command":@"testGetPerson",@"params":@{@"name":name},@"callback":@"testCallback"}};
    mockMessage.webView = webView;
    
    [_bridge executeFromMessage:(WKScriptMessage *)mockMessage];
    
    if (![[_bridgeDelegate.params objectForKey:@"name"] isEqualToString:name])
    {
        XCTAssert(NO, @"params name not match");
        return;
    }
    
    NSString *jsString = @"testCallback({\"result\":{\"name\":\"jane\",\"year\":21,\"gender\":\"female\"},\"error\":\"\"})";
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
    mockMessage.body = @{@"body":@{@"command":@"testGetPerson",@"params":@{@"name":name},@"callback":@"testCallback"}};
    mockMessage.webView = webView;
    
    [_bridge executeFromMessage:(WKScriptMessage *)mockMessage];
    
    if (![[_bridgeDelegate.params objectForKey:@"name"] isEqualToString:name])
    {
        XCTAssert(NO, @"params name not match");
        return;
    }
    
    NSString *jsString = @"testCallback({\"result\":\"\",\"error\":\"\"})";
    NSLog(@"%@", webView.javaScriptString);
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
    mockMessage.body = @{@"body":@{@"command":@"",@"params":@{@"name":name},@"callback":@"testCallback"}};
    mockMessage.webView = webView;
    
    [_bridge executeFromMessage:(WKScriptMessage *)mockMessage];
    
    NSString *jsString = @"testCallback({\"result\":\"\",\"error\":\"TestWebridgeDelegate doesn't know method: :\"})";
    //NSLog(@"%@", webView.javaScriptString);
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
    mockMessage.body = @{@"body":@{@"command":@"testGetPerson1",@"params":@{@"name":name},@"callback":@"testCallback"}};
    mockMessage.webView = webView;
    
    [_bridge executeFromMessage:(WKScriptMessage *)mockMessage];
    
    NSString *jsString = @"testCallback({\"result\":\"\",\"error\":\"TestWebridgeDelegate doesn't know method: testGetPerson1:\"})";
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
    mockMessage.body = @{@"body":@{@"command":@"testGetPerson",@"params":@(111),@"callback":@"testCallback"}};
    mockMessage.webView = webView;
    
    [_bridge executeFromMessage:(WKScriptMessage *)mockMessage];
    
    NSString *jsStringPrefix = @"testCallback({\"result\":\"\",\"error\":\"TestWebridgeDelegate exception on method: testGetPerson:";
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
        
        NSString *jsString = @"testCallback({\"result\":{\"name\":\"jane\",\"year\":21,\"gender\":\"female\"},\"error\":\"\"})";
        if (![weakWebView.javaScriptString isEqualToString:jsString])
        {
            XCTAssert(NO, @"callback not match");
            return;
        }
        
        XCTAssert(YES, @"Pass");
    };
    
    MockWKScriptMessage *mockMessage = [MockWKScriptMessage new];
    mockMessage.body = @{@"body":@{@"command":@"testGetPersonAsync",@"params":@{@"name":name},@"callback":@"testCallback"}};
    mockMessage.webView = webView;
    
    [_bridge executeFromMessage:(WKScriptMessage *)mockMessage];
    
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

        [weakViewController.webView evaluateJavaScript:@"wbNativeToJS('jsGetPerson', {'name':'linyize'})" completionHandler:^(id object, NSError *error) {
            
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
        
        [weakViewController.webView evaluateJavaScript:@"wbNativeToJS('jsGetPerson1', {'name':'linyize'})" completionHandler:^(id object, NSError *error) {
            
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
        
        [weakViewController.webView evaluateJavaScript:@"wbNativeToJS('jsGetPerson', null)" completionHandler:^(id object, NSError *error) {
            
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

- (void)testBridge_nativeToJS_wrongJSParams {
    
    XCTestExpectation *jsExpectation = [self expectationWithDescription:@"nativeToJS_wrongJSParams"];
    
    AppDelegate* appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    ViewController *viewController = (ViewController *)appDelegate.window.rootViewController;
    __weak typeof(viewController) weakViewController = viewController;
    
    WebViewFinishedBlock block = ^ {
        
        [weakViewController.webView evaluateJavaScript:@"wbNativeToJS('jsGetPerson', 'eeee')" completionHandler:^(id object, NSError *error) {
            
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


//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
