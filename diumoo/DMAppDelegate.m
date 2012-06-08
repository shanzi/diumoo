//
//  DMAppDelegate.m
//  diumoo
//
//  Created by Shanzi on 12-6-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DMAppDelegate.h"

@implementation DMAppDelegate
@synthesize center;

-(void) applicationDidFinishLaunching:(NSNotification *)notification
{
    [center fireToPlay:nil];
}


-(void)mediaKeyTap:(SPMediaKeyTap*)keyTap receivedMediaKeyEvent:(NSEvent*)event{
    
    int keyCode = (([event data1] & 0xFFFF0000) >> 16);
    int keyFlags = ([event data1] & 0x0000FFFF);
    int keyState = (((keyFlags & 0xFF00) >> 8)) ==0xA;
    if(keyState==0)
        switch (keyCode) {
            case NX_KEYTYPE_PLAY:
                break;
            case NX_KEYTYPE_FAST:
                break;
            case NX_KEYTYPE_REWIND:
                break;
        }
    
}

@end
