//
//  DMAppDelegate.m
//  diumoo
//
//  Created by Shanzi on 12-6-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DMAppDelegate.h"
#import "DMDoubanAuthHelper.h"
#import "DMService.h"


@implementation DMAppDelegate

-(void) applicationDidFinishLaunching:(NSNotification *)notification
{
    //redictor NSLog() to diumoo folder
    [self redirectConsoleLogToDocumentFolder];
    
    [self makeDefaultPreference];
    
    mediaKeyTap = [[SPMediaKeyTap alloc] initWithDelegate:self];
    
    [DMShortcutsHandler registrationShortcuts];
    
    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:@"showDockIcon" 
                                               options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)
                                               context:nil];
    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:@"displayAlbumCoverOnDock" 
                                               options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)
                                               context:nil];
        
    [self performSelectorInBackground:@selector(startPlayInBackground) withObject:nil];
    [self handleDockIconDisplayWithChange:nil];
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (keyPath == @"showDockIcon") {
        [self handleDockIconDisplayWithChange:change];
    }
    else if(keyPath == @"displayAlbumCoverOnDock")
    {
        id newvalue = [change valueForKey:@"new"];
        NSInteger new = NSOnState;
        if ([newvalue respondsToSelector:@selector(integerValue)]) {
            new = [newvalue integerValue];
        }
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
    NSUserDefaults* values = [NSUserDefaults standardUserDefaults];
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
    [center fireToPlayDefault];
    [DMService showDMNotification];
}



-(void) applicationWillTerminate:(NSNotification *)notification
{
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.apple.iTunes.playerInfo"
                                                                   object:@"com.apple.iTunes.player"
                                                                 userInfo:@{@"Player State": @"Paused"}];
    [center stopForExit];
    [center release];
    [mediaKeyTap release];
}

-(void) makeDefaultPreference
{
    NSDictionary *preferences=@{
    @"channel" : @1,
    @"volume":@1.0f,
    @"max_wait_playlist_count":@2,
    @"autoCheckUpdate":@(NSOnState),
    @"displayAlbumCoverOnDock":@(NSOnState),
    @"enableGrowl":@(NSOnState),
    @"enableEmulateITunes":@(NSOnState),
    @"usesMediaKey":@(NSOnState),
    @"showDockIcon":@(NSOnState),
    @"filterAds":@(NSOffState),
    
    };
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:preferences];
    
}

-(void)mediaKeyTap:(SPMediaKeyTap*)keyTap receivedMediaKeyEvent:(NSEvent*)event{
    
    int keyCode = (([event data1] & 0xFFFF0000) >> 16);
    int keyFlags = ([event data1] & 0x0000FFFF);
    int keyState = (((keyFlags & 0xFF00) >> 8)) ==0xA;
    if(keyState==0)
        switch (keyCode) {
            case NX_KEYTYPE_PLAY:
                [center playOrPause];
                break;
            case NX_KEYTYPE_FAST:
                [center skip];
                break;
        }
}

-(void) keyShortcuts:(id)key
{
    if([key isEqualToString:keyPlayShortcut])
    {
        [center playOrPause];
    }
    else if ([key isEqualToString:keySkipShortcut]) 
    {
        [center skip];
    }
    else if ([key isEqualToString:keyRateShortcut])
    {
        [center rateOrUnrate];
    }
    else if ([key isEqualToString:keyBanShortcut])
    {
        [center ban];
    }
    else if ([key isEqualToString:keyTogglePanelShortcut])
    {
        [center.diumooPanel togglePanel:nil];
    }
    else if([key isEqualToString:mediaKeyOn])
    {
        [mediaKeyTap startWatchingMediaKeys];
    }
    else if([key isEqualToString:mediaKeyOff])
    {
        [mediaKeyTap stopWatchingMediaKeys];
    }
    else 
    {
        [self showPreference:nil];
    }
}

-(void) showPreference:(id)sender
{
    [PLTabPreferenceControl showPrefsAtIndex:0];
}

-(void) importOrExport:(id)sender
{
    if ([sender tag] == 1) {
        [DMService importRecordOperation];
    }
    else
    {
        [DMService exportRecordOperation];
    }
}

- (void) redirectConsoleLogToDocumentFolder
{
    NSArray* dirs = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory,
                                                        NSUserDomainMask, YES);
    NSString* pathToUserApplicationSupportFolder = dirs[0];
    NSString* pathToDiumooDataFolder = [pathToUserApplicationSupportFolder
                                        stringByAppendingPathComponent:@"diumoo"];
    
    NSString *logPath = [pathToDiumooDataFolder stringByAppendingPathComponent:@"error.log"];
    freopen([logPath fileSystemRepresentation],"a+",stderr);
}


@end
