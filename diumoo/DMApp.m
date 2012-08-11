//
//  DMApp.m
//  diumoo
//
//  Created by Shanzi on 12-6-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DMApp.h"
#import "DMService.h"

@implementation DMApp

-(id) init
{
    self = [super init];
    if(self)
    {
        NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
        LSSetDefaultHandlerForURLScheme((CFStringRef)@"dm", (__bridge CFStringRef)bundleID);
        
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

-(void) sendEvent:(NSEvent *)event
{
    BOOL shouldHandleMediaKeyEventLocally = ![SPMediaKeyTap usesGlobalMediaKeyTap];
    if(shouldHandleMediaKeyEventLocally && [event type] == NSSystemDefined && [event subtype] == 8 )
    {
        [(id)[self delegate] mediaKeyTap:nil receivedMediaKeyEvent:event];
    }
    [super sendEvent:event];
}

-(NSString*) openedURLString
{
    return openedURLString;
}

@end
