//
//  DMShortcutsHandler.m
//  diumoo
//
//  Created by Shanzi on 12-7-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DMShortcutsHandler.h"
#import "SPMediaKeyTap.h"
#import "MASShortcut.h"
#import "MASShortcut+UserDefaults.h"
#import "MASShortcutView+UserDefaults.h"

@implementation DMShortcutsHandler

+(void)registrationShortcuts
{
    NSUserDefaults* values = [NSUserDefaults standardUserDefaults];
    if ([[values valueForKey:@"usesMediaKey"] integerValue]!=NSOnState) {
        [MASShortcut registerGlobalShortcutWithUserDefaultsKey:keyPlayShortcut
                                                       handler:^{
                                                           [[NSApp delegate] 
                                                            performSelector:@selector(keyShortcuts:)
                                                            withObject:keyPlayShortcut];
                                                       }];
        [MASShortcut registerGlobalShortcutWithUserDefaultsKey:keySkipShortcut
                                                       handler:^{
                                                           [[NSApp delegate] 
                                                            performSelector:@selector(keyShortcuts:)
                                                            withObject:keySkipShortcut];
                                                       }];
        [[NSApp delegate] performSelector:@selector(keyShortcuts:) withObject:mediaKeyOff];
    }
    else {
        [MASShortcut unregisterGlobalShortcutWithUserDefaultsKey:keyPlayShortcut];
        [MASShortcut unregisterGlobalShortcutWithUserDefaultsKey:keySkipShortcut];
        [[NSApp delegate] performSelector:@selector(keyShortcuts:) withObject:mediaKeyOn];
    }
    [MASShortcut registerGlobalShortcutWithUserDefaultsKey:keyRateShortcut
                                                   handler:^{
                                                       [[NSApp delegate] 
                                                        performSelector:@selector(keyShortcuts:)
                                                        withObject:keyRateShortcut];
                                                   }];
    
    [MASShortcut registerGlobalShortcutWithUserDefaultsKey:keyBanShortcut
                                                   handler:^{
                                                       [[NSApp delegate] 
                                                        performSelector:@selector(keyShortcuts:)
                                                        withObject:keyBanShortcut];
                                                   }];
    [MASShortcut registerGlobalShortcutWithUserDefaultsKey:keyTogglePanelShortcut
                                                   handler:^{
                                                       [[NSApp delegate] 
                                                        performSelector:@selector(keyShortcuts:)
                                                        withObject:keyTogglePanelShortcut];
                                                   }];
    [MASShortcut registerGlobalShortcutWithUserDefaultsKey:keyShowPrefsPanel
                                                   handler:^{
                                                       [[NSApp delegate] 
                                                        performSelector:@selector(keyShortcuts:)
                                                        withObject:keyShowPrefsPanel];
                                                   }];
    
}

@end
