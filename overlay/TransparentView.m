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
	/*
	static bool isLoaded = false;
	if( !isLoaded )
	{
		isLoaded = true;
		dispatch_async(dispatch_get_main_queue(), ^{
		   NSURL* url = [NSURL URLWithString:@"http://fiiish.omnimad.net/"];
		   NSURLRequest* request = [NSURLRequest requestWithURL:url];
		   [self->webView loadRequest:request];
		});
	}
	 */
	
//    [super drawRect:dirtyRect];
	//[webView setBackgroundColor]
//	webView.layer.backgroundColor = CGColorCreateGenericRGB( 0.5f, 0.0f, 0.0f, 1.0f);
//	[webView setValue:false forKey:@"drawsBackground"];
//	[webView setValue:[NSColor greenColor] forKey:@"backgroundColor"];
	NSRect rect = [self frame];
	rect.origin.x += 0.9*rect.size.width;
	rect.size.width *= 0.1f;
//	[[NSColor clearColor] set];
	[[NSColor redColor] set];
	NSRectFillUsingOperation(rect, NSCompositingOperationSourceOver);
	
}

- (BOOL)isOpaque
{
	return false;
}

- (CGFloat)alphaValue

{
	return 1.0f;
}

@end
