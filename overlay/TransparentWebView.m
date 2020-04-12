
#import "TransparentWebView.h"

@implementation TransparentWebView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
	NSRect rect = [self frame];
//	rect.origin.x += 0.9*rect.size.width;
//	rect.size.width *= 0.1f;
//	[[NSColor redColor] set];
	[self.backgroundColor set];
//	NSRectFill(rect);
	NSRectFillUsingOperation(rect, NSCompositingOperationSourceOver);
}

- (BOOL)isOpaque
{
	return false;
}

- (CGFloat)alphaValue

{
	return 0.1f;
}

@end
