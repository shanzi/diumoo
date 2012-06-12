//
//  DMChannelListUpdater.h
//  diumoo
//
//  Created by Shanzi on 12-6-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMDoubanAuthHelper.h"

@interface DMChannelListHandler : NSObject

@property(retain)NSArray* public_list;
@property(retain)NSArray* dj_list;
@property(retain)NSMutableSet* dj_collected_list;

+(DMChannelListHandler*) sharedHandler;
+(DMChannelListHandler*) sharedHandlerWithCollectedChannels:(NSArray*) array;

-(id) initWithCollectedChannels:(NSArray*) array;
-(void) updateChannelList;
-(void) collectDjChannelWithChannelID:(NSString*) cid;
-(void) uncollectDjChannelWithChannelId:(NSString*) cid;
@end
