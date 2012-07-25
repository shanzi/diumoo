//
//  DMShortcutsHandler.h
//  diumoo
//
//  Created by Shanzi on 12-7-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define keyPlayShortcut  @"playShortcut"
#define keySkipShortcut  @"skipShortcut"
#define keyRateShortcut  @"rateShortcut"
#define keyBanShortcut  @"banShortcut"
#define keyShowPrefsPanel  @"showPrefsPanel"
#define keyTogglePanelShortcut  @"togglePanelShortcut"
#define mediaKeyOn @"mediaKeyOn"
#define mediaKeyOff @"mediaKeyOff"

@interface DMShortcutsHandler : NSObject

+(void) registrationShortcuts;

@end
