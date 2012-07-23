//
//  DMNotificationCenter.h
//  diumoo
//
//  Created by Shanzi on 12-7-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Growl/Growl.h>
@class DMPlayableCapsule;

@interface DMNotificationCenter : NSObject<GrowlApplicationBridgeDelegate>

-(void) notifyMusicWithCapsule:(DMPlayableCapsule*) capsule;

@end
