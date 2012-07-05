//
//  DMControlCenter.h
//  diumoo-core
//
//  Created by Shanzi on 12-6-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#define MAX_WAIT_PLAYLIST_COUNT 2

#define kPauseOperationTypePass @"pass"
#define kPauseOperationTypeSkip @"skip"
#define kPauseOperationTypeFetchNewPlaylist @"newplaylist"

#import <Foundation/Foundation.h>
#import "DMPlayableCapsule.h"
#import "DMPlaylistFetcher.h"
#import "DMPanelWindowController.h"
#import "DMPlayRecordHandler.h"


@interface DMControlCenter : NSObject<DMPlayableCapsuleDelegate,DMPlaylistFetcherDeleate,DMPanelWindowDelegate,DMPlayRecordHandlerDelegate>
// {

@property(retain) NSString* channel;

@property(retain) DMPlayableCapsule* playingCapsule;
@property(assign) DMPlayableCapsule* songToPlay;

@property(assign) DMPlaylistFetcher* fetcher;
@property(assign) NSMutableOrderedSet* waitPlaylist;
@property(assign) NSString* pausedOperationType;
@property(assign) NSLock* skipLock; // 用于在skip和bye的时候锁住线程，防止多余操作

@property(assign) DMPanelWindowController* mainPanel;
@property(assign) DMPlayRecordHandler* recordHandler;


// }

-(void) fireToPlay:(NSString*)startSongAttribute;
-(void) fireToPlayDefaultChannel;

@end
