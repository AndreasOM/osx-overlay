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

@end
