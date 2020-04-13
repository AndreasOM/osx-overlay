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

enum OverlayStartupState { On, Off, Last };

@interface Overlay : NSObject <NSCopying, NSMutableCopying>

@property NSUUID*		uuid;
@property NSString*		url;
@property NSString*		title;
@property WKWebView*	webView;
@property NSPoint		position;
@property enum OverlayStartupState	startupState;
@property bool			enabled;
@property bool			reloadOnEnable;
@property unsigned char	midiOnNote;
@property unsigned char	midiOffNote;


+ (id)createWithUrl:(NSString*)url;
- (id)initWithUrl:(NSString*)url andTitle:(NSString*)title;
- (bool)isEqualTo:(nullable Overlay*)overlay;
- (void)setPositionX:(NSInteger)x;
- (void)setPositionY:(NSInteger)y;
- (NSString*)startupStateAsString;
+ (enum OverlayStartupState)startupStateFromString:(NSString* )string;
- (NSDictionary*)toDictionary;
- (void)fromDictionary:(NSDictionary*)d;
- (void)assignFrom:(Overlay*)overlay;

@end

NS_ASSUME_NONNULL_END
