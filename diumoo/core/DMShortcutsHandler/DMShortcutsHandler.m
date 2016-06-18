//
//  DMShortcutsHandler.m
//  diumoo
//
//  Created by Shanzi on 12-7-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DMShortcutsHandler.h"
#import "Shortcut.h"
#import "DMAppDelegate.h"

@implementation DMShortcutsHandler

+(void)registrationShortcuts
{
	
    
    [[MASShortcutBinder sharedBinder] bindShortcutWithDefaultsKey:keyPlayShortcut
                                                   toAction:^{
                                                       [[NSApp delegate]
                                                        performSelector:@selector(keyShortcuts:)
                                                        withObject:keyPlayShortcut];
                                                   }];
    [[MASShortcutBinder sharedBinder] bindShortcutWithDefaultsKey:keySkipShortcut
                                                   toAction:^{
                                                       [[NSApp delegate]
                                                        performSelector:@selector(keyShortcuts:)
                                                        withObject:keySkipShortcut];
                                                   }];
    

    [[MASShortcutBinder sharedBinder] bindShortcutWithDefaultsKey:keyRateShortcut
                                                   toAction:^{
                                                       [[NSApp delegate] 
                                                        performSelector:@selector(keyShortcuts:)
                                                        withObject:keyRateShortcut];
                                                   }];
    
    [[MASShortcutBinder sharedBinder] bindShortcutWithDefaultsKey:keyBanShortcut
                                                   toAction:^{
                                                       [[NSApp delegate] 
                                                        performSelector:@selector(keyShortcuts:)
                                                        withObject:keyBanShortcut];
                                                   }];
    [[MASShortcutBinder sharedBinder] bindShortcutWithDefaultsKey:keyTogglePanelShortcut
                                                   toAction:^{
                                                       [[NSApp delegate] 
                                                        performSelector:@selector(keyShortcuts:)
                                                        withObject:keyTogglePanelShortcut];
                                                   }];
    [[MASShortcutBinder sharedBinder] bindShortcutWithDefaultsKey:keyShowPrefsPanel
                                                   toAction:^{
                                                       [[NSApp delegate] 
                                                        performSelector:@selector(keyShortcuts:)
                                                        withObject:keyShowPrefsPanel];
                                                   }];
	
    
}

@end
