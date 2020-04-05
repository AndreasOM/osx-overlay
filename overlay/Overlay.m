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
    }
    return self;
}

@end


