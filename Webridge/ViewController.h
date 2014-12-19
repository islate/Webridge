//
//  ViewController.h
//  Webridge
//
//  Created by linyize on 14/12/10.
//  Copyright (c) 2014年 eletech. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WBURI.h"
#import "WBWebView.h"
#import "WBWebridge.h"
#import "WebridgeDelegate.h"

typedef void (^WebViewFinishedBlock)(void);

@interface ViewController : UIViewController

@property (nonatomic, strong) WBWebView *webView;
@property (nonatomic, strong) WBWebridge *webridge;
@property (nonatomic, strong) WebridgeDelegate *webridgeDelegate;

// for unit test
@property (nonatomic, assign) BOOL webViewLoaded;
@property (nonatomic, copy) WebViewFinishedBlock webViewFinishedBlock;

@end

