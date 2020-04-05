//
//  OverlayManager.h
//  overlay
//
//  Created by anti on 05.04.20.
//  Copyright © 2020 Omni-Mad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

#import "Overlay.h"

NS_ASSUME_NONNULL_BEGIN

@interface OverlayManager : NSObject
- (Overlay*)findOrCreateForUrl:(NSString*)url;
- (Overlay*)findByUrl:(NSString*)url;
- (Overlay*)findByTitle:(NSString*)title;
- (Overlay*)findByWebView:(WKWebView*)webView;
- (void)removeForUrl:(NSString*)url;
- (void)save;
- (BOOL)load;
- (void)foreach:(void (^)(Overlay*))block;
@end

NS_ASSUME_NONNULL_END
