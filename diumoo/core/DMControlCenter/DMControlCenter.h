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

typedef enum{
    PAUSE_PASS = 0,
    PAUSE_SKIP,
    PAUSE_NEW_PLAYLIST,
    PAUSE_SPECIAL,
    PAUSE_EXIT,
} PAUSE_OPERATION_TYPE;

@interface DMControlCenter : NSObject<DMPlayableCapsuleDelegate,DMPlaylistFetcherDeleate,DMPanelWindowDelegate,DMPlayRecordHandlerDelegate>
{
    NSString *channel;
    
    DMPlayableCapsule *playingCapsule;
    DMPlayableCapsule *waitingCapsule;
    DMPlaylistFetcher *fetcher;
    NSMutableOrderedSet *waitPlaylist;
    
    DMNotificationCenter *notificationCenter;
    DMPanelWindowController *diumooPanel;
    DMPlayRecordHandler *recordHandler;
    
    NSMutableArray *specialWaitList;

    NSAutoreleasePool *bufferingMusicPool;
    BOOL canPlaySpecial;
}

@property (assign) DMPlayableCapsule *playingCapsule;
@property (retain) DMPanelWindowController *diumooPanel;

//self methods
-(void) fireToPlayDefault;
-(void) stopForExit;

//methods in DMPlayableCapsuleDelegate
-(void) playableCapsule:(id)capsule loadStateChanged:(long) state;
-(void) playableCapsuleDidPlay:(id)capsule;
-(void) playableCapsuleWillPause:(id)capsule;
-(void) playableCapsuleDidPause:(id)capsule;
-(void) playableCapsuleDidEnd:(id)capsule;

@end
