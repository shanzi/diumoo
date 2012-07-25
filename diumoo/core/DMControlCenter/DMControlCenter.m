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
//@synthesize playingCapsule,songToPlay,fetcher,waitPlaylist,channel,pausedOperationType,skipLock,notificationCenter;
//@synthesize mainPanel,recordHandler;
//@synthesize specialWaitList;
@synthesize playingCapsule;

#pragma init & dealloc

-(id) init
{
    if (self = [super init]) {
        //init iVars
        channel = @"1";
        pausedOperationType = @"";
        playingCapsule = [[DMPlayableCapsule alloc] init];
        waitingCapsule = [[DMPlayableCapsule alloc] init];
        fetcher = [[DMPlaylistFetcher alloc] init];
        waitPlaylist = [[NSMutableOrderedSet alloc] init];
        
        skipLock = [[NSLock alloc] init];
        
        notificationCenter = [[DMNotificationCenter alloc] init];
        
        diumooPanel = [DMPanelWindowController sharedWindowController];
        recordHandler = [DMPlayRecordHandler sharedRecordHandler];
        
        specialWaitList = [[NSMutableArray alloc] init];
        
        //set delegate
        fetcher.delegate = self;
        diumooPanel.delegate = self;
        recordHandler.delegate = self;

        //add Observer
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(playSpecialNotification:)
                                                    name:@"playspecial"
                                                  object:nil];
    }
    return self;
}

-(void)dealloc
{
    channel=nil;
    [playingCapsule release];
    [waitingCapsule release];
    [fetcher release];
    [waitPlaylist release];
    [skipLock release];
    [notificationCenter release];
    [diumooPanel release];
    [recordHandler release];
    fetcher.delegate = nil;
    diumooPanel.delegate = nil;
    recordHandler.delegate = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [super dealloc];
}

#pragma -

-(void) fireToPlay:(NSDictionary*)firstSong
{
    [fetcher fetchPlaylistFromChannel:channel 
                             withType:kFetchPlaylistTypeNew 
                                  sid:nil 
                       startAttribute:[NSString stringWithFormat:@"%@g%@g%@",[firstSong objectForKey:@"sid"],[firstSong objectForKey:@"ssid"],channel]];
    [self startToPlay:nil];
}

-(void) fireToPlayDefaultChannel
{
    [self fireToPlay:nil];
    [diumooPanel performSelectorOnMainThread:@selector(playDefaultChannel)
                                  withObject:nil
                               waitUntilDone:NO];
}


-(void) stopForExit
{
<<<<<<< HEAD
    [skipLock tryLock];
    //[diumooPanel closePanel];
=======
    [skipLock lock];
>>>>>>> b2608129ddbae20e3e06de48a5cd5ac0aa23e386
    if (playingCapsule) {
        [playingCapsule synchronousStop];
    }
}

-(void) startToPlay:(DMPlayableCapsule*)aSong
{
    DMLog(@"start to play : %@",aSong);
    
    [playingCapsule invalidateMovie];
    
    if(aSong == nil){
        // start to play 的 song 为 nil， 则表明自动从缓冲列表或者播放列表里取出歌曲
        if ([specialWaitList count]>0)
        {
            playingCapsule = nil;
            [self fireToPlay:[specialWaitList objectAtIndex:0]];
            [specialWaitList removeObject:[specialWaitList objectAtIndex:0]];
            return;
        }
        else {
            [diumooPanel toggleSpecialWithDictionary:nil];
        }
        
        DMLog(@"waitPlayList count = %ld",[waitPlaylist count]);
        
        if ([waitPlaylist count]>0)
        {
            // 缓冲列表不是空的，从缓冲列表里取出一个来
            playingCapsule = nil;
            playingCapsule = [waitPlaylist objectAtIndex:0];
            playingCapsule.delegate = self;
            [waitPlaylist removeObjectAtIndex:0];

            
            // 再从播放列表里抓取一个歌曲出来放到缓冲列表里
            if((waitingCapsule = [fetcher getOnePlayableCapsule]))
            {
                waitingCapsule.delegate = self;
                if([waitingCapsule createNewMovie])
                    [waitPlaylist addObject:waitingCapsule];
            }
        }
        else{
            
            // 用户关闭了缓冲功能，或者缓冲列表为空，直接从播放列表里取歌曲
            if ((playingCapsule = [fetcher getOnePlayableCapsule]))
                playingCapsule.delegate = self;
            else
            {
                // 没有获取到capsule，说明歌曲列表已经为空，那么新获取一个播放列表

                [fetcher fetchPlaylistFromChannel:channel
                                         withType:kFetchPlaylistTypeNew
                                              sid:nil
                                   startAttribute:nil];
            }
        }
    }
    else {
        // 指定了要播放的歌曲
        //[aSong setDelegate:self];
        playingCapsule = aSong;
        playingCapsule.delegate = self;
        
        if(playingCapsule.loadState < 0 && ![playingCapsule createNewMovie]){
            // 歌曲加载失败，且重新加载也失败，尝试获取此歌曲的连接
            playingCapsule = nil;
            [fetcher fetchPlaylistFromChannel:channel 
                                     withType:kFetchPlaylistTypeNew 
                                          sid:nil 
                               startAttribute:[aSong startAttributeWithChannel:channel]];
        }
    }
    
    if(playingCapsule)
    {
        [playingCapsule play];
        [playingCapsule prepareCoverWithCallbackBlock:^(NSImage * image) {
            [diumooPanel setRated:playingCapsule.like];
            [diumooPanel setPlayingCapsule:playingCapsule];
            [notificationCenter notifyMusicWithCapsule:playingCapsule];
            [recordHandler addRecordAsyncWithCapsule:playingCapsule];
        }];
    }
        
        
}

