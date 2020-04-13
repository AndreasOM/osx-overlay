//
//  OverlayManager.m
//  overlay
//
//  Created by anti on 05.04.20.
//  Copyright © 2020 Omni-Mad. All rights reserved.
//

#import "OverlayManager.h"

NSMutableDictionary* m_overlays;

@implementation OverlayManager
- (id)init {
    if (self = [super init]) {
		m_overlays = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}
- (NSUInteger)count {
	return [m_overlays count];
}
- (bool)insert:(Overlay *)overlay {
	if( [m_overlays objectForKey:overlay.url] != nil )
	{
		// entry already exists
		return false;
	}
	[m_overlays setObject:overlay forKey:overlay.url];
	return true;
}

-(Overlay*)findOrCreateForUrl:(NSString *)url {
	Overlay* overlay = [m_overlays objectForKey:url];
	if( overlay == nil )
	{
		overlay = [Overlay createWithUrl:url];
		[m_overlays setObject:overlay forKey:url];
	}
	return overlay;
}

- (Overlay*)findByUrl:(NSString*)url {
	return [m_overlays objectForKey:url];
}

- (Overlay*)findByTitle:(NSString*)title {
	for(NSString* key in m_overlays)
	{
		Overlay* o = m_overlays[key];
		if( o.title == title )
		{
			return o;
		}
	}
	return nil;
}

- (Overlay*)findByWebView:(WKWebView *)webView {
	for(NSString* key in m_overlays)
	{
		Overlay* o = m_overlays[key];
		if( o.webView == webView )
		{
			return o;
		}
	}
	return nil;
}

- (void)removeForUrl:(NSString *)url {
	[m_overlays removeObjectForKey:url];
}

- (void)foreach:(void (^)(Overlay*))block {
	for(NSString* key in m_overlays)
	{
		Overlay* o = m_overlays[key];
		block( o );
	}
}
- (void)save {

	NSMutableDictionary* toSave = [[NSMutableDictionary alloc] init];
	
	for(NSString* key in m_overlays)
	{
		Overlay* o = m_overlays[key];
		NSDictionary* e = [o toDictionary];
		/*
		NSMutableDictionary* e = [[NSMutableDictionary alloc] init];
//		[e setObject:o.url forKey:@"url"];	// url is key, no need to duplicate
		[e setObject:o.title forKey:@"title"];
		[e setObject:[NSNumber numberWithFloat:o.position.x] forKey:@"posX"];
		[e setObject:[NSNumber numberWithFloat:o.position.y] forKey:@"posY"];
		*/
		[toSave setObject:e forKey:o.url];
	}
	NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
	NSString *documentsDirectory = [pathArray objectAtIndex:0];
	NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"osx-overlay.plist"];
	BOOL status = [toSave writeToFile:filePath atomically:YES];
	if( !status )
	{
		NSLog(@"Error: Save failed!");
	}
}

- (BOOL)load {
	NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
	NSString *documentsDirectory = [pathArray objectAtIndex:0];
	NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"osx-overlay.plist"];
	NSDictionary *toLoad = [NSDictionary dictionaryWithContentsOfFile:filePath];
	
	if( toLoad == nil )
	{
		return NO;
	}
	
	[m_overlays removeAllObjects];	// ???
	
	for(NSString* key in toLoad)
	{
		NSDictionary* e = [toLoad objectForKey:key];
		Overlay* o = [[Overlay alloc] init];
		
//		Overlay* o = [self findOrCreateForUrl:key];
		[o fromDictionary:e];
		[o setUrl:key];	// :HACK: see url/key thingy, allow loading of old for the moment
		/*
		[o setUrl:key];
		[o setTitle:[e objectForKey:@"title"]];
		NSNumber* posX = [e objectForKey:@"posX"];
		NSNumber* posY = [e objectForKey:@"posY"];
		o.position = NSMakePoint( [posX floatValue], [posY floatValue]);
		 */
		[self insert:o];
	}
	
	return YES;
}

@end
