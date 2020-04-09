//
//  OverlayConfigWindowController.m
//  overlay
//
//  Created by anti on 08.04.20.
//  Copyright © 2020 Omni-Mad. All rights reserved.
//

#import "OverlayConfigWindowController.h"

@interface OverlayConfigWindowController ()
@property (nonatomic) Overlay* overlay;
@property Overlay* modifiedOverlay;
@end

@implementation OverlayConfigWindowController

@synthesize delegate;

- (void)windowDidLoad {
    [super windowDidLoad];
	NSLog(@"OverlayConfigWindow Loaded");
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
	[self.labelTextField setStringValue:self.modifiedOverlay.title];
	[self.urlTextField setStringValue:@"[hidden]"];
//	[self.urlTextField setStringValue:self.modifiedOverlay.url];
	[self.showUrlCheckBox setState:NSControlStateValueOff];
	[self.startupStateComboBox addItemWithObjectValue:@"On"];
	[self.startupStateComboBox addItemWithObjectValue:@"Off"];
	[self.startupStateComboBox addItemWithObjectValue:@"Last"];
	[self.startupStateComboBox selectItemWithObjectValue:@"Last"];
	
	[self.positionXTextField setIntegerValue:self.modifiedOverlay.position.x];
	[self.positionYTextField setIntegerValue:self.modifiedOverlay.position.y];

	[self showUrlToggled:self.showUrlCheckBox];
	[self onModification];
}

- (IBAction)saveButtonClicked:(NSButton *)sender {
	if( [delegate respondsToSelector:@selector(overlayChanged:was:)] ){
		[self.delegate overlayChanged:self.modifiedOverlay was:self.overlay];
	}
}

- (IBAction)urlChanged:(NSTextField *)sender {
	NSLog(@"URL Changed");
	NSString* newUrl = [self.urlTextField stringValue];
	if( ![newUrl isEqualTo:self.modifiedOverlay.url] ) {
		[self.modifiedOverlay setUrl:newUrl];
		[self onModification];
	}
}

- (IBAction)labelChanged:(NSTextField *)sender {
	NSLog(@"Label Changed");
	NSString* newLabel = [self.labelTextField stringValue];
	if( ![newLabel isEqualTo:self.modifiedOverlay.title] ) {
		[self.modifiedOverlay setTitle:newLabel];
		[self onModification];
	}
}

- (IBAction)showUrlToggled:(NSButton *)sender {
	if( [self.showUrlCheckBox state] == NSControlStateValueOn )
	{
		[self.urlTextField setStringValue:self.modifiedOverlay.url];
		[self.urlTextField setEnabled:true];
	}
	else
	{
		[self.urlTextField setStringValue:@"[hidden]"];
		[self.urlTextField setEnabled:false];
	}
}

- (void)onModification {
	if( [self.overlay isEqualTo:self.modifiedOverlay] ) {
//		[self.saveButton setStringValue:@"Save"];
		[self.saveButton setTitle:@"Save"];
		[self.saveButton setEnabled:false];
	} else {
//		[self.saveButton setStringValue:@"* Save"];
		[self.saveButton setTitle:@"* Save"];
		[self.saveButton setEnabled:true];
	}
}
- (void)setOverlay:(Overlay *)overlay {
	_overlay = overlay;
	self.modifiedOverlay = [_overlay mutableCopy];
}

- (IBAction)positionYChanged:(id)sender {
	NSInteger posY = [self.positionYTextField integerValue];
	if( posY != self.modifiedOverlay.position.y ) {
		[self.modifiedOverlay setPositionY:posY];
		[self onModification];
		[self onPositionChanged];
	}
}

- (IBAction)positionXChanged:(NSTextField *)sender {
	NSInteger posX = [self.positionXTextField integerValue];
	if( posX != self.modifiedOverlay.position.x ) {
		[self.modifiedOverlay setPositionX:posX];
		[self onModification];
		[self onPositionChanged];
	}
}

- (IBAction)cancelButtonClicked:(NSButton *)sender {
	if( [delegate respondsToSelector:@selector(overlayChangeCanceled:)] ){
		[self.delegate overlayChangeCanceled:self.overlay];
	}
}

- (void)onPositionChanged {
	if( [delegate respondsToSelector:@selector(overlayPositionChanged:)] ){
		[self.delegate overlayPositionChanged:self.modifiedOverlay];
	}

}

@end
