//
//  OverlayConfigWindowController.h
//  overlay
//
//  Created by anti on 08.04.20.
//  Copyright © 2020 Omni-Mad. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "Overlay.h"

NS_ASSUME_NONNULL_BEGIN

@protocol OverlayConfigWindowControllerDelegate <NSObject>
@optional
- (void)overlayChanged:(Overlay *)overlay was:(Overlay *)oldOverlay;
- (void)overlayChangeCanceled:(Overlay *)overlay;
- (void)overlayPositionChanged:(Overlay *)overlay;
- (void)overlayMidiNoteRequest;
- (void)overlayCancelMidiNoteRequest;
@end

@interface OverlayConfigWindowController : NSWindowController

- (void)midiNoteAnswer:(unsigned char)note;

@property (weak) IBOutlet NSTextField *labelTextField;
@property (weak) IBOutlet NSTextField *urlTextField;
@property (weak) IBOutlet NSComboBox *startupStateComboBox;
@property (weak) IBOutlet NSButton *saveButton;
@property (weak) IBOutlet NSButton *showUrlCheckBox;
@property (weak) IBOutlet NSButton *cancelButton;
@property (weak) IBOutlet NSTextField *positionXTextField;
@property (weak) IBOutlet NSTextField *positionYTextField;
@property (weak) IBOutlet NSTextField *uuidLabel;
@property (weak) IBOutlet NSButton *midiOnNoteButton;
@property (weak) IBOutlet NSButton *midiOffNoteButton;

- (IBAction)labelChanged:(NSTextField *)sender;
- (IBAction)urlChanged:(NSTextField *)sender;
- (IBAction)saveButtonClicked:(NSButton *)sender;
- (IBAction)showUrlToggled:(NSButton *)sender;
- (IBAction)cancelButtonClicked:(NSButton *)sender;
- (IBAction)positionXChanged:(NSTextField *)sender;
- (IBAction)positionYChanged:(id)sender;
- (IBAction)startupStateComboBoxChanged:(NSComboBox *)sender;
- (IBAction)midiOnNoteButtonClicked:(NSButton *)sender;
- (IBAction)midiOffNoteButtonClicked:(NSButton *)sender;

- (void)setOverlay:(Overlay *)overlay;


@property (nonatomic, weak) id <OverlayConfigWindowControllerDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
