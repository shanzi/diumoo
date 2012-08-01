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

#import "DMPlayableCapsule.h"

@implementation DMPlayableCapsule

@synthesize loadState,playState,volume;
@synthesize like,length,rating_avg;
@synthesize aid,sid,ssid,subtype,title,artist,albumtitle;
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
        
        loadState = -1;
        self.aid = [dic valueForKey:@"aid"]; 
        self.sid = [dic valueForKey:@"sid"];
        self.ssid = [dic valueForKey:@"ssid"];
        self.subtype = [dic valueForKey:@"subtype"];
        self.title = [dic valueForKey:@"title"];
        self.artist = [dic valueForKey:@"artist"];
        self.albumtitle = [dic valueForKey:@"albumtitle"];
        self.albumLocation = [NSString stringWithFormat:@"%@%@",DOUBAN_URL_PRIFIX,[dic valueForKey:@"album"]];
        self.musicLocation = [dic valueForKey:@"url"];
        self.pictureLocation = [dic valueForKey:@"picture"];
        self.largePictureLocation = [pictureLocation stringByReplacingOccurrencesOfString:@"mpic" withString:@"lpic"];
        
        self.like = [[dic valueForKey:@"like"] boolValue];
        self.length = [[dic valueForKey:@"length"] floatValue] * 1000;
        self.rating_avg = [[dic valueForKey:@"rating_avg"] floatValue];
        
        self.volume = [[[NSUserDefaults standardUserDefaults] valueForKey:@"volume"] floatValue];
        
    }
    return self;
}

-(BOOL) canLoad;
{
#ifdef DEBUG
    NSLog(@"%@",musicLocation);
#endif
    if(!movie){
        return [QTMovie canInitWithURL:[NSURL URLWithString:musicLocation]];
    }
    else {
        return loadState >0;
    }
}

-(BOOL) createNewMovie
{
    if(loadState >= QTMovieLoadStatePlaythroughOK) 
        return YES;
    
    self.playState = WAIT_TO_PLAY;
    
    NSError* err = nil;
    QTMovie* m = [QTMovie movieWithURL:[NSURL URLWithString:musicLocation] error:&err];
    
    if(!err)
    {
        [self invalidateMovie];
        self.movie = m;

        // 添加新的侦听
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(movieRateDidChanged:) 
                                                     name:QTMovieRateDidChangeNotification 
                                                   object:movie];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(movieLoadStateDidChanged:) 
                                                     name:QTMovieLoadStateDidChangeNotification
                                                   object:movie];
        return YES;
    }
    return NO;
}

-(void) invalidateMovie
{
    // 删除notification侦听
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.loadState = -1;
    self.playState = WAIT_TO_PLAY;
    [movie invalidate];
    self.movie = nil;
}

-(void) movieRateDidChanged:(NSNotification* )n
{
    
    if (movie.rate > 0) {
        [self.delegate playableCapsuleDidPlay:self];
    }
    else if (
        (movie.duration.timeValue - movie.currentTime.timeValue) < 100) {
        [self.delegate playableCapsuleDidEnd:self];
    }
    else {
        [self.delegate playableCapsuleDidPause:self];
    }
}

-(void) movieLoadStateDidChanged:(NSNotification*)n
{
    self.loadState = [[movie attributeForKey:QTMovieLoadStateAttribute] longValue];
    [self.delegate playableCapsule:self loadStateChanged:loadState];
}

-(void) play
{
    if(loadState < QTMovieLoadStatePlayable)
        return;
    if(playState == WAIT_TO_PLAY)
    {
        self.playState = PLAYING;
        [movie setVolume: self.volume];
    }
    else self.playState = REPLAYING;
    
    if(movie && movie.rate < 0.1){
        if(timer) [timer invalidate];
        if(movie.currentTime.timeValue < 100) [movie autoplay];
        
        self.timer = [NSTimer timerWithTimeInterval:TIMER_INTERVAL 
                                             target:self 
                                           selector:@selector(timerPulse:) 
                                           userInfo:kTimerPulseTypePlay 
                                            repeats:YES] ;
        
        CFRunLoopAddTimer(CFRunLoopGetMain(), (CFRunLoopTimerRef)timer, kCFRunLoopCommonModes);
        
        [movie autoplay];
        [timer fire];
    }
    else {
        [self.delegate playableCapsuleDidPlay:self];
    }
}

