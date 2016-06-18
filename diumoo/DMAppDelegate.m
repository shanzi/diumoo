//
//  DMAppDelegate.m
//  diumoo
//
//  Created by Shanzi on 12-6-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DMAppDelegate.h"
#import "DMDoubanAuthHelper.h"
#import "DMErrorLog.h"
#import "DMService.h"
#import "Shortcut.h"

@implementation DMAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification*)notification
{
    mediakeyTap = [[SPMediaKeyTap alloc] initWithDelegate:self];

    [self makeDefaultPreference];
    center = [[DMControlCenter alloc] init];

    [DMErrorLog sharedErrorLog];

#ifndef DEBUG
    [self redirectConsoleLogToDocumentFolder];
#endif

    [DMShortcutsHandler registrationShortcuts];

    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:@"showDockIcon"
                                               options:(NSKeyValueObservingOptionNew)
                                               context:nil];

    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:@"displayAlbumCoverOnDock"
                                               options:(NSKeyValueObservingOptionNew)
                                               context:nil];

    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:@"enableLogFile"
                                               options:(NSKeyValueObservingOptionNew)
                                               context:nil];

    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:@"useMediaKey"
                                               options:(NSKeyValueObservingOptionNew)
                                               context:nil];

    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:@"musicQuality"
                                               options:(NSKeyValueObservingOptionNew)
                                               context:nil];

    [self performSelectorInBackground:@selector(startPlayInBackground) withObject:nil];

    [self handleDockIconDisplayWithChange:nil];
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
    if ([keyPath isEqualToString:@"showDockIcon"]) {
        [self handleDockIconDisplayWithChange:change];
    }
    else if ([keyPath isEqualToString:@"displayAlbumCoverOnDock"]) {
        id newvalue = [change valueForKey:@"new"];
        NSInteger new = NSOnState;
        if ([newvalue respondsToSelector:@selector(integerValue)]) {
            new = [ newvalue integerValue ];
        }
        if (new == NSOnState) {
            [NSApp setApplicationIconImage:center.playingItem.cover];
        }
        else {
            [NSApp setApplicationIconImage:nil];
        }
    }
    else if ([keyPath isEqualToString:@"enableLogFile"]) {
        [self redirectConsoleLogToDocumentFolder];
    }
    else if ([keyPath isEqualToString:@"useMediaKey"]) {
        id newvalue = [change valueForKey:@"new"];
        if ([newvalue respondsToSelector:@selector(integerValue)]) {
            if ([newvalue integerValue] == NSOffState)
                [mediakeyTap stopWatchingMediaKeys];
            else
                [mediakeyTap startWatchingMediaKeys];
        }
    }
    else if ([keyPath isEqualToString:@"musicQuality"]) {
        id newvalue = [change valueForKey:@"new"];
        if ([newvalue respondsToSelector:@selector(integerValue)]) {
            NSInteger bitrate;
            if ((bitrate = [newvalue integerValue]) > 64) {
                [[NSUserDefaults standardUserDefaults] setInteger:bitrate
                                                           forKey:@"pro_musicQuality"];
            }
        }
        [center qualityChanged];
    }
}

- (void)handleDockIconDisplayWithChange:(id)change
{
    NSUserDefaults* values = [NSUserDefaults standardUserDefaults];
    NSInteger displayIcon = [[values valueForKey:@"showDockIcon"] integerValue];
    if (displayIcon == NSOnState) {
        ProcessSerialNumber psn = { 0, kCurrentProcess };
        TransformProcessType(&psn, kProcessTransformToForegroundApplication);
    }
    else if (change == nil) {
        ProcessSerialNumber psn = { 0, kCurrentProcess };
        TransformProcessType(&psn, kProcessTransformToUIElementApplication);
    }
}

- (void)startPlayInBackground;
{
    [[DMDoubanAuthHelper sharedHelper] authWithDictionary:nil];
    [center fireToPlayDefault];
    [DMService showDMNotification];
}

- (void)applicationWillTerminate:(NSNotification*)notification
{
    [NSApp setApplicationIconImage:nil];
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.apple.iTunes.playerInfo"
                                                                   object:@"com.apple.iTunes.player"
                                                                 userInfo:@{ @"Player State" : @"Paused" }];
    [[DMPlayRecordHandler sharedRecordHandler] removeVersionsToLimit];
    [center stopForExit];
}

