//
//  DMPlayableCapsuleDelegate.h
//  diumoo-core
//
//  Created by Shanzi on 12-6-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DMPlayableCapsuleDelegate <NSObject>

-(void) playableCapsule:(id)capsule loadStateChanged:(long) state;
-(void) playableCapsuleDidPlay:(id)capsule;
-(void) playableCapsuleWillPause:(id)capsule;
-(void) playableCapsuleDidPause:(id)capsule;
-(void) playableCapsuleDidEnd:(id)capsule;

@end
