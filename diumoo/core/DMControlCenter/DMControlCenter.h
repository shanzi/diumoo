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

#define kTimerPulseTypePlay @"kTimerPulseTypePlay"
#define kTimerPulseTypePause @"kTimerPulseTypePause"
#define KTimerPulseTypeVolumeChange @"kTimerPulseTypeVolumeChange"

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <IOKit/pwr_mgt/IOPMLib.h>

#import "diumoo-Swift.h"
#import "DMPanelWindowController.h"
#import "DMPlayRecordHandler.h"
#import "NSDictionary+UrlEncoding.h"
#import "DMService.h"
#import "DMSearchPanelController.h"

#define TIMER_INTERVAL 0.1


typedef enum{
    PAUSE_PASS = 0,
    PAUSE_PAUSE,
    PAUSE_SKIP,
    PAUSE_NEW_PLAYLIST,
    PAUSE_SPECIAL,
    PAUSE_EXIT,
} PAUSE_OPERATION_TYPE;

@interface DMControlCenter : NSObject<DMPlayableItemDelegate,DMPlaylistFetcherDeleate,DMPanelWindowDelegate,DMPlayRecordHandlerDelegate>
{
    NSString *channel;
    
    DMPlayableItem *__strong playingItem;
    DMPlayableItem *__strong waitingItem;
    DMPlaylistFetcher *fetcher;
    
    DMNotificationCenter *notificationCenter;
    DMPanelWindowController *diumooPanel;
    DMPlayRecordHandler *recordHandler;

    BOOL canPlaySpecial;
}

@property (strong) DMPlayableItem *playingItem;
@property (strong) DMPlayableItem *waitingItem;
@property DMPanelWindowController *diumooPanel;

//self methods
-(void) fireToPlayDefault;
-(void) stopForExit;
-(void) qualityChanged;
-(void) volumeChange:(float)volume;

//methods in DMPlayableItemDelegate
- (void)playableItem:(DMPlayableItem * )item logStateChanged:(NSInteger)logStateChanged;
@end
