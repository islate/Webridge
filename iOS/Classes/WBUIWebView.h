//
//  WBUIWebView.h
//  Webridge
//
//  Created by lin yize on 14-3-21.
//

#import <UIKit/UIKit.h>

#import "WBWebridge.h"
#import "WBUtils.h"

@interface WBUIWebView : UIWebView

- (void)setWebridgeDelegate:(id<WBWebridgeDelegate>)delegate;
- (BOOL)isWebridgeMessage:(NSURL *)URL;
- (void)handleWebridgeMessage:(NSURL *)URL;

- (void)evalJSCommand:(NSString *)jsCommand jsParams:(id)jsParams completionHandler:(void (^)(id, NSError *))completionHandler;

- (BOOL)isiFrameURL:(NSURL *)url;

@end
