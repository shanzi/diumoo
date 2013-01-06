//
//  DMApp.m
//  diumoo
//
//  Created by Shanzi on 12-6-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DMApp.h"
#import "DMService.h"
#import "SPMediaKeyTap.h"

@implementation DMApp

@synthesize openedURLString;

-(id) init
{
    self = [super init];
    if(self)
    {
        NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
        LSSetDefaultHandlerForURLScheme((CFStringRef)@"diumoo", (__bridge CFStringRef)bundleID);
        
        [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self
                                                           andSelector:@selector(handleEvent:withReplyEvent:)
                                                         forEventClass:kInternetEventClass
                                                            andEventID:kAEGetURL];
    }
    return self;
}


- (void)handleEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
    NSString* urlstring = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    openedURLString = [urlstring copy];
    [DMService openDiumooLink:openedURLString];
}

- (void)sendEvent:(NSEvent *)theEvent
{
	// If event tap is not installed, handle events that reach the app instead
	BOOL shouldHandleMediaKeyEventLocally = ![SPMediaKeyTap usesGlobalMediaKeyTap];
    
	if(shouldHandleMediaKeyEventLocally && [theEvent type] == NSSystemDefined && [theEvent subtype] == SPSystemDefinedEventMediaKeys) {
		[(id)[self delegate] mediaKeyTap:nil receivedMediaKeyEvent:theEvent];
	}
	[super sendEvent:theEvent];
}

@end
