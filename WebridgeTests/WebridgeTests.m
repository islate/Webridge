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

typedef NS_ENUM(NSInteger, TestURIHandlerStatus) {
    TestURIHandlerStatusUnknownURI = 0,
    TestURIHandlerStatusUnknownCommand,
    TestURIHandlerStatusWebCommand,
    TestURIHandlerStatusArticleCommand,
};

@interface TestURIHandler : NSObject <WBURIHandler>

@property (nonatomic, assign) TestURIHandlerStatus status;
@property (nonatomic, strong) NSString *currentCommand;
@property (nonatomic, strong) NSString *currentParams;
@property (nonatomic, strong) NSArray *currentParamsArray;

@end

@implementation TestURIHandler

- (NSString *)scheme
{
    return @"slate";
}

- (void)unknownURI:(NSString *)uri
{
    NSLog(@"未能识别的uri %@", uri);
    
    _status = TestURIHandlerStatusUnknownURI;
    _currentCommand = nil;
    _currentParams = nil;
    _currentParamsArray = nil;
}

- (void)unknownCommand:(NSString *)command params:(NSString *)params paramsArray:(NSArray *)paramsArray
{
    NSLog(@"未能识别的command %@\n params %@\n paramsArray %@", command, params, paramsArray);
    
    _status = TestURIHandlerStatusUnknownCommand;
    _currentCommand = command;
    _currentParams = params;
    _currentParamsArray = paramsArray;
}

- (void)webCommand:(NSString *)command params:(NSString *)params paramsArray:(NSArray *)paramsArray
{
    NSLog(@"识别webCommand  params %@\n paramsArray %@", params, paramsArray);
    
    _status = TestURIHandlerStatusWebCommand;
    _currentCommand = command;
    _currentParams = params;
    _currentParamsArray = paramsArray;
}

- (void)articleCommand:(NSString *)command params:(NSString *)params paramsArray:(NSArray *)paramsArray
{
    NSLog(@"识别articleCommand  params %@\n paramsArray %@", params, paramsArray);
    
    _status = TestURIHandlerStatusArticleCommand;
    _currentCommand = command;
    _currentParams = params;
    _currentParamsArray = paramsArray;
}

@end


@interface TestWebridgeDelegate : NSObject

@property (nonatomic, strong) id params;

@end

@implementation TestWebridgeDelegate

- (NSString *)getPerson:(id)params
{
    NSLog(@"getPerson:%@", params);
    _params = params;
    return @"123";
}

@end

@interface MockWKWebView : NSObject

@property (nonatomic, strong) NSString *javaScriptString;

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *))completionHandler;

@end

@implementation MockWKWebView

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *))completionHandler
{
    NSLog(@"MockWKWebView evaluateJavaScript %@ ", javaScriptString);
    
    _javaScriptString = javaScriptString;
    
    if (completionHandler) {
        completionHandler(@"123", nil);
    }
}

@end

@interface MockWKScriptMessage : NSObject

@property (nonatomic, strong) id body;

@property (nonatomic, weak) MockWKWebView *webView;

@end

@implementation MockWKScriptMessage

@end

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

- (void)testBridge {

    MockWKWebView *webView = [MockWKWebView new];
    
    MockWKScriptMessage *mockMessage = [MockWKScriptMessage new];
    mockMessage.body = @{@"body":@{@"command":@"getPerson",@"params":@{@"name":@"peter"},@"callback":@"wbCallback"}};
    mockMessage.webView = webView;
    
    [_bridge executeFromMessage:(WKScriptMessage *)mockMessage];
    
    NSString *name = @"peter";
    if (![[_bridgeDelegate.params objectForKey:@"name"] isEqualToString:name])
    {
        XCTAssert(NO, @"params name not match");
        return;
    }
    
    NSString *jsString = @"wbCallback({\"result\":\"123\",\"error\":\"\"})";
    if (![webView.javaScriptString isEqualToString:jsString])
    {
        XCTAssert(NO, @"callback not match");
        return;
    }
    
    XCTAssert(YES, @"Pass");
}


//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
