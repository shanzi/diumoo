//
//  DMPlayableCapsule.m
//  diumoo-core
//
//  Created by Shanzi on 12-5-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//


#import "DMPlayableCapsule.h"

#define kTimerPulseTypePlay @"kTimerPulseTypePlay"
#define kTimerPulseTypePause @"kTimerPulseTypePause"
#define KTimerPulseTypeVolumeChange @"kTimerPulseTypeVolumeChange"

@implementation DMPlayableCapsule

@synthesize loadState,volume;
@synthesize like,length,rating_avg;
@synthesize aid,sid,ssid,subtype,title,artist,albumWithYear;
@synthesize albumLocation,musicLocation,pictureLocation,largePictureLocation;
@synthesize picture,movie,timer,delegate,skipType;

+(id)playableCapsuleWithDictionary:(NSDictionary *)dic
{
    return [[[DMPlayableCapsule alloc] initWithDictionary:dic] autorelease];
}

-(void)dealloc
{
    [self invalidateMovie];
    
    [super dealloc];
}

-(id)initWithDictionary:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
#ifdef DEBUG
        NSLog(@"%@",dic);
#endif
        loadState = -1;
        aid = [dic valueForKey:@"aid"]; 
        sid = [dic valueForKey:@"sid"];
        ssid = [dic valueForKey:@"ssid"];
        subtype = [dic valueForKey:@"subtype"];
        title = [dic valueForKey:@"title"];
        artist = [dic valueForKey:@"artist"];
        id year = [dic valueForKey:@"year"];
        if(year) albumWithYear = [NSString stringWithFormat:@"%@ - %@",
                             [dic valueForKey:@"albumtitle"],
                             [dic valueForKey:@"public_time"]];
        else albumWithYear = [dic valueForKey:@"albumtitle"];
        albumLocation = [NSString stringWithFormat:@"%@%@",DOUBAN_URL_PRIFIX,[dic valueForKey:@"album"]];
        musicLocation = [dic valueForKey:@"url"];
        pictureLocation = [dic valueForKey:@"picture"];
        largePictureLocation = [pictureLocation stringByReplacingOccurrencesOfString:@"mpic" withString:@"lpic"];
        
        like = [[dic valueForKey:@"like"] boolValue];
        length = [[dic valueForKey:@"length"] floatValue] * 1000;
        rating_avg = [[dic valueForKey:@"rating_avg"] floatValue];
        
    }
    return self;
}

-(BOOL) canLoad;
{
#ifdef DEBUG
    NSLog(@"%@",musicLocation);
#endif
    if(!self.movie){
        NSURL* musicUrl = [NSURL URLWithString:musicLocation];
        return [QTMovie canInitWithURL:musicUrl];
    }
    else {
        return loadState >0;
    }
}

-(BOOL) createNewMovie
{
    if(loadState >= QTMovieLoadStatePlaythroughOK) return YES;
    
    NSURL*  musicUrl = [NSURL URLWithString:musicLocation];
    NSError* err = NULL;
    QTMovie* m = [QTMovie movieWithURL:musicUrl error:&err];
    
    if(!err)
    {
        [self invalidateMovie];
        self.movie = m;
        
        // 添加新的侦听
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(movieRateDidChanged:) 
                                                     name:QTMovieRateDidChangeNotification 
                                                   object:self.movie];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(movieLoadStateDidChanged:) 
                                                     name:QTMovieLoadStateDidChangeNotification
                                                   object:self.movie];
        
        return YES;
    }
    return NO;
}

-(void) invalidateMovie
{
    // 删除notification侦听
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    loadState = -1;
    [self.movie invalidate];
    self.movie = nil;
}

-(void) movieRateDidChanged:(NSNotification* )n
{
#ifdef DEBUG
    NSLog(@"%@",n);
#endif
    
    if (self.movie.rate > 0) {
        [self.delegate playableCapsuleDidPlay:self];
    }
    else if (
        (self.movie.duration.timeValue - self.movie.currentTime.timeValue) < 1000) {
        [self.delegate playableCapsuleDidEnd:self];
    }
    else {
        [self.delegate playableCapsuleDidPause:self];
    }
}

-(void) movieLoadStateDidChanged:(NSNotification*)n
{
#ifdef DEBUG
    NSLog(@"%@",n);
#endif
    loadState = [[movie attributeForKey:QTMovieLoadStateAttribute] longValue];
    [self.delegate playableCapsule:self loadStateChanged:loadState];
}

-(void) play
{
    if(loadState < QTMovieLoadStatePlayable) return;
    
    if(movie && movie.rate < 0.1){
        if(timer) [timer invalidate];
        if(movie.currentTime.timeValue < 100) [movie autoplay];
        
        timer = [NSTimer timerWithTimeInterval:TIMER_INTERVAL 
                                             target:self 
                                           selector:@selector(timerPulse:) 
                                           userInfo:kTimerPulseTypePlay 
                                            repeats:YES] ;
        
        CFRunLoopAddTimer(CFRunLoopGetMain(), (CFRunLoopTimerRef)timer, kCFRunLoopCommonModes);
        
        [movie play];
        [timer fire];
    }
}

-(void) pause
{
    if(movie && movie.rate > 0.9){
        if(timer) [timer invalidate];
        if(movie.currentTime.timeValue < 100) [movie autoplay];
        
        timer = [NSTimer timerWithTimeInterval:TIMER_INTERVAL 
                                        target:self 
                                      selector:@selector(timerPulse:) 
                                      userInfo:kTimerPulseTypePause
                                       repeats:YES];
        
        CFRunLoopAddTimer(CFRunLoopGetMain(), (CFRunLoopTimerRef)timer, kCFRunLoopCommonModes);
        [delegate playableCapsuleWillPause:self];
        [timer fire];
    }
}

-(void) invalidateTimer
{
    CFRunLoopRemoveTimer(CFRunLoopGetMain(),(CFRunLoopTimerRef) timer, kCFRunLoopCommonModes);
    [timer invalidate];
    timer = nil;
}

-(void) timerPulse:(NSTimer*)t
{
    float delta =  self.volume - movie.volume;
#ifdef DEBUG
    NSLog(@"timer delta: %f",delta);
#endif
    if([timer userInfo] == kTimerPulseTypePlay)
    {
        if(delta < 0.1 && -delta < 0.1) 
        {
            [self invalidateTimer];
            movie.volume = self.volume;
        }
        else {
            movie.volume += delta>0?0.1:-0.1;
        }
    }
    else if([timer userInfo] == kTimerPulseTypePause)
    {
        if(movie.volume > 0.0 && movie.rate > 0) movie.volume -= 0.1;
        else {
            [self invalidateTimer];
            [movie stop];
        }
    }
    else {
        if (delta < 0.1 && -delta < 0.1) {
            [self invalidateTimer];
        }
        else {
            movie.volume += delta>0?0.1:-0.1;
        }
    }
}

-(void) commitVolume:(float)v
{
#ifdef DEBUG
    NSLog(@"%f",v);
#endif
    self.volume = v;
    if(self.timer|| movie.rate < 0.1) return;
    else{
        timer = [NSTimer timerWithTimeInterval:TIMER_INTERVAL 
                                        target:self 
                                      selector:@selector(timerPulse:) 
                                      userInfo:KTimerPulseTypeVolumeChange 
                                       repeats:YES];
        CFRunLoopAddTimer(CFRunLoopGetMain(),(CFRunLoopTimerRef) timer, kCFRunLoopCommonModes);
        [timer fire];
    }
}


@end
