//
//  TransparentViewController.m
//  overlay
//
//  Created by anti on 05.04.20.
//  Copyright © 2020 Omni-Mad. All rights reserved.
//

#import "TransparentViewController.h"

#import "MidiInput.h"

#import "Overlay.h"
#import "OverlayManager.h"


@interface TransparentViewController ()

@property OverlayConfigWindowController* overlayConfigWindowController;

@end

//NSMutableDictionary* m_pOverlays;

MidiInput*		m_pMidiInput;
OverlayManager* m_pOverlayManager;

//@synthesize
@implementation TransparentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self.view setFrame:[[NSScreen mainScreen] frame]];

	m_pOverlayManager = [[OverlayManager alloc] init];
	if( ![m_pOverlayManager load] )
	{
		[[m_pOverlayManager findOrCreateForUrl:@"https://htmlpreview.github.io/?https://github.com/AndreasOM/osx-overlay/blob/master/sample/1.html"] setTitle:@"Sample 1"];
		[[m_pOverlayManager findOrCreateForUrl:@"https://htmlpreview.github.io/?https://github.com/AndreasOM/osx-overlay/blob/master/sample/2.html"] setTitle:@"Sample 2"];
	}

	
	[m_pOverlayManager foreach:^(Overlay* o) {
		[self createWebViewForUrl:o.url withTitle:o.title];
	}];
	
	[[m_pOverlayManager findOrCreateForUrl:@"file:///Users/anti/data/work/anti666tv/anti666tv/live/overlay_fiiish.html"] setTitle:@"Fiiish! [local]"];

	[self rebuildMenu];

	m_pMidiInput = [[MidiInput alloc] init];
	
	[m_pMidiInput sendNoteOn:0x0c withVelocity:0x7f onChannel:0]; // enter extended mode // Note: Should be 15, but that seems broken
	[m_pMidiInput sendNoteOn:96 withVelocity:16 onChannel:0];
	for( int ch = 0; ch <= 15; ++ch )
	{
		[m_pMidiInput sendNoteOn:96 withVelocity:1 onChannel:ch];
	}
//	[m_pMidiInput sendNoteOn:96 withVelocity:1 onChannel:1]; // flash
//	[m_pMidiInput sendNoteOn:96 withVelocity:1 onChannel:3]; // pulse
/*
	[m_pMidiInput sendNoteOn:96 withVelocity:1 onChannel:0]; // pulse
	[m_pMidiInput sendNoteOn:96 withVelocity:1 onChannel:1]; // pulse
	[m_pMidiInput sendNoteOn:96 withVelocity:1 onChannel:2]; // pulse
	[m_pMidiInput sendNoteOn:96 withVelocity:1 onChannel:3]; // pulse
	[m_pMidiInput sendNoteOn:96 withVelocity:1 onChannel:4]; // pulse
	[m_pMidiInput sendNoteOn:96 withVelocity:1 onChannel:5]; // pulse
	[m_pMidiInput sendNoteOn:96 withVelocity:1 onChannel:6]; // pulse
	[m_pMidiInput sendNoteOn:96 withVelocity:1 onChannel:7]; // pulse
*/
	[m_pMidiInput registerNoteOnBlock:^(unsigned char note) {
		NSLog(@"Note ON: %d", note );
		switch( note )
		{
			case 96:	// 1 on my novation launchkey mini
				{
					int c = arc4random_uniform(127);
					[m_pMidiInput sendNoteOn:96 withVelocity:c onChannel:0]; //color feedback
					// velocity: 1 = red, 16 = green, 51 = orange
//					[m_pMidiInput sendNoteOn:96 withVelocity:51 onChannel:16]; //color feedback
				}
				break;
			default:
				{
					if( note >= 0 && note <= 120 && note != 0x0c )
					{
						int c = arc4random_uniform(127);
						[m_pMidiInput sendNoteOn:note withVelocity:c onChannel:0]; //color feedback
						dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
							[m_pMidiInput sendNoteOn:note withVelocity:0 onChannel:0]; //color feedback
						});
					}
				}
				break;
		}
	}];
}

- (void)createWebViewForUrl:(NSString*)url {
	[self createWebViewForUrl:url withTitle:url];
}
- (void)createWebViewForUrl:(NSString*)url withTitle:(NSString*)title{
	Overlay* overlay = [m_pOverlayManager findOrCreateForUrl:url];
	
	// :TODO: handle case where we already have a web view
	
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
}

