//
//  Overlay.h
//  overlay
//
//  Created by anti on 05.04.20.
//  Copyright © 2020 Omni-Mad. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Overlay : NSObject <NSCopying, NSMutableCopying>

@property NSString*		url;
@property NSString*		title;
@property WKWebView*	webView;
@property NSPoint		position;

+ (id)createWithUrl:(NSString*)url;
- (id)initWithUrl:(NSString*)url andTitle:(NSString*)title;
- (bool)isEqualTo:(nullable Overlay*)overlay;
- (void)setPositionX:(NSInteger)x;
- (void)setPositionY:(NSInteger)y;
@end

NS_ASSUME_NONNULL_END
