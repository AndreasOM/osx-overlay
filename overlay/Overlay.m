//
//  Overlay.m
//  overlay
//
//  Created by anti on 05.04.20.
//  Copyright © 2020 Omni-Mad. All rights reserved.
//

#import "Overlay.h"

@implementation Overlay

+ (id)createWithUrl:(NSString *)url {
	return [[Overlay alloc] initWithUrl:url andTitle:url];
}

- (id)initWithUrl:(NSString *)url andTitle:(NSString*)title {
    if (self = [super init]) {
		self.url = url;
		self.title = title;
		self.position = NSMakePoint( 0.0f, 0.0f );
    }
    return self;
}

- (bool)isEqualTo:(Overlay *)overlay {
	return
		[_title isEqualTo:overlay->_title]
		&& [_url isEqualTo:overlay->_url]
		&& NSEqualPoints( _position, overlay->_position )
	;
}

- (void)setPositionX:(NSInteger)x {
	self.position  = NSMakePoint( x, self.position.y );
}
- (void)setPositionY:(NSInteger)y {
	self.position  = NSMakePoint( self.position.x, y );
}

- (id)copyWithZone:(NSZone *)zone {
	Overlay* overlay = [[[self class] allocWithZone:zone] init];
	overlay->_title = [_title copyWithZone:zone];
	overlay->_url = [_url copyWithZone:zone];
	overlay->_position = _position;
	overlay->_webView = nil;	// we explicitly don't copy the webview

	return overlay;
}
- (id)mutableCopyWithZone:(NSZone *)zone {
	Overlay* overlay = [[[self class] allocWithZone:zone] init];
	overlay->_title = [_title mutableCopyWithZone:zone];
	overlay->_url = [_url mutableCopyWithZone:zone];
	overlay->_webView = nil;	// we explicitly don't copy the webview

	return overlay;
}
@end


