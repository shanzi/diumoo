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
    [self handleDockIconDisplayWithChange:nil];
    
    [self performSelectorInBackground:@selector(startPlayInBackground) withObject:nil];
    
    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:@"showDockIcon" 
                                               options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)
                                               context:nil];
    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:@"displayAlbumCoverOnDock" 
                                               options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)
                                               context:nil];
    
    // handle dock icon
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (keyPath == @"showDockIcon") {
        [self handleDockIconDisplayWithChange:change];
    }
    else if(keyPath == @"displayAlbumCoverOnDock")
    {
        NSInteger new  = [[change valueForKey:@"new"] integerValue];
        if (new == NSOnState) {
            [NSApp setApplicationIconImage:center.playingCapsule.picture];
        }
        else {
            [NSApp setApplicationIconImage:nil];
        }
    }
}

-(void) handleDockIconDisplayWithChange:(id)change
{
    id values = [[NSUserDefaultsController sharedUserDefaultsController] values];
    NSInteger displayIcon = [[values valueForKey:@"showDockIcon"] integerValue];
    if (displayIcon == NSOnState) {
        ProcessSerialNumber psn = { 0, kCurrentProcess };
        TransformProcessType(&psn, kProcessTransformToForegroundApplication);
    }
    else if(change == nil){
        ProcessSerialNumber psn = { 0, kCurrentProcess };
        TransformProcessType(&psn, kProcessTransformToUIElementApplication);
    }
}

-(void) startPlayInBackground;
{
    [[DMDoubanAuthHelper sharedHelper] authWithDictionary:nil];
    [center fireToPlayDefaultChannel];
}



-(void) applicationWillTerminate:(NSNotification *)notification
{
    [center stopForExit];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
	if (flag) {
		return NO;
	}	
    else
	{
        return YES;	
	}
    
}

-(void) makeDefaultPreference
{
    NSDictionary *defaultPreferences = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInteger:1],@"channel",
                          [NSNumber numberWithFloat:1.0],@"volume",
                          [NSNumber numberWithInteger:2],@"max_wait_playlist_count", 
                          [NSNumber numberWithInteger:NSOnState],@"autoCheckUpdate",
                          [NSNumber numberWithInteger:NSOnState],@"showDockIcon",
                          [NSNumber numberWithInteger:NSOnState],@"displayAlbumCoverOnDock",
                          [NSNumber numberWithInteger:NSOnState],@"enableGrowl",
                          [NSNumber numberWithInteger:NSOnState],@"enableEmulateITunes",
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
    [PLTabPreferenceControl showPrefsAtIndex:0];
}


@end
