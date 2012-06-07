//
//  DMControlCenter.m
//  diumoo-core
//
//  Created by Shanzi on 12-6-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DMControlCenter.h"

@implementation DMControlCenter
@synthesize capsule,fetcher;

-(id) init
{
    self = [super init];
    if (self) {
        fetcher = [DMPlaylistFetcher new];
        fetcher.delegate = self;
    }
    return self;
}

//------------------PlayableCapsule 的 delegate 函数部分-----------------------

-(void) playableCapsuleDidPlay:(id)c
{
#ifdef DEBUG
    NSLog(@"capsule played: %@",c);
#endif

}

-(void) playableCapsuleWillPause:(id)c
{
#ifdef DEBUG
    NSLog(@"capsule will pause: %@",c);
#endif
}
-(void) playableCapsuleDidPause:(id)c
{
#ifdef DEBUG
    NSLog(@"capsule paused: %@",c);
#endif
}

-(void) playableCapsuleDidEnd:(id)c
{
#ifdef DEBUG
    NSLog(@"capsule ended: %@",c);
#endif
}

-(void) playableCapsule:(id)c loadStateChanged:(long)state
{
#ifdef DEBUG
    NSLog(@"capsule (%@) loadstate: %ld",c,state);
#endif
}

//------------------------------------------------------------------------


//----------------------------fetcher 的 delegate 部分 --------------------

-(void) fetchPlaylistError:(NSError *)err withComment:(NSString *)comment
{
#ifdef DEBUG
    NSLog(@"fetch error : %@ comment : %@",err,comment);
#endif
}

-(void) fetchPlaylistSuccessWithStartSong:(id)startsong
{
#ifdef DEBUG
    NSLog(@"fetch success with start song : %@",startsong);
    NSLog(@"playlist: %@",fetcher.playlist);
#endif
}

//------------------------------------------------------------------------


-(void) playAction:(id)sender
{
#ifdef DEBUG
    NSLog(@"%@",capsule.movie);
#endif
    [capsule play];
}

-(void) pauseAction:(id)sneder
{
    [capsule pause];
}

-(void) volumeChange:(id)sender
{
    [capsule commitVolume:[sender intValue]*0.01];
}

@end
