//
//  DMControlCenter.m
//  diumoo-core
//
//  Created by Shanzi on 12-6-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DMControlCenter.h"

@interface DMControlCenter() 
//私有函数的
-(void) startToPlay:(DMPlayableCapsule*)aSong;

@end


@implementation DMControlCenter
@synthesize playingCapsule,songToPlay,fetcher,waitPlaylist,channel,pausedOperationType,skipLock;
@synthesize mainPanel,recordHandler;
@synthesize specialWaitList;

#pragma init & dealloc

-(id) init
{
    self = [super init];
    if (self) {
        fetcher = [DMPlaylistFetcher new];
        fetcher.delegate = self;
        waitPlaylist = [NSMutableOrderedSet new];
        skipLock = [NSLock new];
        channel = @"1";
        
        self.mainPanel = [DMPanelWindowController sharedWindowController];
        [mainPanel setDelegate:self];
        [mainPanel togglePanel:nil];

        self.recordHandler = [DMPlayRecordHandler sharedRecordHandler];
        [recordHandler setDelegate:self];
        

        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(playSpecialNotification:)
                                                    name:@"playspecial"
                                                  object:nil];
    }
    return self;
}

-(void)dealloc
{
    [pausedOperationType release];
    [channel release];
    [waitPlaylist release];
    [fetcher release];
    [playingCapsule release];
    [mainPanel close];
    [mainPanel release];
    [recordHandler release];
    [super dealloc];
}

#pragma -

-(void) fireToPlay:(NSDictionary*)firstSong
{
    id sid = [firstSong objectForKey:@"sid"];
    id ssid = [firstSong objectForKey:@"ssid"];
    NSString* startattribute =
    [NSString stringWithFormat:@"%@g%@g%@",sid,ssid,channel];
    [fetcher fetchPlaylistFromChannel:channel 
                             withType:kFetchPlaylistTypeNew 
                                  sid:nil 
                       startAttribute:startattribute];
}

-(void) fireToPlayDefaultChannel
{
    [mainPanel playDefaultChannel];
}

-(void) startToPlay:(DMPlayableCapsule*)aSong
{
    DMLog(@"start to play : %@",aSong);
    
    [self.playingCapsule invalidateMovie];
    
    if(aSong == nil){
        // start to play 的 song 为 nil， 则表明自动从缓冲列表或者播放列表里取出歌曲

        if ([specialWaitList count]) {
            self.playingCapsule = nil;
            NSDictionary* song = [specialWaitList objectAtIndex:0];
            [self fireToPlay:song];
            [specialWaitList removeObject:song];
            return;
        }
        else {
            [mainPanel toggleSpecialWithDictionary:nil];
        }
        
        
        if ([waitPlaylist count]>0) {
            // 缓冲列表不是空的，从缓冲列表里取出一个来
            self.playingCapsule = [waitPlaylist objectAtIndex:0];
            [playingCapsule setDelegate:self];
            [waitPlaylist removeObject:playingCapsule];

            
            // 再从播放列表里抓取一个歌曲出来放到缓冲列表里
            id waitcapsule = [fetcher getOnePlayableCapsule];
            if(waitcapsule){
                [waitcapsule setDelegate:self];
                if([waitcapsule createNewMovie])
                    [waitPlaylist addObject:waitcapsule];
            }
        }
        else{
            
            // 用户关闭了缓冲功能，或者缓冲列表为空，直接从播放列表里取歌曲
            self.playingCapsule = [fetcher getOnePlayableCapsule];
            [playingCapsule setDelegate:self];
            
            
            // 没有获取到capsule，说明歌曲列表已经为空，那么新获取一个播放列表
            if(playingCapsule == nil)
                [fetcher fetchPlaylistFromChannel:channel 
                                               withType:kFetchPlaylistTypeNew 
                                                    sid:nil 
                                         startAttribute:nil];
        }
    }
    else {
        // 指定了要播放的歌曲
        [aSong setDelegate:self];
        self.playingCapsule = aSong;
        
        if(playingCapsule.loadState < 0 && ![playingCapsule createNewMovie]){
            // 歌曲加载失败，且重新加载也失败，尝试获取此歌曲的连接
            self.playingCapsule = nil;
            [fetcher fetchPlaylistFromChannel:channel 
                                     withType:kFetchPlaylistTypeNew 
                                          sid:nil 
                               startAttribute:[aSong startAttributeWithChannel:channel]];
        }
    }
    
    if(playingCapsule)
    {
        [playingCapsule play];
        [mainPanel setRated:playingCapsule.like];
        [mainPanel setPlayingCapsule:playingCapsule];
        [recordHandler addRecordAsyncWithCapsule:playingCapsule];
    }
        
        
}