//------------------PlayableCapsule 的 delegate 函数部分-----------------------

-(void) playableCapsuleDidPlay:(id)c
{
    [diumooPanel setPlaying:YES];
}

-(void) playableCapsuleWillPause:(id)c
{
    [diumooPanel setPlaying:NO];
}
-(void) playableCapsuleDidPause:(id)c
{
    [diumooPanel setPlaying:NO];

    if([pausedOperationType isEqualToString:kPauseOperationTypeSkip])
    {
        // 跳过当前歌曲
        if (waitingCapsule) {
            [self startToPlay:waitingCapsule];
            waitingCapsule = nil;
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

-(void) playableCapsuleDidEnd:(id)capsule
{
    [diumooPanel setPlaying:NO];
    
    if (capsule == playingCapsule) {
        if(playingCapsule.playState == PLAYING_AND_WILL_REPLAY)
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

-(void) playableCapsule:(id)capsule loadStateChanged:(long)state
{
    if (state > 20000) {
        if(capsule == playingCapsule && playingCapsule.playState == WAIT_TO_PLAY)
            [playingCapsule play];
        
        if(state >= QTMovieLoadStateComplete)
        {
            if ([capsule picture] == nil) {
                [capsule prepareCoverWithCallbackBlock:nil];
            }
        }
        
         
        // 特殊播放模式下不缓冲
        if ([specialWaitList count]>0) {
            return;
        }
        
        // 在这里执行一些缓冲歌曲的操作
        NSInteger MAX_WAIT_PLAYLIST_COUNT = [[[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"max_wait_playlist_count"] integerValue];

        
        if ([waitPlaylist count] < MAX_WAIT_PLAYLIST_COUNT)
        {
            DMPlayableCapsule *newWaitingCapsule = [fetcher getOnePlayableCapsule];
            
            if(newWaitingCapsule == nil){
                [fetcher fetchPlaylistFromChannel:channel
                                         withType:kFetchPlaylistTypePlaying
                                              sid:playingCapsule.sid
                                   startAttribute:nil];
            }
            else{
                newWaitingCapsule.delegate = self;
                if([newWaitingCapsule createNewMovie])
                    [waitPlaylist addObject:newWaitingCapsule];
            }
        }
    }
    else if(state < 0){
        if(capsule == playingCapsule)
        {
            // 当前歌曲加载失败
            // 做些事情
        }
        else {
            // 缓冲列表里的歌曲加载失败，直接跳过好了
            [waitPlaylist removeObject:capsule];
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
    DMLog(@"fetch success:playing = %@; startsong = %@",playingCapsule,startsong);
    
    if (startsong)
    {
        if (playingCapsule)
        {
            waitingCapsule = startsong;
            if ([skipLock tryLock])
            {
                pausedOperationType = kPauseOperationTypeSkip;
                [playingCapsule pause];
            }
        }
        else {
            [self startToPlay:startsong];
        }
    }
    else if (playingCapsule == nil) 
    {
        [self startToPlay:[fetcher getOnePlayableCapsule]];
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
    pausedOperationType = kPauseOperationTypeSkip;
    
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
        [diumooPanel countRated:-1];
        [diumooPanel setRated:NO];
    }
    else {
        
        
        [fetcher fetchPlaylistFromChannel:channel
                                 withType:kFetchPlaylistTypeRate
                                      sid:playingCapsule.sid
                           startAttribute:nil];
        
        [diumooPanel countRated:1];
        [diumooPanel setRated:YES];
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
    pausedOperationType = kPauseOperationTypeSkip;
    
    // 暂停当前歌曲
    [playingCapsule pause];
}

-(BOOL)channelChangedTo:(NSString *)ch
{
    if (channel == ch) {
        return YES;
    }
    
    if (![skipLock tryLock]) {
        return NO;
    };
    
    channel = ch;
    
    [waitPlaylist removeAllObjects];
    [fetcher clearPlaylist];
    
    if (playingCapsule) {

        pausedOperationType = kPauseOperationTypeFetchNewPlaylist;
        
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
    specialWaitList = nil;
    [diumooPanel toggleSpecialWithDictionary:nil];
    [self skip];
}

-(BOOL)canBanSong
{
    NSString* c = channel;
    @try {
        NSInteger channel_id = [c integerValue];
        if (channel_id == 0 || channel_id == -3) {
            return YES;
        }
        else {
            return NO;
        }
    }
    @catch (NSException *exception) {
        return NO;
    }
}

//--------------------------------------------------------------------


//-------------------------playrecord handler delegate ---------------
-(void) playSongWithSid:(NSString *)sid andSsid:(NSString *)ssid
{
    NSString* startattribute = [NSString stringWithFormat:@"%@g%@g%@",sid,ssid,channel];
    [fetcher fetchPlaylistFromChannel:channel
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
            specialWaitList = [array retain];
            [diumooPanel toggleSpecialWithDictionary:info];
            
            pausedOperationType = kPauseOperationTypePlaySpecial;
            [playingCapsule pause];
            
        }
        else {
            specialWaitList = nil;
            [skipLock unlock];
        }
    }];
}
//--------------------------------------------------------------------
@end