- (void)rebuildMenu {
	// :TODO: probably could just patch up the menu
	NSMenu* mainMenu = [[NSApplication sharedApplication] mainMenu];
	
	NSMenuItem* overlaysItem = [mainMenu itemWithTitle:@"Overlays"];
	NSMenu* overlaysMenu = overlaysItem.submenu;
//	NSMenu* overlaysMenu = [[NSMenu alloc] init];

	NSMenuItem* saveItem = [overlaysMenu itemWithTitle:@"Save"];
	[saveItem setTarget:self];
	[saveItem setAction:@selector(save)];

	NSMenuItem* addOverlayItem = [overlaysMenu itemWithTitle:@"Add Overlay"];
	[addOverlayItem setTarget:self];
	[addOverlayItem setAction:@selector(addOverlay)];

	[m_pOverlayManager foreach:^(Overlay* overlay) {
		NSInteger index = [overlaysMenu indexOfItemWithRepresentedObject:overlay];
		if( index >= 0 ) {	// old overlay
			// ensure title is correct
			NSMenuItem* oi = [overlaysMenu itemAtIndex:index];
			if( ![oi.title isEqualToString:overlay.title] ) {
				[oi setTitle:overlay.title];
			}
		} else {			// new overlay
			[self addOverlayToMenu:overlay];
		}
	}];
	
	// does not remove old entries!
}

- (void)addOverlayToMenu:(Overlay*)overlay {
	NSString* title = overlay.title;
	
	NSMenu* mainMenu = [[NSApplication sharedApplication] mainMenu];
	
	NSMenuItem* overlaysItem = [mainMenu itemWithTitle:@"Overlays"];
	NSMenu* overlaysMenu = overlaysItem.submenu;
	
	NSMenuItem* menuItem = [[NSMenuItem alloc] initWithTitle:title action:@selector(menuUrlAction:) keyEquivalent:@""];
	[menuItem setTarget:self];
	NSMenu* menuItemMenu = [[NSMenu alloc] initWithTitle:title];
	[[menuItemMenu addItemWithTitle:@"Reload" action:@selector(menuUrlReload:) keyEquivalent:@""] setTarget:self];
//	[[menuItemMenu addItemWithTitle:@"Toggle" action:@selector(menuUrlToggle:) keyEquivalent:@""] setTarget:self];
	[[menuItemMenu addItemWithTitle:@"Remove" action:@selector(menuUrlRemove:) keyEquivalent:@""] setTarget:self];
	[[menuItemMenu addItemWithTitle:@"Edit" action:@selector(menuUrlEdit:) keyEquivalent:@""] setTarget:self];
	[menuItem setState: NSControlStateValueOn];
	[menuItem setRepresentedObject:overlay];
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

- (void)menuUrlEdit:(id)sender {
	NSMenuItem* menuItem = (NSMenuItem*)sender;
	NSLog(@"Edit %@", menuItem.parentItem.title);
	if( !_overlayConfigWindowController ) {
		Overlay* overlay = [self findOverlayForMenuItem:menuItem.parentItem];
		if( overlay != nil ) {
			_overlayConfigWindowController =[[OverlayConfigWindowController alloc] initWithWindowNibName:@"OverlayConfigWindowController"];
			[_overlayConfigWindowController setOverlay:overlay];
			[_overlayConfigWindowController setDelegate:self];
			[_overlayConfigWindowController showWindow:self];
		}
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

- (Overlay*)findOverlayForMenuItem:(NSMenuItem*)menuItem {
	Overlay* overlay = [m_pOverlayManager findByUrl:menuItem.title];
	if( overlay == nil )
	{
		overlay = [m_pOverlayManager findByTitle:menuItem.title];
		if( overlay == nil )
		{
			return nil;
		}
	}
	
	return overlay;
}

- (void)menuAddOverlay:(id)sender {
	NSLog(@":TODO: Add overlay");
}

- (IBAction)save {
	[m_pOverlayManager save];
}

- (IBAction)addOverlay {
	if( !_overlayConfigWindowController ) {
		Overlay* overlay = [[Overlay alloc] init];
		if( overlay != nil ) {
			_overlayConfigWindowController =[[OverlayConfigWindowController alloc] initWithWindowNibName:@"OverlayConfigWindowController"];
			[_overlayConfigWindowController setOverlay:overlay];
			[_overlayConfigWindowController setDelegate:self];
			[_overlayConfigWindowController showWindow:self];
		}
	}
}

- (void)overlayChangeCanceled:(Overlay *)overlay {
	[_overlayConfigWindowController close];
	_overlayConfigWindowController = nil;
}

- (void)overlayChanged:(Overlay *)newOverlay was:(Overlay *)oldOverlay {
	NSLog( @"overlayChanged" );
	[_overlayConfigWindowController close];
	_overlayConfigWindowController = nil;
	Overlay* overlay = nil;
	bool titleChanged = ![oldOverlay.title isEqualTo:newOverlay.title];
	if( oldOverlay.url != nil ) {
		if( ![oldOverlay.url isEqualTo:newOverlay.url] ) {
			// url changed, so the key changed
			[m_pOverlayManager removeForUrl:oldOverlay.url];
			overlay = [m_pOverlayManager findOrCreateForUrl:newOverlay.url];
		} else {
			// url is the same, so reuse entry
			overlay = [m_pOverlayManager findByUrl:oldOverlay.url];
		}
	} else {
		overlay = [m_pOverlayManager findOrCreateForUrl:newOverlay.url];
	}
	if( overlay != nil ) {
		[overlay setTitle:newOverlay.title];
	}
	if( titleChanged ) {
		[self rebuildMenu];	// :TODO: could probably just patch the old entry
	}
	
}

@end
