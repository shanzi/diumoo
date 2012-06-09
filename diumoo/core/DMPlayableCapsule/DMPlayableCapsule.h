//
//  DMPlayableCapsule.h
//  diumoo-core
//
//  Created by Shanzi on 12-5-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#define DOUBAN_URL_PRIFIX @"http://music.douban.com/"
#define TIMER_INTERVAL 0.1

//  Playable State

#import <Foundation/Foundation.h>
#import <QTKit/QTKit.h>

#import "DMPlayableCapsuleDelegate.h"

typedef enum{
    WAIT_TO_PLAY = 0,
    PLAYING,
    PLAYING_AND_WILL_REPLAY,
    REPLAYING,
    REPLAYED
}CapsulePlayState;

@interface DMPlayableCapsule : NSObject
//{

@property long loadState;
@property CapsulePlayState playState;
@property(nonatomic) float volume;

@property BOOL like;
@property float length;
@property float rating_avg;


@property(copy) NSString* aid;
@property(copy) NSString* sid;
@property(copy) NSString* ssid;
@property(copy) NSString* subtype;
@property(copy) NSString* title;
@property(copy) NSString* artist;
@property(copy) NSString* albumWithYear;
@property(copy) NSString* albumLocation;
@property(copy) NSString* musicLocation;
@property(copy) NSString* pictureLocation;
@property(copy) NSString* largePictureLocation;

@property(assign) NSImage* picture;
@property(retain,nonatomic) NSTimer* timer;
@property(retain) id<DMPlayableCapsuleDelegate> delegate;

@property(retain) QTMovie* movie;
@property(retain) NSString* skipType;

//}


+(id) playableCapsuleWithDictionary:(NSDictionary*)dic;
-(id) initWithDictionary:(NSDictionary*) dic;

-(BOOL) canLoad;
-(BOOL) createNewMovie;
-(void) invalidateMovie;

-(void) play;
-(void) pause;
-(void) replay;

-(void) commitVolume:(float) volume;

-(NSString*) startAttributeWithChannel:(NSString*)channel;

@end
