//
//  MidiInput.m
//  overlay
//
//  Created by anti on 06.04.20.
//  Copyright © 2020 Omni-Mad. All rights reserved.
//

#import "MidiInput.h"

#include <CoreMIDI/CoreMIDI.h>
#include <Foundation/Foundation.h>

@implementation MidiInput

MIDIClientRef client;
NSMutableArray* noteOnBlocks;

MIDIPortRef oututPortRef;
NSMutableArray* outputEndpoints;

dispatch_source_t runclockSource;

static void MIDIInputProc(const MIDIPacketList *pktlist, void *readProcRefCon, void *srcConnRefCon)
{
	[((__bridge MidiInput*)srcConnRefCon) input:pktlist ref:readProcRefCon];
}

-(id)init {
	if( self = [super init] ) {
		NSString* clientName = @"client";
		MIDIClientCreate(
						 (__bridge CFStringRef)clientName,
						 nil,
						 nil,
						 &client
						 );
		MIDIPortRef inputPortRef;
		NSString* inputPortName = @"input";
		MIDIInputPortCreate( client, (__bridge CFStringRef)inputPortName, MIDIInputProc, nil, &inputPortRef );
		
		ItemCount sourceCount = MIDIGetNumberOfSources();
		OSStatus err;
		for (ItemCount i = 0; i < sourceCount; i++) {
			MIDIEndpointRef sourcePointRef = MIDIGetSource(i);
			CFStringRef strEndPointRef = NULL;
			CFStringRef strDispnameRef = NULL;
			err = MIDIObjectGetStringProperty(sourcePointRef, kMIDIPropertyName, &strEndPointRef);
			err = MIDIObjectGetStringProperty(sourcePointRef, kMIDIPropertyDisplayName, &strDispnameRef);

			err = MIDIPortConnectSource(inputPortRef, sourcePointRef, (__bridge void * _Nullable)(self));
			if (err != noErr) {
				NSLog(@"MIDIPortConnectSource ERROR: %d", err);
				break;
			}
		}
		
		noteOnBlocks = [[NSMutableArray alloc] init];
		
		// output
		NSString* outputPortName = @"output";
		err = MIDIOutputPortCreate( client, (__bridge CFStringRef)outputPortName, &oututPortRef );
		if (err != noErr) {
			NSLog(@"MIDIOutputPortCreate ERROR: %d", err);
		}
		
		outputEndpoints = [[NSMutableArray alloc] init];
		ItemCount destinationCount = MIDIGetNumberOfDestinations();
		for (ItemCount i = 0; i < destinationCount; i++) {
			MIDIEndpointRef endpoint = MIDIGetDestination( i );
			NSValue *value = [NSValue value:&endpoint withObjCType:@encode(MIDIEndpointRef)];
			[outputEndpoints addObject:value];
		}
		
//		[self runClock:120.0f*24.0f];
		[self sendTempo];
	}
	
	return self;
}

- (void)input:(const void *)pktlist ref:(void *)readProcRefCon
{
	MIDIPacket *packet = (MIDIPacket *)&(((MIDIPacketList*)pktlist)->packet[0]);
	UInt32 packetCount = ((MIDIPacketList*)pktlist)->numPackets;
	for (NSInteger i = 0; i < packetCount; i++) {
        unsigned char msg = packet->data[0] & 0xF0;
        unsigned char ch = packet->data[0] & 0x0F;
		NSLog(@"Message %08x, Channel %08x\n", msg, ch);
		switch( msg )
		{
			case 0x90: // note on (or off if velocity zero)
				if( packet->data[ 2 ] > 0 )
				{
					unsigned char note = packet->data[ 1 ];
					NSLog(@"Note on - %d", note );
					[self callNoteOnBlocks:note];
					break;
				}
				// fallthrough
			case 0x80: // note off
				if( packet->data[ 1 ] == 0 ) // all
				{
					NSLog(@"Mute");
				}
				else
				{
					NSLog(@"Note off - %d", packet->data[ 1 ] );
				}
				break;
		}
		packet = MIDIPacketNext(packet);
	}
}

- (void)sendTempo {
//0xFF 0x51 0x03 0x07 0xA1 0x20
	unsigned char data[6];
	MIDIPacketList pktlist ;
	MIDIPacket* packet = MIDIPacketListInit(&pktlist);
	data[ 0 ] = 0xff;	// meta
	data[ 1 ] = 0x51;	// tempo
	data[ 2 ] = 3;		// 3 more bytes
	data[ 3 ] = 0x07;	//	500.000 ms per quarter note
	data[ 4 ] = 0xa1;	//
	data[ 5 ] = 0x20;	//
	packet = MIDIPacketListAdd(&pktlist, sizeof(pktlist), packet, 0, sizeof( data ), data);
	if( packet != nil )
	{
		[self broadcastPacketList:&pktlist];
	}
}
- (void)sendNoteOn:(unsigned char)note withVelocity:(unsigned char)velocity onChannel:(unsigned char)channel
{
	unsigned char data[3];
	MIDIPacketList pktlist ;
	MIDIPacket* packet = MIDIPacketListInit(&pktlist);
	data[ 0 ] = 0x90 | (channel & 0x0f );
	data[ 1 ] = note;
	data[ 2 ] = velocity;
	packet = MIDIPacketListAdd(&pktlist, sizeof(pktlist), packet, 0, sizeof( data ), data);
	if( packet != nil )
	{
		[self broadcastPacketList:&pktlist];
	}
}

- (void)runClock:(float)frequency {
	float period = 1.0f/frequency;
	
	dispatch_queue_t _queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	runclockSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,0,0, _queue);
	dispatch_source_set_timer(runclockSource, dispatch_walltime(NULL, 0), DISPATCH_TIME_NOW, period * NSEC_PER_SEC ); //2ull * NSEC_PER_SEC,1ull * NSEC_PER_SEC );
    dispatch_source_set_event_handler(runclockSource, ^{
            [self sendClock];
    });
    dispatch_resume(runclockSource);
}
- (void)sendClock {
	unsigned char data[1];
	MIDIPacketList pktlist ;
	MIDIPacket* packet = MIDIPacketListInit(&pktlist);
	data[ 0 ] = 0xf8;
	packet = MIDIPacketListAdd(&pktlist, sizeof(pktlist), packet, 0, sizeof( data ), data);
	if( packet != nil )
	{
		[self broadcastPacketList:&pktlist];
	}
}

- (void)broadcastPacketList:(MIDIPacketList*)pktlist {
	for( NSValue* value in outputEndpoints )
	{
		MIDIEndpointRef endpoint;
		[value getValue:&endpoint];
		MIDISend( oututPortRef, endpoint, pktlist );
	}
}

- (void)registerNoteOnBlock:(NoteOnBlock)block {
	[noteOnBlocks addObject:block];
}
- (void)callNoteOnBlocks:(unsigned char)note {
	for( NoteOnBlock block in noteOnBlocks )
	{
		block( note );
	}
}
@end
