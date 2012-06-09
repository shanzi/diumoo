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


@interface DMControlCenter : NSObject<DMPlayableCapsuleDelegate,DMPlaylistFetcherDeleate>
// {

@property(retain) NSString* channel;
@property(retain) DMPlayableCapsule* playingCapsule;
@property(assign) DMPlaylistFetcher* fetcher;
@property(assign) NSMutableOrderedSet* waitPlaylist;
@property(assign) NSString* pausedOperationType;
@property(assign) NSLock* skipLock; // 用于在skip和bye的时候锁住线程，防止多余操作

// }

-(void) fireToPlay:(NSString*)startSongAttribute;

//-------------------播放控制用的action函数--------------------------
-(IBAction)playOrPauseAction:(id) sender;
-(IBAction)skipAction:(id)sender;
-(IBAction)rateOrUnrateAction:(id)sender;
-(IBAction)trashAction:(id)sender;
-(IBAction)volumeChange:(id)sender;
//---------------------------------------------------------------

@end
