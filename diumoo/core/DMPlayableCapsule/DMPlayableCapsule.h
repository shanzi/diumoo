//
//  DMPlayableCapsule.h
//  diumoo-core
//
//  Created by Shanzi on 12-5-31.
//  retainright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#define DOUBAN_URL_PRIFIX @"http://music.douban.com"
#define TIMER_INTERVAL 0.1

//  Playable State

#import <Foundation/Foundation.h>
#import <QTKit/QTKit.h>

#import <IOKit/pwr_mgt/IOPMLib.h>

#import "DMPlayableCapsuleDelegate.h"

typedef enum{
    WAIT_TO_PLAY = 0,
    PLAYING,
    PLAYING_AND_WILL_REPLAY,
    REPLAYING,
    REPLAYED
}CapsulePlayState;

@interface DMPlayableCapsule : NSObject
{
    NSString *aid;
    NSString *sid;
    NSString *ssid;
    NSString *subtype;
    NSString *title;
    NSString *artist;
    NSString *albumtitle;
    NSString *pictureLocation;
    NSString *skipType;
    NSTimer *timer;
    NSImage *picture;
    float volume;
    
    IOPMAssertionID idleSleepAssertionID;
}

@property long loadState;
@property CapsulePlayState playState;

@property BOOL like;
@property float length;
@property float rating_avg;

@property(nonatomic,copy,readonly) NSString* aid;
@property(nonatomic,copy,readonly) NSString* sid;
@property(nonatomic,copy,readonly) NSString* ssid;
@property(nonatomic,copy,readonly) NSString* subtype;
@property(nonatomic,copy,readonly) NSString* title;
@property(nonatomic,copy,readonly) NSString* artist;
@property(nonatomic,copy,readonly) NSString* albumtitle;
@property(nonatomic,copy,readonly) NSString* albumLocation;
@property(nonatomic,copy,readonly) NSString* musicLocation;
@property(nonatomic,copy,readonly) NSString* pictureLocation;
@property(nonatomic,copy,readonly) NSString* largePictureLocation;

@property NSImage *picture;

@property id<DMPlayableCapsuleDelegate> delegate;

@property QTMovie* movie;

+(id) playableCapsuleWithDictionary:(NSDictionary*)dic;
-(id) initWithDictionary:(NSDictionary*) dic;

-(BOOL) createNewMovie;
-(void) invalidateMovie;

-(void) play;
-(void) pause;
-(void) replay;

-(void) commitVolume:(float)targetVolume;

-(void) prepareCoverWithCallbackBlock: (void (^)(NSImage*))block;

-(NSString*) startAttributeWithChannel:(NSString*)channel;
-(void)synchronousStop;
@end
