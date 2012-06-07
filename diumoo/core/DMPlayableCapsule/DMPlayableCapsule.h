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


@interface DMPlayableCapsule : NSObject
// {
@property long loadState;
@property(nonatomic) float volume;

@property BOOL like;
@property float length;
@property float rating_avg;


@property(retain) NSString* aid;
@property(retain) NSString* sid;
@property(retain) NSString* ssid;
@property(retain) NSString* subtype;
@property(retain) NSString* title;
@property(retain) NSString* artist;
@property(retain) NSString* albumWithYear;
@property(retain) NSString* albumLocation;
@property(retain) NSString* musicLocation;
@property(retain) NSString* pictureLocation;
@property(retain) NSString* largePictureLocation;

@property(assign) NSImage* picture;
@property(retain,nonatomic) NSTimer* timer;
@property(retain) id<DMPlayableCapsuleDelegate> delegate;

@property(retain) QTMovie* movie;
@property(retain) NSString* skipType;

// }

+(id) playableCapsuleWithDictionary:(NSDictionary*)dic;
-(id) initWithDictionary:(NSDictionary*) dic;

-(BOOL) canLoad;
-(BOOL) createNewMovie;
-(void) invalidateMovie;

-(void) play;
-(void) pause;
-(void) commitVolume:(float) volume;

@end
