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
	
	[self.view setFrame:[[NSScreen mainScreen] frame]];

	[self createWebViewForUrl:@"https://htmlpreview.github.io/?https://github.com/AndreasOM/anti666tv/blob/master/live/overlay_fiiish.html"];
}

- (void)createWebViewForUrl:(NSString*)url {
	WKWebView* webView = [[WKWebView alloc] init];
	[webView setValue:[NSNumber numberWithInt:false] forKey:@"drawsBackground"];
	webView.frame = self.view.bounds;
	[self.view addSubview:webView];
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		NSLog(@"Loading... %@", url);
		NSURL* urlUrl = [NSURL URLWithString:url];
		NSURLRequest* request = [NSURLRequest requestWithURL:urlUrl];
		[webView loadRequest:request];
	});
}

@end