-(void) pause
{
    if(movie && movie.rate > 0.9){
        if(timer) [timer invalidate];
        if(movie.currentTime.timeValue < 100) [movie autoplay];
        
        self.timer = [NSTimer timerWithTimeInterval:TIMER_INTERVAL 
                                        target:self 
                                      selector:@selector(timerPulse:) 
                                      userInfo:kTimerPulseTypePause
                                       repeats:YES];
        
        CFRunLoopAddTimer(CFRunLoopGetMain(), (CFRunLoopTimerRef)timer, kCFRunLoopCommonModes);
        [delegate playableCapsuleWillPause:self];
        [timer fire];
    }
    else
        [delegate playableCapsuleDidPause:self];
}

-(void) replay
{
    [movie stop];
    [movie gotoBeginning];
    [self play];
}

-(void) invalidateTimer
{
    CFRunLoopRemoveTimer(CFRunLoopGetMain(),(CFRunLoopTimerRef) timer, kCFRunLoopCommonModes);
    [timer invalidate];
    self.timer = nil;
}

-(void) timerPulse:(NSTimer*)t
{
    float delta =  volume - movie.volume;
    if([timer userInfo] == kTimerPulseTypePlay)
    {
        if(delta < 0.08 && -delta < 0.08) 
        {
            [self invalidateTimer];
            movie.volume = volume;
        }
        else {
            movie.volume += delta>0?0.08:-0.08;
        }
    }
    else if([timer userInfo] == kTimerPulseTypePause)
    {
        if(movie.volume > 0.0 && movie.rate > 0) movie.volume -= 0.08;
        else {
            [self invalidateTimer];
            [movie stop];
        }
    }
    else {
        if (delta < 0.1 && -delta < 0.1) {
            [self invalidateTimer];
            movie.volume = volume;
        }
        else {
            movie.volume += delta>0?0.08:-0.08;
        }
    }
}

-(void) commitVolume:(float)v
{
    self.volume = v;

    id values = [[NSUserDefaultsController sharedUserDefaultsController] values];
    [values setValue:[NSNumber numberWithFloat:v] forKey:@"volume"];
    
    if(timer|| movie.rate < 0.1) return;
    else{
        self.timer = [NSTimer timerWithTimeInterval:TIMER_INTERVAL 
                                        target:self 
                                      selector:@selector(timerPulse:) 
                                      userInfo:KTimerPulseTypeVolumeChange 
                                       repeats:YES];
        
        CFRunLoopAddTimer(CFRunLoopGetMain(),(CFRunLoopTimerRef) timer, kCFRunLoopCommonModes);
        [timer fire];
    }
}

-(NSString*) startAttributeWithChannel:(NSString *)channel
{
    if(ssid==nil) return  nil;
    else return [NSString stringWithFormat:@"%@g%@g%@",sid,ssid,channel];
}

-(void) prepareCoverWithCallbackBlock:(void (^)(NSImage*))block
{

    if (self.picture == nil) {
        NSURL* url = [NSURL URLWithString:largePictureLocation];
        NSURLRequest* request = [NSURLRequest requestWithURL:url
                                                 cachePolicy:NSURLCacheStorageAllowed
                                             timeoutInterval:2.0];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *r, NSData *d, NSError *e) {
                                   picture = [[NSImage alloc] initWithData:d];
                                   if (picture) {
                                       if(block) block(picture);
                                   }
                                   else {
                                       picture = [NSImage imageNamed:@"albumfail"];
                                       if(block)block(picture);
                                   }
                                   
                               }];
    }
    else{
        if(block) block(picture);
    }
}

-(void)synchronousStop
{
    if(movie.rate < 0.1) return;
    if(timer){
        [self invalidateTimer];
    }
    
    while (movie.volume>0) {
        movie.volume -= 0.1;
        [NSThread sleepForTimeInterval:0.1];
    }
}

@end
