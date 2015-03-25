//
//  WBUtils.h
//  Webridge
//
//  Created by linyize on 14/12/23.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSInvocation (webridge)

- (id)returnValueAsObject;

@end

@interface NSObject (webridge)

- (NSString *)stringForJavascript;

@end

@interface NSString (webridge)

- (NSString *)encodeWBURI;
- (NSString *)decodeWBURI;

@end

@interface NSString (MD5)

- (NSString *)md5;

@end

@interface NSString (json)

- (id)JSONObject;

@end

@interface NSData (json)

- (id)JSONObject;

@end

@interface NSObject (json)

- (NSString *)JSONString;

@end

@interface UIWebView (slate)

- (NSInteger)getiFrameCount;
- (NSString *)getiFrameSrcWithIndex:(NSUInteger)index;
- (NSString *)metaTag:(NSString *)metaTagName;
- (NSString *)title;

@end
