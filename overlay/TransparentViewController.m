//
//  TransparentViewController.m
//  overlay
//
//  Created by anti on 05.04.20.
//  Copyright © 2020 Omni-Mad. All rights reserved.
//

#import "TransparentViewController.h"

#import "Overlay.h"
#import "OverlayManager.h"

@interface TransparentViewController ()

@end

//NSMutableDictionary* m_pOverlays;

OverlayManager* m_pOverlayManager;

//@synthesize
@implementation TransparentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self.view setFrame:[[NSScreen mainScreen] frame]];

	m_pOverlayManager = [[OverlayManager alloc] init];
	
//	m_pOverlays = [[NSMutableDictionary alloc] init];
//	[self createWebViewForUrl:@"https://htmlpreview.github.io/?https://github.com/AndreasOM/anti666tv/blob/master/live/overlay_fiiish.html"];
	[self createWebViewForUrl:@"https://htmlpreview.github.io/?https://github.com/AndreasOM/osx-overlay/blob/master/sample/1.html"];
	[self createWebViewForUrl:@"https://htmlpreview.github.io/?https://github.com/AndreasOM/osx-overlay/blob/master/sample/2.html"];
	[self createWebViewForUrl:@"https://streamlabs.com/alert-box/v3/YES-AS-IF" withTitle:@"Streamlabs"];
}

- (void)createWebViewForUrl:(NSString*)url {
	[self createWebViewForUrl:url withTitle:url];
}
- (void)createWebViewForUrl:(NSString*)url withTitle:(NSString*)title{
	Overlay* overlay = [m_pOverlayManager findOrCreateForUrl:url];
	
	WKWebView* webView = [[WKWebView alloc] init];
	[webView setValue:[NSNumber numberWithInt:false] forKey:@"drawsBackground"];
	webView.frame = self.view.bounds;
	[self.view addSubview:webView];
	
	[overlay setWebView:webView];
	[overlay setTitle:title];

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		NSLog(@"Loading... %@", url);
		NSURL* urlUrl = [NSURL URLWithString:url];
		NSURLRequest* request = [NSURLRequest requestWithURL:urlUrl];
		Overlay* overlay = [m_pOverlayManager findOrCreateForUrl:url];
		if( overlay.webView != nil )
		{
			[overlay.webView loadRequest:request];
		}
	});
	NSMenu* mainMenu = [[NSApplication sharedApplication] mainMenu];
	
	NSMenuItem* overlaysItem = [mainMenu itemWithTitle:@"Overlays"];
	NSMenu* overlaysMenu = overlaysItem.submenu;
	
	NSMenuItem* menuItem = [[NSMenuItem alloc] initWithTitle:title action:@selector(menuUrlAction:) keyEquivalent:@""];
	[menuItem setTarget:self];
	NSMenu* menuItemMenu = [[NSMenu alloc] initWithTitle:title];
	[[menuItemMenu addItemWithTitle:@"Reload" action:@selector(menuUrlReload:) keyEquivalent:@""] setTarget:self];
//	[[menuItemMenu addItemWithTitle:@"Toggle" action:@selector(menuUrlToggle:) keyEquivalent:@""] setTarget:self];
	[[menuItemMenu addItemWithTitle:@"Remove" action:@selector(menuUrlRemove:) keyEquivalent:@""] setTarget:self];
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

- (void)menuUrlRemove:(id)sender {
	NSMenuItem* menuItem = (NSMenuItem*)sender;

	WKWebView* webView = [self findWebViewForMenuItem:menuItem.parentItem];
	if( webView == nil )
	{
		return;
	}
	
	NSMenu* mainMenu = [[NSApplication sharedApplication] mainMenu];
	
	NSMenuItem* overlaysItem = [mainMenu itemWithTitle:@"Overlays"];
	NSMenu* overlaysMenu = overlaysItem.submenu;

	[overlaysMenu removeItem:menuItem.parentItem];
	[webView removeFromSuperview];
	[self deleteEntryByWebView:webView];
}

- (void)menuUrlAction:(id)sender {
	NSMenuItem* menuItem = (NSMenuItem*)sender;
	
	WKWebView* webView = [self findWebViewForMenuItem:menuItem];
	if( webView == nil )
	{
		return;
	}
	
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

- (void)deleteEntryByWebView:(WKWebView*)webView {
	Overlay* overlay = [m_pOverlayManager findByWebView:webView];
	[m_pOverlayManager removeForUrl:overlay.url];
}
- (WKWebView*)findWebViewForMenuItem:(NSMenuItem*)menuItem {
	Overlay* overlay = [m_pOverlayManager findByUrl:menuItem.title];
	if( overlay == nil )
	{
		overlay = [m_pOverlayManager findByTitle:menuItem.title];
		if( overlay == nil )
		{
			return nil;
		}
	}
	
	return overlay.webView;
}

- (void)menuAddOverlay:(id)sender {
	NSLog(@":TODO: Add overlay");
}
@end
