//
//  DMNotificationCenter.h
//  diumoo
//
//  Created by Shanzi on 12-7-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Growl/Growl.h>
#import "DMPlayableItem.h"
#import "DMPanelWindowController.h"

@interface DMNotificationCenter : NSObject<GrowlApplicationBridgeDelegate,NSUserNotificationCenterDelegate>
{
    
}

-(void) notifyMusicWithItem:(DMPlayableItem*) item;
-(void) clearNotifications;

@end
