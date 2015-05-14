//
//  WBWebridge.h
//  Webridge
//
//  Created by linyize on 14/12/8.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

typedef void (^WBWebridgeCompletionBlock)(id result, NSError *error);

@protocol WBWebridgeDelegate <NSObject>
@optional
- (void)domReady:(id)params;

@end

@interface WBWebridge : NSObject

@property (nonatomic, weak) id<WBWebridgeDelegate> delegate;

+ (instancetype)bridge;

// 注册回调block，并获得序号
- (NSNumber *)sequenceOfNativeToJSCallback:(WBWebridgeCompletionBlock)callback;

// 移除序号对应的回调block
- (void)removeSequence:(NSNumber *)sequence;

// 处理webView得到的message
// 1、执行函数 或 2、得到返回值
- (void)handleMessage:(WKScriptMessage *)message;

@end
