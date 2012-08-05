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
{
    NSString *channel;
    
    DMPlayableCapsule *playingCapsule;
    DMPlayableCapsule *waitingCapsule;
    DMPlaylistFetcher *fetcher;
    NSMutableOrderedSet *waitPlaylist;
    
    NSLock *skipLock;
    
    DMNotificationCenter *notificationCenter;
    DMPanelWindowController *diumooPanel;
    DMPlayRecordHandler *recordHandler;
    
    NSMutableArray *specialWaitList;
    
    NSString *pausedOperationType;
    
    NSAutoreleasePool *bufferingMusicPool;
}

@property (assign) DMPlayableCapsule *playingCapsule;
@property (retain) DMPanelWindowController *diumooPanel;

-(void) fireToPlayDefault;
-(void) stopForExit;

@end
