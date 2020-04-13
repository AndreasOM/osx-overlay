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

- (id)init {
    if (self = [super init]) {
		self.uuid = [NSUUID UUID];
//		self.url = nil;
//		self.title = nil;
		self.position = NSMakePoint( 0.0f, 0.0f );
		self.startupState = On;
		self.enabled = true;
		self.midiOnNote = 0;
		self.midiOffNote = 0;
	}
	return self;
}
- (id)initWithUrl:(NSString *)url andTitle:(NSString*)title {
    if (self = [super init]) {
		self.uuid = [NSUUID UUID];
		self.url = url;
		self.title = title;
		self.position = NSMakePoint( 0.0f, 0.0f );
		self.startupState = On;
		self.enabled = true;
		self.midiOnNote = 0;
		self.midiOffNote = 0;
    }
    return self;
}

- (bool)isEqualTo:(Overlay *)overlay {
	return
		[_title isEqualTo:overlay->_title]
		&& [_url isEqualTo:overlay->_url]
		&& NSEqualPoints( _position, overlay->_position )
		&& ( _midiOnNote == overlay->_midiOnNote )
		&& ( _midiOffNote == overlay->_midiOffNote )
	;
}

- (void)setPositionX:(NSInteger)x {
	self.position  = NSMakePoint( x, self.position.y );
}
- (void)setPositionY:(NSInteger)y {
	self.position  = NSMakePoint( self.position.x, y );
}

- (NSDictionary*)toDictionary {
	NSMutableDictionary* d = [[NSMutableDictionary alloc] init];
	[d setObject:[self.uuid UUIDString] forKey:@"uuid"];
	[d setObject:self.url forKey:@"url"];	// url is/was key, still duplicate if we ever decide to change that
	[d setObject:self.title forKey:@"title"];
	[d setObject:[NSNumber numberWithFloat:self.position.x] forKey:@"posX"];
	[d setObject:[NSNumber numberWithFloat:self.position.y] forKey:@"posY"];
	[d setObject:[self startupStateAsString] forKey:@"startupState"];
	[d setObject:[NSNumber numberWithBool:self.enabled] forKey:@"enabled"];
	[d setObject:[NSNumber numberWithUnsignedChar:self.midiOnNote] forKey:@"midiOnNote"];
	[d setObject:[NSNumber numberWithUnsignedChar:self.midiOffNote] forKey:@"midiOffNote"];
	return d;
}

- (NSString*)startupStateAsString {
	NSString* startupState = @"On";
	switch( self.startupState )
	{
		case On:
			startupState = @"On";
			break;
		case Off:
			startupState = @"Off";
			break;
		case Last:
			startupState = @"Last";
			break;
	}
	
	return startupState;
}
+ (enum OverlayStartupState)startupStateFromString:(NSString* )string {
	if( [string isEqualToString:@"On"] )
	{
		return On;
	}
	if( [string isEqualToString:@"Off"] )
	{
		return Off;
	}
	if( [string isEqualToString:@"Last"] )
	{
		return Last;
	}
	// default -> On (for legacy)
	return On;
}
- (void)fromDictionary:(NSDictionary *)d {
	NSUUID* uuid;
	NSString* uuidString = [d objectForKey:@"uuid"];
	if( uuidString == nil )	// for legacy data loading
	{
		uuid = [NSUUID UUID];
	}
	else
	{
		uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
	}
	[self setUuid:uuid];
	if( [d objectForKey:@"url"] != nil )
	{
		[self setUrl:[d objectForKey:@"url"]];
	}
	[self setTitle:[d objectForKey:@"title"]];
	NSNumber* posX = [d objectForKey:@"posX"];
	NSNumber* posY = [d objectForKey:@"posY"];
	self.position = NSMakePoint( [posX floatValue], [posY floatValue]);
	self.startupState = [Overlay startupStateFromString:[d objectForKey:@"startupState"]];
	
	bool enabled = NO;
	switch( self.startupState )
	{
		case On:
			enabled = YES;
			break;
		case Off:
			enabled = NO;
			break;
		case Last:
			enabled = [[d objectForKey:@"enabled"] boolValue];
			break;

	}
	self.enabled = enabled;
	NSNumber* midiOnNote = [d objectForKey:@"midiOnNote" ];
	self.midiOnNote = midiOnNote?[midiOnNote unsignedCharValue]:0;
	NSNumber* midiOffNote = [d objectForKey:@"midiOffNote" ];
	self.midiOffNote = midiOffNote?[midiOffNote unsignedCharValue]:0;
}

- (void)assignFrom:(Overlay *)overlay {
	self.title = overlay.title;
	self.url = overlay.url;
	self.position = overlay.position;
//!	self.webView = overlay.webView;
	self.startupState = overlay.startupState;
	self.enabled = overlay.enabled;
	self.midiOnNote = overlay.midiOnNote;
	self.midiOffNote = overlay.midiOffNote;
}

- (id)copyWithZone:(NSZone *)zone {
	Overlay* overlay = [[[self class] allocWithZone:zone] init];
	overlay->_title = [_title copyWithZone:zone];
	overlay->_url = [_url copyWithZone:zone];
	overlay->_position = _position;
	overlay->_webView = nil;	// we explicitly don't copy the webview
	overlay->_startupState = _startupState;
	overlay->_enabled = _enabled;
	overlay->_midiOnNote = _midiOnNote;
	
	return overlay;
}
- (id)mutableCopyWithZone:(NSZone *)zone {
	Overlay* overlay = [[[self class] allocWithZone:zone] init];
	overlay->_title = [_title mutableCopyWithZone:zone];
	overlay->_url = [_url mutableCopyWithZone:zone];
	overlay->_webView = nil;	// we explicitly don't copy the webview
	overlay->_startupState = _startupState;
	overlay->_enabled = _enabled;
	overlay->_midiOnNote = _midiOnNote;

	return overlay;
}
@end


