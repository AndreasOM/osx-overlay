//
//  AppDelegate.m
//  overlay
//
//  Created by anti on 05.04.20.
//  Copyright © 2020 Omni-Mad. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
	NSRect frame = [[NSScreen mainScreen] frame];

	{
		NSWindow *window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0,0,100,100)
		styleMask:NSTitledWindowMask
		  backing:NSBackingStoreBuffered
			defer:YES
		   screen:nil];
	}
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}


@end