//------------------PlayableCapsule 的 delegate 函数部分-----------------------

-(void) playableCapsuleDidPlay:(id)c
{
    [mainPanel setPlaying:YES];
}

-(void) playableCapsuleWillPause:(id)c
{
    [mainPanel setPlaying:NO];
}
-(void) playableCapsuleDidPause:(id)c
{
    [mainPanel setPlaying:NO];

    if([pausedOperationType isEqualToString:kPauseOperationTypeSkip])
    {
        // 跳过当前歌曲
        if (self.songToPlay) {
            [self startToPlay:self.songToPlay];
            self.songToPlay = nil;
        }
        else {
            [self startToPlay:nil];
        }

    }
    else if([pausedOperationType isEqualToString:kPauseOperationTypeFetchNewPlaylist])
    {
        // channel 改变了，获取新的列表
        [self startToPlay:nil];

    }
    else if([pausedOperationType isEqualTo:kPauseOperationTypePlaySpecial])
    {
        // 把当前歌曲加入到 wait list 里
        if (playingCapsule) {
            [waitPlaylist insertObject:playingCapsule atIndex:0];
            playingCapsule = nil;
        }
        
        // 开始获取新歌曲
        [self startToPlay:nil];
        
    }

    pausedOperationType = kPauseOperationTypePass;
    [skipLock unlock];
}

-(void) playableCapsuleDidEnd:(id)c
{
    [mainPanel setPlaying:NO];
    
    if (c == playingCapsule) {
        if( playingCapsule.playState == PLAYING_AND_WILL_REPLAY)
            [playingCapsule replay];
        else {
            
            // 将当前歌曲标记为已经播放完毕
            [fetcher fetchPlaylistFromChannel:channel
                                          withType:kFetchPlaylistTypeEnd
                                               sid:playingCapsule.sid
                                    startAttribute:nil];
            
            // 自动播放新的歌曲
            [self startToPlay:nil];
        }
    }
    // 歌曲播放结束时，无论如何都要解除lock

    [skipLock unlock];
}

-(void) playableCapsule:(id)c loadStateChanged:(long)state
{
    
    if (state > QTMovieLoadStatePlayable) {
        if (c == playingCapsule && 
            playingCapsule.playState == WAIT_TO_PLAY)
            [playingCapsule play];
        
        if(state >= QTMovieLoadStateComplete)
            
            if ([c picture] == nil) {
                [c prepareCoverWithCallbackBlock:nil];
            }
        
        
         
        // 特殊播放模式下不缓冲
        if (self.specialWaitList) {
            return;
        }
        
        // 在这里执行一些缓冲歌曲的操作
        id values = [[NSUserDefaultsController sharedUserDefaultsController] values];
        NSInteger MAX_WAIT_PLAYLIST_COUNT = [[values valueForKey:@"max_wait_playlist_count"] integerValue];
        
        
        if ([waitPlaylist count] < MAX_WAIT_PLAYLIST_COUNT) {
            DMPlayableCapsule* waitsong = [fetcher getOnePlayableCapsule];
            if(waitsong==nil){
                
                [fetcher fetchPlaylistFromChannel:channel
                                         withType:kFetchPlaylistTypePlaying
                                              sid:playingCapsule.sid
                                   startAttribute:nil];
                
            }
            else{
                [waitsong setDelegate:self];
                if([waitsong createNewMovie])
                    [waitPlaylist addObject:waitsong];
            }
            
        }
    }
    else if(state < 0){
        if(c == playingCapsule)
        {
            // 当前歌曲加载失败
            // 做些事情
        }
        else {
            // 缓冲列表里的歌曲加载失败，直接跳过好了
            [waitPlaylist removeObject:c];
        }
    }
}



//----------------------------fetcher 的 delegate 部分 --------------------

-(void) fetchPlaylistError:(NSError *)err withComment:(NSString *)comment
{

    DMLog(@"fetch error: %@",err);
}



-(void) fetchPlaylistSuccessWithStartSong:(id)startsong
{
    DMLog(@"fetch success:%@ %@",playingCapsule,startsong);
    
    if (startsong) {
        if (playingCapsule) {
            self.songToPlay = startsong;
            if ([skipLock tryLock]) {
                self.pausedOperationType = kPauseOperationTypeSkip;
                [self.playingCapsule pause];
            }
        }
        else {
            [self startToPlay:startsong];
        }
    }
    else if (playingCapsule == nil) 
    {
        DMPlayableCapsule* c = [fetcher getOnePlayableCapsule];
        [self startToPlay:c];
    }

}

//-------------------------------------------------------------------------



