//
//  TransparentView.m
//  overlay
//
//  Created by anti on 05.04.20.
//  Copyright © 2020 Omni-Mad. All rights reserved.
//

#import "TransparentView.h"

@implementation TransparentView

- (void)drawRect:(NSRect)dirtyRect {
	NSRect rect = [self frame];
	rect.origin.x += 0.9*rect.size.width;
	rect.size.width *= 0.1f;
	[[NSColor redColor] set];
//	NSRectFillUsingOperation(rect, NSCompositingOperationSourceOver);
}

- (BOOL)isOpaque
{
	return false;
}

- (CGFloat)alphaValue

{
	return 0.8f;
}

@end
