//
//  DMPlayableCapsule.m
//  diumoo-core
//
//  Created by Shanzi on 12-5-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#define kTimerPulseTypePlay @"kTimerPulseTypePlay"
#define kTimerPulseTypePause @"kTimerPulseTypePause"
#define KTimerPulseTypeVolumeChange @"kTimerPulseTypeVolumeChange"

#import <math.h>
#import "DMPlayableCapsule.h"

@interface DMPlayableCapsule()

-(double) getDuration;

@end

@implementation DMPlayableCapsule

@synthesize playState,currentTime;
@synthesize like,length,rating_avg;
@synthesize aid,sid,ssid,subtype,title,artist,albumtitle;
@synthesize albumLocation,musicLocation,pictureLocation,largePictureLocation;
@synthesize picture,music,delegate;

+(id)playableCapsuleWithDictionary:(NSDictionary *)dic
{
    return [[DMPlayableCapsule alloc] initWithDictionary:dic];
}

-(void)dealloc
{
    [self invalidateMovie];
}

-(id)initWithDictionary:(NSDictionary *)dic
{
    if (self = [super init]) {
        duration = 0.f;
        timer = [[NSTimer alloc] init];
        
        aid = [dic valueForKey:@"aid"]; 
        sid = [dic valueForKey:@"sid"];
        ssid = [dic valueForKey:@"ssid"];
        subtype = [dic valueForKey:@"subtype"];
        title = [dic valueForKey:@"title"];
        artist = [dic valueForKey:@"artist"];
        albumtitle = [dic valueForKey:@"albumtitle"];
        albumLocation = [NSString stringWithFormat:@"%@%@",DOUBAN_URL_PRIFIX,[dic valueForKey:@"album"]];
        musicLocation = [dic valueForKey:@"url"];
        pictureLocation = [dic valueForKey:@"picture"];
        largePictureLocation = [pictureLocation stringByReplacingOccurrencesOfString:@"mpic" withString:@"lpic"];
        
        like = [[dic valueForKey:@"like"] boolValue];
        length = [[dic valueForKey:@"length"] floatValue] * 1000;
        rating_avg = [[dic valueForKey:@"rating_avg"] floatValue];
        
        volume = [[[NSUserDefaults standardUserDefaults] valueForKey:@"volume"] floatValue];
    }
    return self;
}

-(void) createNewMovie
{
    if(music.status == AVPlayerStatusReadyToPlay)
        return;
    
    [self invalidateMovie];
    
    playState = WAIT_TO_PLAY;
    
    music = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:musicLocation]];
        
    [music addObserver:self forKeyPath:@"rate" options:0 context:nil];
    [music addObserver:self forKeyPath:@"currentItem.status" options:0 context:nil];
    
    music.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    
    return;
}

-(void) invalidateMovie
{
    playState = WAIT_TO_PLAY;
    [music pause];
    [music removeObserver:self forKeyPath:@"rate"];
    [music removeObserver:self forKeyPath:@"currentItem.status"];
    music = nil;
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"currentItem.status"]) {
        [self.delegate playableCapsule:self loadStateChanged:music.currentItem.status];
    }
    
    if ([keyPath isEqualToString:@"rate"]) {
        if (self.playState == PLAYING) {
            if (music.rate == 1.f) {
                [self.delegate playableCapsuleDidPlay:self];
            }
            else if (([self getDuration] >30) && ([self getDuration] - self.currentTime) < 1) {
                [self.delegate playableCapsuleDidEnd:self];
            }
            else {
                [self.delegate playableCapsuleDidPause:self];
            }
        }
    }
}

-(void) play
{
    if(music.status == AVPlayerStatusUnknown)
        return;
    
    if(playState == WAIT_TO_PLAY)
    {
        [music pause];
        playState = PLAYING;
        music.volume = volume;
    }
    else
        playState = REPLAYING;
    
    CFStringRef reasonForActivity= CFSTR("Diumoo playing");

    if(music.rate == 0.f){
        if(timer)
            [timer invalidate];

        
        timer = [NSTimer timerWithTimeInterval:TIMER_INTERVAL
                                        target:self
                                      selector:@selector(timerPulse:)
                                      userInfo:kTimerPulseTypePlay
                                       repeats:YES];
        CFRunLoopAddTimer(CFRunLoopGetMain(), (__bridge CFRunLoopTimerRef)timer, kCFRunLoopCommonModes);
        [music play];
        [timer fire];

        IOPMAssertionCreateWithName(kIOPMAssertionTypeNoIdleSleep,
                                    kIOPMAssertionLevelOn, reasonForActivity, &idleSleepAssertionID);
    }
    else {
        IOPMAssertionCreateWithName(kIOPMAssertionTypeNoDisplaySleep,
                                    kIOPMAssertionLevelOn, reasonForActivity, &idleSleepAssertionID);
        [self.delegate playableCapsuleDidPlay:self];
    }
    
}

