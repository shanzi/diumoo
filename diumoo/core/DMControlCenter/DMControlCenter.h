//
//  DMControlCenter.h
//  diumoo-core
//
//  Created by Shanzi on 12-6-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//


#define kPauseOperationTypePass @"pass"
#define kPauseOperationTypeSkip @"skip"
#define kPauseOperationTypeFetchNewPlaylist @"newplaylist"
#define kPauseOperationTypePlaySpecial @"special"

#import <Foundation/Foundation.h>
#import "DMPlayableCapsule.h"
#import "DMPlaylistFetcher.h"
#import "DMPanelWindowController.h"
#import "DMPlayRecordHandler.h"
#import "DMNotificationCenter.h"

@interface DMControlCenter : NSObject<DMPlayableCapsuleDelegate,DMPlaylistFetcherDeleate,DMPanelWindowDelegate,DMPlayRecordHandlerDelegate>
// {

@property(retain) NSString* channel;

@property(retain) DMPlayableCapsule* playingCapsule;
@property(retain) DMPlayableCapsule* songToPlay;

@property(assign) DMPlaylistFetcher* fetcher;
@property(assign) DMNotificationCenter* notificationCenter;
@property(assign) NSMutableOrderedSet* waitPlaylist;
@property(assign) NSString* pausedOperationType;
@property(assign) NSLock* skipLock; // 用于在skip和bye的时候锁住线程，防止多余操作

@property(assign) DMPanelWindowController* mainPanel;
@property(assign) DMPlayRecordHandler* recordHandler;

@property(retain) NSMutableArray* specialWaitList;


// }

-(void) fireToPlayDefaultChannel;
-(void) stopForExit;

@end