- (void)makeDefaultPreference
{
    NSDictionary* preferences = @{ @"channel" : @(1),
        @"volume" : @(1.0),
        @"versionsLimit" : @(100),
        @"displayAlbumCoverOnDock" : @(NSOnState),
        @"enableNotification" : @(NSOnState),
        @"enableEmulateITunes" : @(NSOnState),
        @"showDockIcon" : @(NSOnState),
        @"filterAds" : @(NSOnState),
        @"enableLog" : @(NSOnState),
        @"enableLogFile" : @(NSOnState),
        @"useMediaKey" : @(NSOnState),
        @"musicQuality" : @(64),
        @"pro_musicQuality" : @(192)
    };
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults registerDefaults:preferences];
    [[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:preferences];

    if ([defaults valueForKey:@"shortcutDidRegistered"] != nil) {
        // clear old short cuts as we updated MASShortcut
        // This code is for compatibility
        DMLog(@"Remove old shortcuts");
        [defaults setValue:nil forKey:keyPlayShortcut];
        [defaults setValue:nil forKey:keySkipShortcut];
        [defaults setValue:nil forKey:keyRateShortcut];
        [defaults setValue:nil forKey:keyBanShortcut];
        [defaults setValue:nil forKey:keyTogglePanelShortcut];
        [defaults setValue:nil forKey:keyShowPrefsPanel];
        [defaults setValue:nil forKey:@"shortcutDidRegistered"];
    }

    // Register default shortcuts
    int flags = (NSAlternateKeyMask | NSCommandKeyMask);
    [[MASShortcutBinder sharedBinder] registerDefaultShortcuts:
                                          @{ keyPlayShortcut : [MASShortcut shortcutWithKeyCode:kVK_ANSI_Semicolon modifierFlags:flags],
                                             keySkipShortcut : [MASShortcut shortcutWithKeyCode:kVK_ANSI_Quote modifierFlags:flags],
                                             keyRateShortcut : [MASShortcut shortcutWithKeyCode:kVK_ANSI_Comma modifierFlags:flags],
                                             keyBanShortcut : [MASShortcut shortcutWithKeyCode:kVK_ANSI_Period modifierFlags:flags],
                                             keyTogglePanelShortcut : [MASShortcut shortcutWithKeyCode:kVK_ANSI_Slash modifierFlags:flags],
                                             keyShowPrefsPanel : [MASShortcut shortcutWithKeyCode:kVK_ANSI_P modifierFlags:flags] }];

    if ([defaults integerForKey:@"useMediaKey"] == NSOnState) {
        [mediakeyTap startWatchingMediaKeys];
    }
}

- (void)keyShortcuts:(id)key
{
    if ([key isEqualToString:keyPlayShortcut]) {
        [center playOrPause];
    }
    else if ([key isEqualToString:keySkipShortcut]) {
        [center skip];
    }
    else if ([key isEqualToString:keyRateShortcut]) {
        [center rateOrUnrate];
    }
    else if ([key isEqualToString:keyBanShortcut]) {
        [center ban];
    }
    else if ([key isEqualToString:keyTogglePanelShortcut]) {
        [center.diumooPanel togglePanel:self];
    }
    else if ([key isEqualToString:keyShowPrefsPanel]) {
        [self showPreference:nil];
    }
}

- (void)showPreference:(id)sender
{
    [PLTabPreferenceControl showPrefsAtIndex:0];
}

- (void)importOrExport:(id)sender
{
    if ([sender tag] == 1) {
        [DMService importRecordOperation];
    }
    else {
        [DMService exportRecordOperation];
    }
}

- (void)redirectConsoleLogToDocumentFolder
{
    NSInteger currentValue = [[[NSUserDefaults standardUserDefaults] valueForKey:@"enableLogFile"] integerValue];
    if (currentValue == NSOnState) {
        NSArray* dirs = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory,
            NSUserDomainMask, YES);
        NSString* pathToUserApplicationSupportFolder = dirs[0];
        NSString* pathToDiumooDataFolder = [pathToUserApplicationSupportFolder
            stringByAppendingPathComponent:@"diumoo"];

        NSString* logPath = [pathToDiumooDataFolder stringByAppendingPathComponent:@"error.log"];
        remove([logPath fileSystemRepresentation]);
        freopen([logPath fileSystemRepresentation], "a+", stderr);
    }
    else {
        [[NSUserDefaults standardUserDefaults] setInteger:NSOffState forKey:@"enableFileLog"];
    }
}

- (void)showHelp:(id)sender
{
    switch ([sender tag]) {
    case 0:
        [[NSWorkspace sharedWorkspace] openURL:
                                           [NSURL URLWithString:@"http://diumoo.net/usage"]];
        break;
    case 1:
        [[NSWorkspace sharedWorkspace] openURL:
                                           [NSURL URLWithString:@"http://diumoo.net/extensions"]];
        break;
    case 2:
        [[NSWorkspace sharedWorkspace] openURL:
                                           [NSURL URLWithString:@"http://diumoo.net/report"]];
        break;
    }
}

- (void)mediaKeyTap:(SPMediaKeyTap*)keyTap receivedMediaKeyEvent:(NSEvent*)event;
{
    NSAssert([event type] == NSSystemDefined && [event subtype] == SPSystemDefinedEventMediaKeys, @"Unexpected NSEvent in mediaKeyTap:receivedMediaKeyEvent:");
    // here be dragons...
    int keyCode = (([event data1] & 0xFFFF0000) >> 16);
    int keyFlags = ([event data1] & 0x0000FFFF);
    BOOL keyIsPressed = (((keyFlags & 0xFF00) >> 8)) == 0xA;

    if (keyIsPressed) {

        switch (keyCode) {
        case NX_KEYTYPE_PLAY:
            [center playOrPause];
            break;

        case NX_KEYTYPE_NEXT:
        case NX_KEYTYPE_FAST:
            [center skip];
            break;

        case NX_KEYTYPE_PREVIOUS:
        case NX_KEYTYPE_REWIND:
            [center rateOrUnrate];
            break;
        }
    }
}

@end
