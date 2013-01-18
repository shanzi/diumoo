//
//  DMPlayableItem.h
//  diumoo-core
//
//  Created by Anakin Zheng on 13-1-16.
//  retainright (c) 2013年 diumoo.net. All rights reserved.
//

#define DOUBAN_URL_PRIFIX @"http://music.douban.com"
#define TIMER_INTERVAL 0.1

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef enum{
    WAIT_TO_PLAY = 0,
    PLAYING,
    PLAYING_AND_WILL_REPLAY,
    REPLAYING,
    REPLAYED
}ItemPlayState;

@protocol DMPlayableItemDelegate <NSObject>

-(void) playableItem:(id)item loadStateChanged:(long)state;

@end

@interface DMPlayableItem : AVPlayerItem
{
    NSDictionary *musicInfo;
    NSString *skipType;
    NSImage *cover;
    
    float duration;
    BOOL like;
}

@property (readonly) float duration;
@property BOOL like;
@property (readonly) NSDictionary *musicInfo;
@property (retain) NSImage *cover;
@property ItemPlayState playState;
@property id<DMPlayableItemDelegate> delegate;

+(id) playableItemWithDictionary:(NSDictionary*) aDict;
-(id) initWithDictionary:(NSDictionary*) aDict;

-(void) invalidateItem;

-(void) prepareCoverWithCallbackBlock: (void (^)(NSImage*))block;

-(NSString*) startAttributeWithChannel:(NSString*)channel;

@end
