//
//  DMApp.m
//  diumoo
//
//  Created by Shanzi on 12-6-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DMApp.h"

@implementation DMApp

-(void) sendEvent:(NSEvent *)event
{
    BOOL shouldHandleMediaKeyEventLocally = ![SPMediaKeyTap usesGlobalMediaKeyTap];
    if(shouldHandleMediaKeyEventLocally && [event type] == NSSystemDefined && [event subtype] == 8 )
    {
        [(id)[self delegate] mediaKeyTap:nil receivedMediaKeyEvent:event];
    }
    [super sendEvent:event];
}


@end
