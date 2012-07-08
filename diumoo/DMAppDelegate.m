//
//  DMAppDelegate.m
//  diumoo
//
//  Created by Shanzi on 12-6-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DMAppDelegate.h"
#import "DMDoubanAuthHelper.h"

@implementation DMAppDelegate

-(void) applicationDidFinishLaunching:(NSNotification *)notification
{
    [self makeDefaultPreference];
    [[DMDoubanAuthHelper sharedHelper] authWithDictionary:nil];
    [center fireToPlayDefaultChannel];
}

-(void) applicationWillTerminate:(NSNotification *)notification
{
    
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
	if (flag) {
		return NO;
	}	
    else
	{
        [center.mainPanel showWindow:nil];
        return YES;	
	}
    
}

-(void) makeDefaultPreference
{
    NSDictionary *defaultPreferences = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInteger:1],@"channel",
                          [NSNumber numberWithFloat:1.0],@"volume",
                           nil];
    [[NSUserDefaultsController sharedUserDefaultsController]
     setInitialValues:defaultPreferences];
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

-(void) showPreference:(id)sender
{
    [[DMPrefsPanelDataProvider sharedPrefs] showPreferences];
}

@end
