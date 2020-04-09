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
- (NSUInteger)count {
	return [m_overlays count];
}
-(Overlay*)findOrCreateForUrl:(NSString *)url {
	if( m_overlays == nil )
	{
		m_overlays = [[NSMutableDictionary alloc] init];
	}
	
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
		NSMutableDictionary* e = [[NSMutableDictionary alloc] init];
//		[e setObject:o.url forKey:@"url"];	// url is key, no need to duplicate
		[e setObject:o.title forKey:@"title"];
		[toSave setObject:e forKey:o.url];
	}
	NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
	NSString *documentsDirectory = [pathArray objectAtIndex:0];
	NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"osx-overlay.plist"];
	BOOL status = [toSave writeToFile:filePath atomically:YES];
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
		Overlay* o = [self findOrCreateForUrl:key];
		[o setUrl:key];
		[o setTitle:[e objectForKey:@"title"]];
	}
	
	return YES;
}

@end
