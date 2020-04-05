//
//  TransparentWindowController.m
//  overlay
//
//  Created by anti on 05.04.20.
//  Copyright © 2020 Omni-Mad. All rights reserved.
//

#import "TransparentWindowController.h"

@interface TransparentWindowController ()

@end

@implementation TransparentWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
	if( self.window != nil )
	{
		[self.window setLevel:NSFloatingWindowLevel];
		[self.window setIgnoresMouseEvents:true];
	}
}

@end
