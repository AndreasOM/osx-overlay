//
//  OverlayConfigWindowController.m
//  overlay
//
//  Created by anti on 08.04.20.
//  Copyright © 2020 Omni-Mad. All rights reserved.
//

#import "OverlayConfigWindowController.h"

enum MidiNoteRequestState { None, OnNoteRequested, OffNoteRequested };

@interface OverlayConfigWindowController ()
@property (nonatomic) Overlay* overlay;
@property Overlay* modifiedOverlay;
@property enum MidiNoteRequestState midiNoteRequestState;
@end


@implementation OverlayConfigWindowController

@synthesize delegate;

- (void)windowDidLoad {
    [super windowDidLoad];
	NSLog(@"OverlayConfigWindow Loaded");
	[self.uuidLabel setStringValue:[self.modifiedOverlay.uuid UUIDString]];
	[self.labelTextField setStringValue:self.modifiedOverlay.title];
	[self.urlTextField setStringValue:@"[hidden]"];
	[self.showUrlCheckBox setState:NSControlStateValueOff];
	[self.startupStateComboBox addItemWithObjectValue:@"On"];	// :TODO: this list should come from Overlay
	[self.startupStateComboBox addItemWithObjectValue:@"Off"];
	[self.startupStateComboBox addItemWithObjectValue:@"Last"];
	[self.startupStateComboBox selectItemWithObjectValue:self.modifiedOverlay.startupStateAsString];
	
	[self.reloadOnEnableCheckBox setState:self.modifiedOverlay.reloadOnEnable?NSControlStateValueOn:NSControlStateValueOff];
	[self.positionXTextField setIntegerValue:self.modifiedOverlay.position.x];
	[self.positionYTextField setIntegerValue:self.modifiedOverlay.position.y];

	[self.midiOnNoteButton setTitle:[NSString stringWithFormat:@"%02X", self.modifiedOverlay.midiOnNote]];
	[self.midiOffNoteButton setTitle:[NSString stringWithFormat:@"%02X", self.modifiedOverlay.midiOffNote]];
	[self showUrlToggled:self.showUrlCheckBox];
	[self onModification];
	
	self.midiNoteRequestState = None;
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

- (IBAction)midiOffNoteButtonClicked:(NSButton *)sender {
	if( self.midiNoteRequestState == None )
	{
		// new request
		if( [delegate respondsToSelector:@selector(overlayMidiNoteRequest)] ){
			[self.delegate overlayMidiNoteRequest];
		}
		self.midiNoteRequestState = OffNoteRequested;
	}
	else
	{
		// cancel old request
		if( [delegate respondsToSelector:@selector(overlayCancelMidiNoteRequest)] ){
			[self.delegate overlayCancelMidiNoteRequest];
		}
		self.midiNoteRequestState = None;
	}
}

- (IBAction)midiOnNoteButtonClicked:(NSButton *)sender {
	if( self.midiNoteRequestState == None )
	{
		// new request
		if( [delegate respondsToSelector:@selector(overlayMidiNoteRequest)] ){
			[self.delegate overlayMidiNoteRequest];
		}
		self.midiNoteRequestState = OnNoteRequested;
	}
	else
	{
		// cancel old request
		if( [delegate respondsToSelector:@selector(overlayCancelMidiNoteRequest)] ){
			[self.delegate overlayCancelMidiNoteRequest];
		}
		self.midiNoteRequestState = None;
	}
}

- (IBAction)reloadOnEnableCheckBoxToggled:(id)sender {
	self.modifiedOverlay.reloadOnEnable = [self.reloadOnEnableCheckBox state] == NSControlStateValueOn;
	[self onModification];
}

- (void)midiNoteAnswer:(unsigned char)note {
	switch( self.midiNoteRequestState )
	{
		case None:
			// :TODO: we didn't request that, or maybe just changed our mind without telling the caller?
			break;
		case OnNoteRequested:
			{
				dispatch_async(dispatch_get_main_queue(), ^{
					self.modifiedOverlay.midiOnNote = note;
					[self.midiOnNoteButton setTitle:[NSString stringWithFormat:@"%02X", self.modifiedOverlay.midiOnNote]];
					[self onModification];
				});
				self.midiNoteRequestState = None;
			}
			break;
		case OffNoteRequested:
			{
				dispatch_async(dispatch_get_main_queue(), ^{
					self.modifiedOverlay.midiOffNote = note;
					[self.midiOffNoteButton setTitle:[NSString stringWithFormat:@"%02X", self.modifiedOverlay.midiOffNote]];
					[self onModification];
				});
				self.midiNoteRequestState = None;
			}
			break;
	}
}

- (IBAction)startupStateComboBoxChanged:(NSComboBox *)sender {
	NSString* value = [self.startupStateComboBox stringValue];
	NSLog(@"Startup State changed to %@", value );
	enum OverlayStartupState state = [Overlay startupStateFromString:value];
	[self.modifiedOverlay setStartupState:state];
	[self onModification];
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