-(void) pause
{
    if(music.rate == 1.f){
        if(timer)
            [timer invalidate];
        
        timer = [NSTimer timerWithTimeInterval:TIMER_INTERVAL 
                                        target:self 
                                      selector:@selector(timerPulse:) 
                                      userInfo:kTimerPulseTypePause
                                       repeats:YES];
        
        CFRunLoopAddTimer(CFRunLoopGetMain(), (__bridge CFRunLoopTimerRef)timer, kCFRunLoopCommonModes);
        [self.delegate playableCapsuleWillPause:self];
        [timer fire];
        
        IOPMAssertionRelease(idleSleepAssertionID);
        idleSleepAssertionID = 0;
    }
    else{
        [self.delegate playableCapsuleDidPause:self];
        IOPMAssertionRelease(idleSleepAssertionID);
        idleSleepAssertionID = 0;
    }
}

-(void) replay
{
    [music pause];
    self.currentTime = 0.f;
    [self play];
}

-(void) invalidateTimer
{
    CFRunLoopRemoveTimer(CFRunLoopGetMain(),(__bridge CFRunLoopTimerRef) timer, kCFRunLoopCommonModes);
    [timer invalidate];
    timer = nil;
}

-(void) timerPulse:(NSTimer*)t
{
    float delta =  volume - music.volume;

    if([[timer userInfo] isEqual: kTimerPulseTypePlay])
    {
        if(fabsf(delta) < 0.08)
        {
            [self invalidateTimer];
            music.volume = volume;
        }
        else {
            music.volume += delta>0?0.08:-0.08;
        }
    }
    else if([[timer userInfo] isEqual: kTimerPulseTypePause])
    {
        if(music.volume > 0.0 && music.rate > 0.f)
            music.volume -= 0.08;
        else {
            [self invalidateTimer];
            [music pause];
        }
    }
    else {
        if (fabsf(delta) < 0.1) {
            [self invalidateTimer];
            music.volume = volume;
        }
        else {
            music.volume += delta>0?0.08:-0.08;
        }
    }
}

-(void) commitVolume:(float)targetVolume
{
    volume = targetVolume;
    [[NSUserDefaults standardUserDefaults] setValue:@(targetVolume)
                                             forKey:@"volume"];
    
    if(music.rate == 0.f)
        return;
    else{
        if(timer) return;
        music.volume = volume;
        
    }
}

-(NSString*) startAttributeWithChannel:(NSString *)channel
{
    if(ssid==nil)
        return nil;
    else
        return [NSString stringWithFormat:@"%@g%@g%@",sid,ssid,channel];
}

-(void) prepareCoverWithCallbackBlock:(void (^)(NSImage*))block
{
    if (picture == nil && block) {
        NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:largePictureLocation]
                                                 cachePolicy:NSURLCacheStorageAllowed
                                             timeoutInterval:5.0];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *r, NSData *d, NSError *e) {
                                   picture = [[NSImage alloc] initWithData:d];
                                   if (picture) {
                                       block(picture);
                                   }
                                   else {
                                       picture = [NSImage imageNamed:@"albumfail"];
                                       block(picture);
                                   }
                               }];
    }
    else if (block)
        block(picture);
}

-(void)synchronousStop
{
    if(music.rate == 0.f)
       return;
    else {
        if(timer)
            [self invalidateTimer];
        
        while (music.volume>0) {
            self.music.volume -= 0.1;
            [NSThread sleepForTimeInterval:0.1];
        }
    }
}

- (double)getDuration
{
    return CMTimeGetSeconds(music.currentItem.asset.duration);
}

- (double)currentTime
{
	return CMTimeGetSeconds([[self music] currentTime]);
}

- (void)setCurrentTime:(double)time
{
	[[self music] seekToTime:CMTimeMakeWithSeconds(time, 1) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}


@end
