//
//  MidiInput.h
//  overlay
//
//  Created by anti on 06.04.20.
//  Copyright © 2020 Omni-Mad. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MidiInput : NSObject
typedef void (^NoteOnBlock)(unsigned char note);

- (void)registerNoteOnBlock:(NoteOnBlock)block;
- (void)sendNoteOn:(unsigned char)note withVelocity:(unsigned char)velocity onChannel:(unsigned char)channel;
@end

NS_ASSUME_NONNULL_END
