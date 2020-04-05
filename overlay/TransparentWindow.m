//
//  TransparentWindow.m
//  overlay
//
//  Created by anti on 05.04.20.
//  Copyright © 2020 Omni-Mad. All rights reserved.
//

#import "TransparentWindow.h"

@implementation TransparentWindow

- (CGFloat)alphaValue

{
	return 1.0f;
}

//NSColor *backgroundColor;
- (NSColor*) backgroundColor
{
	return [NSColor clearColor];
}
- (BOOL)isOpaque
{
	return false;
}

// set level to: NSFloatingWindowLevel
@end
