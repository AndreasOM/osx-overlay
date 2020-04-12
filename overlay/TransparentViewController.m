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

#import "TransparentWebView.h"

@interface TransparentViewController ()

@property OverlayConfigWindowController* overlayConfigWindowController;

@end

//NSMutableDictionary* m_pOverlays;

MidiInput*		m_pMidiInput;
OverlayManager* m_pOverlayManager;

//@synthesize
@implementation TransparentViewController

+ (NSRect)insetRect:(NSRect)rect insetX:(int)insetX insetY:(int)insetY {
	NSRect outRect = NSMakeRect( rect.origin.x+insetX, rect.origin.y+insetY, rect.size.width - 2*insetX, rect.size.height - 2*insetY );
	
	return outRect;
}
+ (NSRect)outsetRect:(NSRect)rect insetX:(int)insetX insetY:(int)insetY {
	NSRect outRect = NSMakeRect( rect.origin.x-insetX, rect.origin.y-insetY, rect.size.width + 2*insetX, rect.size.height + 2*insetY );
	
	return outRect;
}
- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self.view setFrame:[[NSScreen mainScreen] frame]];
	
	// :TEST:
	if( false )
	{
		NSRect rect = self.view.bounds;
		rect.origin.x = rect.origin.x + 0.5f*( rect.size.width );
		rect.origin.y = rect.origin.y + 0.5f*( rect.size.height );
		rect.size.width = 0;
		rect.size.height = 0;
		
		rect = [TransparentViewController outsetRect:rect insetX:5*16 insetY:5*9];

		rect = NSMakeRect( 0, 0, 160, 90);
		NSArray* colors = [NSArray arrayWithObjects: [NSColor redColor], [NSColor greenColor], [NSColor yellowColor], [NSColor blackColor], nil ];
		for( int i = 0; i < 10; ++i ) {
		for( NSColor* color in colors ) {
			NSLog(@"Rect for %p: %f,%f | %fx%f", color, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height );
			TransparentWebView* webView = [[TransparentWebView alloc] initWithFrame:rect];
			[webView setBackgroundColor:color];
			[self.view addSubview:webView];
//			rect = [TransparentViewController insetRect:rect insetX:16 insetY:9];
			rect.origin.x += 32;
			rect.origin.y += 18;
			rect.size.width += 32;
			rect.size.height += 18;
		}
			rect.origin.x -= 32;
			rect.size.width -= 32;
		}
		return;
	}
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

// the next two are legacy wrappers :TODO: remove
- (void)createWebViewForUrl:(NSString*)url {
	[self createWebViewForUrl:url withTitle:url];
}
- (void)createWebViewForUrl:(NSString*)url withTitle:(NSString*)title{
	Overlay* overlay = [m_pOverlayManager findOrCreateForUrl:url];
	[overlay setTitle:title];
	[self createWebViewForOverlay:overlay];
}

- (void)createWebViewForOverlay:(Overlay*)overlay {
	
	// :TODO: handle case where we already have a web view

//	NSRect rect = NSOffsetRect( self.view.bounds, overlay.position.x, overlay.position.y );
//							   rect = NSIntersectionRect( rect, self.view.bounds );
	
	NSRect rect = self.view.bounds;
	
	rect.origin.y += overlay.position.y;
	rect.size.height += overlay.position.y;	// looks like "size" is actually "end position"
	/*
	if( overlay.position.y > 0 ) {
		rect.origin.y += overlay.position.y;
//		rect.size.height -= overlay.position.y;
	} else {
		rect.origin.y += overlay.position.y;
//		rect.size.height += overlay.position.y; // this value is negative!
	}
	*/
	NSLog(@"Rect for %@: %f,%f | %fx%f", overlay.title, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height );
	
//	rect.origin.x = 400;
//	rect.size.width = 800;

/*
	rect.origin.x = 400;
	rect.origin.x = 100;
	rect.size.width = 800;
	rect.size.height = 800;
	*/

//	NSView* subView = [[NSView alloc] initWithFrame:rect];
//	[self.view addSubview:subView];

	WKWebView* webView = [[WKWebView alloc] initWithFrame:rect];
	[webView setValue:[NSNumber numberWithInt:false] forKey:@"drawsBackground"];

//	webView.frame = rect;
	/*
	rect.origin.y = 100;
	rect.size.width *= 1.0;
	rect.size.height *= 1.0;
	webView.bounds = rect;
	*/
	[webView setTranslatesAutoresizingMaskIntoConstraints:NO];
	webView.navigationDelegate = self;
//	[webView reload];
//	[webView setFrameOrigin:overlay.position];
//	[webView setBoundsOrigin:overlay.position];
	[self.view addSubview:webView];
//	[subView addSubview:webView];
	
	[overlay setWebView:webView];

	if( overlay.enabled )
	{
		[webView setHidden:NO];
	}
	else
	{
		[webView setHidden:YES];
	}

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		NSLog(@"Loading... %@", overlay.url);
		NSURL* urlUrl = [NSURL URLWithString:overlay.url];
		NSURLRequest* request = [NSURLRequest requestWithURL:urlUrl];
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
	
	Overlay* overlay = [self findOverlayForMenuItem:menuItem];
	if( overlay == nil )
	{
		return;
	}

	switch( menuItem.state )
	{
		case NSControlStateValueOn:
			{
				[menuItem setState: NSControlStateValueOff];
				[webView setHidden:YES];
				[overlay setEnabled:NO];
			}
			break;
		case NSControlStateValueOff:
			{
				[menuItem setState: NSControlStateValueOn];
				[webView setHidden:NO];
				[overlay setEnabled:YES];
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
		[overlay assignFrom:newOverlay];
		/*
		[overlay setTitle:newOverlay.title];
		[overlay setPositionX:newOverlay.position.x];
		[overlay setPositionY:newOverlay.position.y];
		 */
	}
	if( titleChanged ) {
		[self rebuildMenu];	// :TODO: could probably just patch the old entry
	}
	
}

- (void)overlayPositionChanged:(Overlay *)overlay {
	NSLog(@"overlayPositionChanged to %f, %f", overlay.position.x, overlay.position.y );
	Overlay* o = [m_pOverlayManager findByUrl:overlay.url];
	WKWebView* w = o.webView;
	if( w == nil ) {
		NSLog(@"No webView for position change" );
	}
	[w setFrameOrigin:overlay.position];
	[w setNeedsDisplay: true];
	[w reload];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
	NSLog(@"didFinishNavigation");
}


@end
