//
//  DMNotificationCenter.h
//  diumoo
//
//  Created by Shanzi on 12-7-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Growl/Growl.h>
#import "DMPlayableCapsule.h"
#import "DMPanelWindowController.h"

@interface DMNotificationCenter : NSObject<GrowlApplicationBridgeDelegate,NSUserNotificationCenterDelegate>

-(void) notifyMusicWithCapsule:(DMPlayableCapsule*) capsule;
-(void) clearNotifications;

@end