// ----------------------------- UI 的 delegate 部分 -----------------------

-(void) playOrPause
{
    
    if (playingCapsule.movie.rate > 0) 
    {
        if (![skipLock tryLock]) return;
        [playingCapsule pause];
    }
    else {
        [playingCapsule play];
    }
}

-(void) skip
{
    if (![skipLock tryLock]) return;
    
    // ping 豆瓣，将skip操作记录下来
    [fetcher fetchPlaylistFromChannel:channel 
                             withType:kFetchPlaylistTypeSkip
                                  sid:playingCapsule.sid
                       startAttribute:nil];
    
    // 指定歌曲暂停后的operation
    self.pausedOperationType = kPauseOperationTypeSkip;
    
    // 暂停当前歌曲
    [playingCapsule pause];
}

-(void)rateOrUnrate
{
    if(self.playingCapsule == nil) return;
    
    if (playingCapsule.like) {
        // 歌曲已经被加红心了，于是取消红心
        [fetcher fetchPlaylistFromChannel:channel
                                 withType:kFetchPlaylistTypeUnrate
                                      sid:playingCapsule.sid
                           startAttribute:nil];
        [mainPanel countRated:-1];
        [mainPanel setRated:NO];
    }
    else {
        
        
        [fetcher fetchPlaylistFromChannel:channel
                                 withType:kFetchPlaylistTypeRate
                                      sid:playingCapsule.sid
                           startAttribute:nil];
        
        [mainPanel countRated:1];
        [mainPanel setRated:YES];
    }
    // 在这里做些什么事情来更新 UI
    
    playingCapsule.like = (playingCapsule.like == NO);
    
}



-(void) ban
{
    if (![skipLock tryLock]) return;
    
    [fetcher fetchPlaylistFromChannel:channel
                             withType:kFetchPlaylistTypeBye
                                  sid:playingCapsule.sid
                       startAttribute:nil];
    
    // 指定歌曲暂停后的operation
    self.pausedOperationType = kPauseOperationTypeSkip;
    
    // 暂停当前歌曲
    [playingCapsule pause];
}

-(BOOL)channelChangedTo:(NSString *)ch
{
    if (self.channel == ch) {
        return YES;
    }
    
    if (![skipLock tryLock]) {
        return NO;
    };
    
    self.channel = ch;
    
    [waitPlaylist removeAllObjects];
    [fetcher clearPlaylist];
    
    if (playingCapsule) {

        self.pausedOperationType = kPauseOperationTypeFetchNewPlaylist;
        
        [playingCapsule pause];
    }
    else {
        [self startToPlay:nil];
        [skipLock unlock];
    }
    
    return YES;
}

-(void) volumeChange:(float)volume
{
    [playingCapsule commitVolume:volume];
}

-(void)exitedSpecialMode
{
    self.specialWaitList = nil;
    [mainPanel toggleSpecialWithDictionary:nil];
    [self skip];
}

//--------------------------------------------------------------------


//-------------------------playrecord handler delegate ---------------
-(void) playSongWithSid:(NSString *)sid andSsid:(NSString *)ssid
{
    NSString* startattribute = [NSString stringWithFormat:@"%@g%@g%@",sid,ssid,self.channel];
    [fetcher fetchPlaylistFromChannel:self.channel
                             withType:kFetchPlaylistTypeNew 
                                  sid:nil 
                       startAttribute:startattribute];
}
//--------------------------------------------------------------------

// ---------------------play special collection ----------------------
-(void) playSpecialNotification:(NSNotification*) n
{
    DMLog(@"receive notification: %@",n.userInfo);
    NSString* aid = [n.userInfo objectForKey:@"aid"];
    NSString* type = [n.userInfo objectForKey:@"type"];
    if ([type isEqualToString:@"album"]) {
        [self playAlbumWithAid:aid withInfo:n.userInfo];
    }
}

-(void) playAlbumWithAid:(NSString*) aid withInfo:(NSDictionary*) info;
{
    DMLog(@"play album : %@",aid);
    BOOL locked = [skipLock tryLock];
    if(!locked) return;
    
    [fetcher dmGetAlbumSongsWithAid:aid andCompletionBlock:^(NSArray *list) {

        if([list count]){
            NSMutableArray* array = nil;
            array = [NSMutableArray arrayWithArray:list];
            self.specialWaitList = [array retain];
            [mainPanel toggleSpecialWithDictionary:info];
            
            self.pausedOperationType = kPauseOperationTypePlaySpecial;
            [playingCapsule pause];
            
        }
        else {
            self.specialWaitList = nil;
            [skipLock unlock];
        }
    }];
}
//--------------------------------------------------------------------
@end
