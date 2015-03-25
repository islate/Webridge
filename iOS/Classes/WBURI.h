//
//  WBURI.h
//  Webridge
//
//  Created by linyize on 14/12/8.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol WBURIHandler <NSObject>
@required
- (NSString *)scheme;
- (void)unknownURI:(NSURL *)uri;
- (void)unknownCommand:(NSString *)command params:(NSString *)params paramsArray:(NSArray *)paramsArray;

@end

@interface WBURI : NSObject

+ (void)registerURIHandler:(id<WBURIHandler>)handler;
+ (id<WBURIHandler>)handler;
+ (BOOL)canOpenURI:(NSURL *)uri;
+ (void)openURI:(NSURL *)uri;

@end
