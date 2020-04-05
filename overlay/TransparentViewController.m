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

NSMutableDictionary* m_pOverlays;

//@synthesize
@implementation TransparentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self.view setFrame:[[NSScreen mainScreen] frame]];

	m_pOverlays = [[NSMutableDictionary alloc] init];
//	[self createWebViewForUrl:@"https://htmlpreview.github.io/?https://github.com/AndreasOM/anti666tv/blob/master/live/overlay_fiiish.html"];
	[self createWebViewForUrl:@"https://htmlpreview.github.io/?https://github.com/AndreasOM/osx-overlay/blob/master/sample/1.html"];
	[self createWebViewForUrl:@"https://htmlpreview.github.io/?https://github.com/AndreasOM/osx-overlay/blob/master/sample/2.html"];
}

- (void)createWebViewForUrl:(NSString*)url {
	NSMutableDictionary* overlay = [m_pOverlays objectForKey:url];
	if( overlay == nil )
	{
		// new entry ... currently default
		// :TODO: could just be a struct?!
		overlay = [[NSMutableDictionary alloc] init];
		[m_pOverlays setObject:overlay forKey:url];
	}
	else
	{
		// :TODO: decide what we do here
	}
	WKWebView* webView = [[WKWebView alloc] init];
	[webView setValue:[NSNumber numberWithInt:false] forKey:@"drawsBackground"];
	webView.frame = self.view.bounds;
	[self.view addSubview:webView];
	
	[overlay setObject:webView forKey:@"webView"];
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		NSLog(@"Loading... %@", url);
		NSURL* urlUrl = [NSURL URLWithString:url];
		NSURLRequest* request = [NSURLRequest requestWithURL:urlUrl];
		[webView loadRequest:request];
	});
	NSMenu* mainMenu = [[NSApplication sharedApplication] mainMenu];
	
	NSMenuItem* overlaysItem = [mainMenu itemWithTitle:@"Overlays"];
	NSMenu* overlaysMenu = overlaysItem.submenu;
	
	NSMenuItem* menuItem = [[NSMenuItem alloc] initWithTitle:url action:@selector(menuUrlAction:) keyEquivalent:@""];
	[menuItem setTarget:self];
	NSMenu* menuItemMenu = [[NSMenu alloc] initWithTitle:url];
	[[menuItemMenu addItemWithTitle:@"Reload" action:@selector(menuUrlReload:) keyEquivalent:@""] setTarget:self];
//	[[menuItemMenu addItemWithTitle:@"Toggle" action:@selector(menuUrlToggle:) keyEquivalent:@""] setTarget:self];
	[menuItem setState: NSControlStateValueOn];
	[overlaysMenu addItem:menuItem];
	[overlaysMenu setSubmenu:menuItemMenu forItem:menuItem];
}

- (void)addUrlToMenu:(NSString*)url {
	NSLog(@"Adding %@ to menu", url);
}
- (void)menuUrlReload:(id)sender {
	NSMenuItem* menuItem = (NSMenuItem*)sender;
	NSLog(@"Reload %@", menuItem.parentItem.title);
}
- (void)menuUrlToggle:(id)sender {
	NSMenuItem* menuItem = (NSMenuItem*)sender;
	NSLog(@"Toggle %@", menuItem.parentItem.title);
	[menuItem setState: NSControlStateValueOn];
}

- (void)menuUrlAction:(id)sender {
	NSMenuItem* menuItem = (NSMenuItem*)sender;

	NSMutableDictionary* overlay = [m_pOverlays objectForKey:menuItem.title];
	if( overlay == nil )
	{
		return;
	}
	
	WKWebView* webView = [overlay objectForKey:@"webView"];

	switch( menuItem.state )
	{
		case NSControlStateValueOn:
			{
				[menuItem setState: NSControlStateValueOff];
				[webView setHidden:YES];
			}
			break;
		case NSControlStateValueOff:
			{
				[menuItem setState: NSControlStateValueOn];
				[webView setHidden:NO];
			}
			break;
	}
}

- (void)menuAddOverlay:(id)sender {
	NSLog(@":TODO: Add overlay");
}
@end
