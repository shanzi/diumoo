//
//  DMNotificationCenter.h
//  diumoo
//
//  Created by Shanzi on 12-7-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMPlayableItem.h"
#import "DMPanelWindowController.h"

@interface DMNotificationCenter : NSObject<NSUserNotificationCenterDelegate>
{
    
}

-(void) notifyMusicWithItem:(DMPlayableItem*) item;
-(void) notifyBitrate;
-(void) clearNotifications;
-(void) copylinkNotification:(NSString *) url;

@end
