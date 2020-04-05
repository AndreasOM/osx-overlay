//
//  TransparentViewController.m
//  overlay
//
//  Created by anti on 05.04.20.
//  Copyright © 2020 Omni-Mad. All rights reserved.
//

#import "TransparentViewController.h"

@interface TransparentViewController ()

@end

//@synthesize
@implementation TransparentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
	
//	[self.view setFrame:[[NSScreen mainScreen] visibleFrame]];
	[self.view setFrame:[[NSScreen mainScreen] frame]];

//	self.webView = [[WKWebView alloc] init];
//	self.webView.isOpaque = false;
//	self.webView.backgroundColor = [NSColor greenColor];
	[self.webView setValue:[NSNumber numberWithInt:false] forKey:@"drawsBackground"];
//	[self.webView.enclosingScrollView.]
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//		NSLog(@"parameter1: %d parameter2: %f", parameter1, parameter2);
		NSLog(@"Loading...");
//		[self.webView setValue:false forKey:@"isOpaque"];
//		NSURL* url = [NSURL URLWithString:@"http://fiiish.omnimad.net/"];
		NSURL* url = [NSURL URLWithString:@"https://htmlpreview.github.io/?https://github.com/AndreasOM/anti666tv/blob/master/live/overlay_fiiish.html"];
		NSURLRequest* request = [NSURLRequest requestWithURL:url];
		[self.webView loadRequest:request];
	});

}

@end
