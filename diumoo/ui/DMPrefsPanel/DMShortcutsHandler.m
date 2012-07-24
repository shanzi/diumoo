//
//  DMShortcutsHandler.m
//  diumoo
//
//  Created by Shanzi on 12-7-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DMShortcutsHandler.h"
#import "MASShortcut.h"
#import "MASShortcut+UserDefaults.h"
#import "MASShortcutView+UserDefaults.h"


@implementation DMShortcutsHandler

+(void)registrationShortcuts
{
    id values = [[NSUserDefaultsController sharedUserDefaultsController] values];
    if ([[values valueForKey:@"usesMediaKey"] integerValue]==NSOnState) {
        
        [MASShortcut registerGlobalShortcutWithUserDefaultsKey:keyPlayShortcut
                                                       handler:^{
                                                           DMLog(@"play");
                                                       }];
        
        [MASShortcut registerGlobalShortcutWithUserDefaultsKey:keySkipShortcut
                                                       handler:^{
                                                           DMLog(@"skip");
                                                       }];
        
        [MASShortcut registerGlobalShortcutWithUserDefaultsKey:keyRateShortcut
                                                       handler:^{
                                                           DMLog(@"rate");
                                                       }];
        
        [MASShortcut registerGlobalShortcutWithUserDefaultsKey:keyBanShortcut
                                                       handler:^{
                                                           DMLog(@"ban");
                                                       }];
        
    }
    else {
        [MASShortcut unregisterGlobalShortcutWithUserDefaultsKey:keyPlayShortcut];
        [MASShortcut unregisterGlobalShortcutWithUserDefaultsKey:keyRateShortcut];
        [MASShortcut unregisterGlobalShortcutWithUserDefaultsKey:keySkipShortcut];
        [MASShortcut unregisterGlobalShortcutWithUserDefaultsKey:keyBanShortcut];
    }
    
    [MASShortcut registerGlobalShortcutWithUserDefaultsKey:keyTogglePanelShortcut
                                                   handler:^{
                                                       DMLog(@"toggle panel");
                                                   }];
    [MASShortcut registerGlobalShortcutWithUserDefaultsKey:keyShowPrefsPanel
                                                   handler:^{
                                                       DMLog(@"prefs ");
                                                   }];
}




@end
