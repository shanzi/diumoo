//
//  DMPlayableCapsule.h
//  diumoo-core
//
//  Created by Shanzi on 12-5-31.
//  retainright (c) 2012年 __MyCompanyName__. All rights reserved.
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

@property long loadState;
@property CapsulePlayState playState;
@property(nonatomic) float volume;

@property BOOL like;
@property float length;
@property float rating_avg;

@property(nonatomic,copy) NSString* aid;
@property(nonatomic,copy) NSString* sid;
@property(nonatomic,copy) NSString* ssid;
@property(nonatomic,copy) NSString* subtype;
@property(nonatomic,copy) NSString* title;
@property(nonatomic,copy) NSString* artist;
@property(nonatomic,copy) NSString* albumtitle;
@property(nonatomic,copy) NSString* albumLocation;
@property(nonatomic,copy) NSString* musicLocation;
@property(nonatomic,copy) NSString* pictureLocation;
@property(nonatomic,copy) NSString* largePictureLocation;

@property(assign) NSImage* picture;
@property(retain,nonatomic) NSTimer* timer;
@property(retain) id<DMPlayableCapsuleDelegate> delegate;

@property(retain) QTMovie* movie;
@property(retain) NSString* skipType;

+(id) playableCapsuleWithDictionary:(NSDictionary*)dic;
-(id) initWithDictionary:(NSDictionary*) dic;

-(BOOL) canLoad;
-(BOOL) createNewMovie;
-(void) invalidateMovie;

-(void) play;
-(void) pause;
-(void) replay;

-(void) commitVolume:(float) volume;

-(void) prepareCoverWithCallbackBlock: (void (^)(NSImage*))block;

-(NSString*) startAttributeWithChannel:(NSString*)channel;
-(void)synchronousStop;
@end
