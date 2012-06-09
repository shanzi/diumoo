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
{
    NSString *channel;
    NSString *pausedOperationType;
    
    NSMutableOrderedSet *waitPlaylist;
    
    DMPlayableCapsule *playingCapsule;
    DMPlaylistFetcher *fetcher;
}
@property(retain) NSString *channel;
@property(retain) DMPlayableCapsule *playingCapsule;
@property(assign) DMPlaylistFetcher *fetcher;
@property(assign) NSMutableOrderedSet *waitPlaylist;
@property(assign) NSString *pausedOperationType;


-(void) fireToPlay:(NSString*)aSong;

//-------------------播放控制用的action函数--------------------------
-(IBAction) playOrPauseAction:(id)sender;
-(IBAction) skipAction:(id)sender;
-(IBAction) volumeChange:(id)sender;
-(IBAction) skipAction:(id)sender;
//---------------------------------------------------------------

@end
