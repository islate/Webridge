//
//  ViewController.h
//  Webridge
//
//  Created by linyize on 16-6-23.
//  Copyright (c) 2016年 islate. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SlateWebView.h"

typedef void (^WebViewFinishedBlock)(void);

@interface ViewController : UIViewController

@property (nonatomic, strong) SlateWebView *webView;

// for unit test
@property (nonatomic, assign) BOOL webViewLoaded;
@property (nonatomic, copy) WebViewFinishedBlock webViewFinishedBlock;

@end

