//
//  TransparentViewController.h
//  overlay
//
//  Created by anti on 05.04.20.
//  Copyright © 2020 Omni-Mad. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <WebKit/WebKit.h>

#import "OverlayConfigWindowController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TransparentViewController : NSViewController <OverlayConfigWindowControllerDelegate> {
}

@property(nonatomic,strong) IBOutlet WKWebView *webView;
@end

NS_ASSUME_NONNULL_END
