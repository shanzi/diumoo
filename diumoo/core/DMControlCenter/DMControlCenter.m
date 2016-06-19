//
//  DMControlCenter.m
//  diumoo-core
//
//  Created by Shanzi on 12-6-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DMApp.h"
#import "DMControlCenter.h"

@interface DMControlCenter () {
    PAUSE_OPERATION_TYPE pauseType;
    AVPlayer* musicPlayer;
    NSTimer* timer;
    float playerVolume;
    IOPMAssertionID idleSleepAssertionID;
}
//私有函数的
- (void)startToPlay:(DMPlayableItem*)aSong;

//playerFunctions
- (float)currentTime;
- (void)setCurrentTime:(double)time;
- (void)play;
- (void)pause;
- (void)replay;
- (void)invalidateTimer;

@end

@implementation DMControlCenter
@synthesize playingItem, waitingItem, diumooPanel;

#pragma init& dealloc
- (id)init
{
    if (self = [super init]) {

        timer = [[NSTimer alloc] init];

        canPlaySpecial = NO;
        fetcher = [[DMPlaylistFetcher alloc] init];
        notificationCenter = [[DMNotificationCenter alloc] init];

        diumooPanel = [DMPanelWindowController sharedWindowController];
        recordHandler = [DMPlayRecordHandler sharedRecordHandler];

        fetcher.delegate = self;
        diumooPanel.delegate = self;
        recordHandler.delegate = self;

        channel = @"1";
        pauseType = PAUSE_PASS;

        playerVolume = [[NSUserDefaults standardUserDefaults] floatForKey:@"volume"];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playSpecialNotification:)
                                                     name:@"playspecial"
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma -

- (void)fireToPlay:(NSDictionary*)firstSong
{
    NSString* startattribute = [NSString stringWithFormat:@"%@g%@g%@", firstSong[@"sid"], firstSong[@"ssid"], channel];

    [fetcher fetchPlaylistFromChannel:channel Type:DMPlaylistFetcher.kFetchPlaylistTypeNew sid:nil startAttribute:startattribute];
}

- (void)fireToPlayDefault
{
    NSString* openedURLString = [NSApp performSelector:@selector(openedURLString)];
    if (openedURLString == nil) {
        [diumooPanel playDefaultChannel];
    }
    else {
        channel = [diumooPanel switchToDefaultChannel];
        canPlaySpecial = YES;
        [DMService openDiumooLink:openedURLString];
    }
}

- (void)stopForExit
{
    pauseType = PAUSE_EXIT;
    if (musicPlayer || musicPlayer.rate > 0.f) {
        if (timer != nil) {
            [self invalidateTimer];
        }
        while (musicPlayer.volume > 0) {
            musicPlayer.volume -= 0.1;
            [NSThread sleepForTimeInterval:0.1];
        }
    }
    [musicPlayer removeObserver:self forKeyPath:@"rate"];
    [notificationCenter clearNotifications];
}

- (void)startToPlay:(DMPlayableItem*)aSong
{
    if (pauseType == PAUSE_EXIT)
        return;

    [DMErrorLog logStateWith:self fromMethod:_cmd andString:[NSString stringWithFormat:@"start to play %@", aSong.musicInfo[@"title"]]];

    if (aSong == nil) {
        // start to play 的 song 为 nil， 则表明自动从缓冲列表或者播放列表里取出歌曲

        playingItem = [fetcher getOnePlayableItem];

        // 没有获取到Item，说明歌曲列表已经为空，那么新获取一个播放列表
        if (playingItem == nil) {
            [fetcher fetchPlaylistFromChannel:channel
                                         Type:DMPlaylistFetcher.kFetchPlaylistTypeNew
                                          sid:nil
                               startAttribute:nil];
        }
        else {
            playingItem.delegate = self;
        }
    }
    else {
        // 指定了要播放的歌曲
        aSong.delegate = self;
        playingItem = aSong;
    }

    if (playingItem) {
        [musicPlayer replaceCurrentItemWithPlayerItem:playingItem];

        [self play];
        [playingItem prepareCoverWithCallbackBlock:^(NSImage* image) {
            [diumooPanel setRated:playingItem.like];
            [diumooPanel setPlayingItem:playingItem];
            [notificationCenter notifyMusicPlaybackWithItem:playingItem];
            [recordHandler addRecordWithItem:playingItem];
        }];
    }
    pauseType = PAUSE_PASS;
}

//------------------PlayableCapsule 的 delegate 函数部分-----------------------

- (void)playableItemDidPlay:(id)item
{
    [diumooPanel setPlaying:YES];
    pauseType = PAUSE_PASS;
}

- (void)playableItemWillPause:(id)item
{
    [diumooPanel setPlaying:NO];
}
- (void)playableItemDidPause:(id)item
{
    [diumooPanel setPlaying:NO];
    if (timer != nil) {
        [timer invalidate];
    }

    if (pauseType == PAUSE_SKIP) {
        // 跳过当前歌曲
        if (waitingItem != nil) {
            [self startToPlay:waitingItem];
            waitingItem = nil;
        }
        else {
            [self startToPlay:nil];
        }
    }
    else if (pauseType == PAUSE_NEW_PLAYLIST) {
        // channel 改变了，获取新的列表
        [self startToPlay:nil];
    }
    else if (pauseType == PAUSE_SPECIAL) {
        // 把当前歌曲加入到 wait list 里

        playingItem = nil;

        // 开始获取新歌曲
        [self startToPlay:nil];
    }
    else if (pauseType == PAUSE_PAUSE) {
        DMLog(@"User Paused");
    }

    pauseType = PAUSE_PASS;
}

- (void)playableItemDidEnd:(id)item
{
    [diumooPanel setPlaying:NO];

    if (timer != nil) {
        [timer invalidate];
    }

    if (item == playingItem) {
        if (playingItem.playState == ItemPlayStatePlaying_and_will_replay)
            [self replay];
        else {

            // 将当前歌曲标记为已经播放完毕
            [fetcher fetchPlaylistFromChannel:channel
                                         Type:DMPlaylistFetcher.kFetchPlaylistTypeEnd
                                          sid:playingItem.musicInfo[@"sid"]
                               startAttribute:nil];

            // 自动播放新的歌曲
            playingItem = nil;
            [self startToPlay:nil];
        }
    }
    // 歌曲播放结束时，无论如何都要解除lock
    pauseType = PAUSE_PASS;
}

- (void)playableItem:(DMPlayableItem* _Nonnull)item logStateChanged:(NSInteger)state
{
    [DMErrorLog logStateWith:item.musicInfo[@"title"] fromMethod:_cmd andString:[NSString stringWithFormat:@"load status changed to %ld", state]];
    if (state == AVPlayerItemStatusReadyToPlay) {
        if (item.cover == nil) {
            [item prepareCoverWithCallbackBlock:^(NSImage* image) {
                item.cover = image;
            }];
        }
        if (item == playingItem && (item.playState != ItemPlayStatePlaying)) {
            [musicPlayer play];
        }
    }
    else if (state == AVPlayerItemStatusFailed) {

        // 当前歌曲加载失败
        [fetcher clearPlaylist];

        [self startToPlay:waitingItem];
    }
}

//----------------------------fetcher 的 delegate 部分 --------------------

- (void)fetchPlaylistWithDictionary:(NSDictionary<NSString*, id>*)dict startAttribute:(NSString*)attribute errorThreshould:(NSInteger)errCount
{
    if (playingItem == nil) {
        if (errCount < 5) {
            [fetcher fetchPlaylistWithDictionary:dict
                                  startAttribute:attribute
                                        errCount:errCount];
        }
        else {
            [diumooPanel unlockUIWithError:YES];
        }
    }
}

- (void)fetchPlaylistSucessWithStartSong:(DMPlayableItem*)startSong
{

    if (startSong) {
        if (playingItem) {
            if (OSAtomicCompareAndSwap32(PAUSE_PASS, PAUSE_SKIP, (int32_t*)&pauseType)) {
                waitingItem = startSong;
                [self pause];
            }
        }
        else {
            [self startToPlay:startSong];
        }
    }
    else if (playingItem == nil) {
        DMPlayableItem* item = [fetcher getOnePlayableItem];
        [self startToPlay:item];
    }
    canPlaySpecial = YES;
}

//-------------------------------------------------------------------------

// ----------------------------- UI 的 delegate 部分 -----------------------

- (void)playOrPause
{
    if (musicPlayer.rate > 0.f) {
        if (pauseType)
            return;
        pauseType = PAUSE_PAUSE;
        [self pause];
    }
    else {
        [self play];
    }
}

- (void)skip
{
    if (!OSAtomicCompareAndSwap32(PAUSE_PASS, PAUSE_SKIP, (int32_t*)&pauseType))
        return;

    // ping 豆瓣，将skip操作记录下来
    [fetcher fetchPlaylistFromChannel:channel
                                 Type:DMPlaylistFetcher.kFetchPlaylistTypeSkip
                                  sid:playingItem.musicInfo[@"sid"]
                       startAttribute:nil];

    // 暂停当前歌曲
    [self pause];
}

- (void)rateOrUnrate
{
    if (musicPlayer.currentItem == nil)
        return;

    if (playingItem.like) {
        // 歌曲已经被加红心了，于是取消红心
        [fetcher fetchPlaylistFromChannel:channel
                                     Type:DMPlaylistFetcher.kFetchPlaylistTypeUnrate
                                      sid:playingItem.musicInfo[@"sid"]
                           startAttribute:nil];
        [diumooPanel setRated:NO];
    }
    else {

        [fetcher fetchPlaylistFromChannel:channel
                                     Type:DMPlaylistFetcher.kFetchPlaylistTypeRate
                                      sid:playingItem.musicInfo[@"sid"]
                           startAttribute:nil];

        [diumooPanel setRated:YES];
    }
    // 在这里做些什么事情来更新 UI

    playingItem.like = (playingItem.like == NO);
}

- (void)ban
{
    if (!OSAtomicCompareAndSwap32(PAUSE_PASS, PAUSE_SKIP, (int32_t*)&pauseType))
        return;

    [fetcher fetchPlaylistFromChannel:channel
                                 Type:DMPlaylistFetcher.kFetchPlaylistTypeBye
                                  sid:playingItem.musicInfo[@"sid"]
                       startAttribute:nil];

    // 暂停当前歌曲
    [self pause];
}

- (BOOL)channelChangedTo:(NSString*)ch
{
    if (channel == ch) {
        return YES;
    }

    if (!OSAtomicCompareAndSwap32(PAUSE_PASS, PAUSE_NEW_PLAYLIST, (int32_t*)&pauseType))
        return NO;
    channel = ch;

    [fetcher clearPlaylist];

    if (musicPlayer.rate != 0.f) {
        [self pause];
    }
    else {
        pauseType = PAUSE_PASS;
        [self startToPlay:nil];
    }

    return YES;
}

- (void)volumeChange:(float)volume
{
    volume = (volume > 1.0 ? 1.0 : volume);
    volume = (volume < 0.0 ? 0.0 : volume);
    [[NSUserDefaults standardUserDefaults] setValue:@(volume) forKey:@"volume"];
    if (musicPlayer.rate == 0.f || timer) {
        return;
    }
    else {
        musicPlayer.volume = volume;
        playerVolume = volume;
    }
}

- (void)exitedSpecialMode
{

    [diumooPanel toggleSpecialWithDictionary:nil];
    [self skip];
}

- (void)share:(SNS_CODE)code
{
    if (playingItem == nil || playingItem.musicInfo[@"sid"] == nil) {
        return;
    }
    NSDictionary* sharedict = @{
        @"t" : playingItem.musicInfo[@"title"],
        @"a" : playingItem.musicInfo[@"albumtitle"],
        @"r" : playingItem.musicInfo[@"artist"],
        @"s" : [NSString stringWithFormat:@"%lx", [playingItem.musicInfo[@"sid"] integerValue]],
        @"ss" : playingItem.musicInfo[@"ssid"],
        @"i" : playingItem.musicInfo[@"largePictureLocation"],
        @"im" : playingItem.cover,
        @"al" : playingItem.musicInfo[@"albumLocation"]
    };

    [DMService shareLinkWithDictionary:sharedict
                              callback:^(NSString* url) {
                                  if (url == nil) {
                                      if (code == COPY_LINK)
                                          return;
                                      url = sharedict[@"al"];
                                  }

                                  [self share:code
                                      shareItem:url
                                      sharedict:sharedict];
                              }];
}

- (void)share:(SNS_CODE)code shareItem:(NSString*)shareLink sharedict:(NSDictionary*)dict
{

    NSString* shareTitle = dict[@"t"];
    NSString* shareString = [NSString stringWithFormat:@"%@ - %@ <%@>  ",
                                      shareTitle, dict[@"r"], dict[@"a"]];

    NSString* imageLink = dict[@"i"];

    NSDictionary* args = nil;
    NSString* urlBase = nil;
    NSArray* shareItem = nil;
    NSString* shareService = nil;

    switch (code) {
    case DOUBAN:
        urlBase = @"http://shuo.douban.com/!service/share";
        args = @{ @"name" : shareString,
            @"href" : shareLink,
            @"image" : imageLink };
        break;
    case FANFOU:
        urlBase = @"http://fanfou.com/sharer";
        args = @{ @"d" : shareString,
            @"t" : shareTitle,
            @"u" : shareLink };
        break;
    case SINA_WEIBO:
        urlBase = @"http://v.t.sina.com.cn/share/share.php";
        args = @{ @"title" : [NSString stringWithFormat:@"%@ ( %@ )",
                                       [NSString stringWithFormat:@"#nowplaying# #diumoo# %@ - %@ <%@>",
                                                            shareTitle, dict[@"r"], dict[@"a"]],
                                       shareLink] };
        break;

    case RENREN:
        urlBase = @"http://widget.renren.com/dialog/share";
        args = @{
            @"title" : shareTitle,
            @"srcUrl" : shareLink,
            @"resourceUrl" : shareLink,
            @"pic" : imageLink,
            @"description" : shareString
        };
        break;

    case TWITTER:
        if (YES) {
            NSString* content = [NSString stringWithFormat:@"%@ ( %@ )", shareString, shareLink];
            NSPasteboard* pb = [NSPasteboard pasteboardWithUniqueName];
            [pb setData:[content dataUsingEncoding:NSUTF8StringEncoding]
                forType:NSStringPboardType];
            if (NSPerformService(@"Tweet", pb))
                return;
            else {
                urlBase = @"http://twitter.com/home";
                args = @{ @"status" : content };
            }
        }
        break;
    case FACEBOOK:
        urlBase = @"http://www.facebook.com/sharer.php";
        args = @{ @"t" : shareString,
            @"u" : shareLink };
        break;
    case SYS_TWITTER:
        shareService = NSSharingServiceNamePostOnTwitter;
        shareItem = @[ [shareString stringByAppendingString:shareLink], dict[@"im"] ];
        break;
    case SYS_FACEBOOK:
        shareService = NSSharingServiceNamePostOnFacebook;
        shareItem = @[ [shareString stringByAppendingString:shareLink], dict[@"im"] ];
        break;
    case SYS_WEIBO:
        shareService = NSSharingServiceNamePostOnSinaWeibo;
        shareItem = @[
            [NSString stringWithFormat:@"%@ ( %@  )",
                      [NSString stringWithFormat:@"#nowplaying# #diumoo# %@ - %@ <%@>",
                                           shareTitle, dict[@"r"], dict[@"a"]],
                      shareLink],
            dict[@"im"]
        ];
        break;
    case COPY_LINK:
        [[NSPasteboard generalPasteboard] clearContents];
        [[NSPasteboard generalPasteboard] writeObjects:@[ shareLink ]];
        [notificationCenter copylinkNotificationWithURLStr:shareLink];
        return;
    }
    if (shareItem && shareService) {
        NSSharingService* service = [NSSharingService sharingServiceNamed:shareService];
        [service performWithItems:shareItem];
    }
    else {
        NSString* urlstring = [urlBase stringByAppendingFormat:@"?%@", [args urlEncodedString]];
        NSURL* url = [NSURL URLWithString:urlstring];
        [[NSWorkspace sharedWorkspace] openURL:url];
    }
}

//--------------------------------------------------------------------

//-------------------------playrecord handler delegate ---------------
- (void)playSongWithSid:(NSString*)sid andSsid:(NSString*)ssid
{

    NSString* startattribute = [NSString stringWithFormat:@"%@g%@g%@", sid, ssid, channel];
    [fetcher fetchPlaylistFromChannel:channel
                                 Type:DMPlaylistFetcher.kFetchPlaylistTypeNew
                                  sid:nil
                       startAttribute:startattribute];
}
//--------------------------------------------------------------------

// ---------------------play special collection ----------------------
- (void)playSpecialNotification:(NSNotification*)n
{
    if (!canPlaySpecial)
        return;

    NSString* type = (n.userInfo)[@"type"];
    if ([type isEqualToString:@"song"]) {
        NSString* start = (n.userInfo)[@"start"];

        [fetcher fetchPlaylistFromChannel:channel
                                     Type:DMPlaylistFetcher.kFetchPlaylistTypeNew
                                      sid:nil
                           startAttribute:[start stringByAppendingString:channel]];
    }
    else if ([type isEqualToString:@"album"]) {
        NSString* aid = (n.userInfo)[@"aid"];
        [fetcher fetchSongsWithAlbum:aid callback:^(BOOL success) {
            if (success) {
                waitingItem = nil;
                [self skip];
            }
            else {
                NSAlert* myAlert = [[NSAlert alloc] init];
                [myAlert setMessageText:NSLocalizedString(@"PLAY_ALBUM_FAILED", "play album failed")];
                [myAlert setInformativeText:NSLocalizedString(@"PLAY_ALBUM_FAILED_DETAIL", "play album fail detail")];
                [myAlert addButtonWithTitle:@"OK"];
                [myAlert runModal];

                [diumooPanel playDefaultChannel];
            }
        }];
    }
    else if ([type isEqualToString:@"musician"]) {
        NSString* musician_id = n.userInfo[@"musician_id"];
        [fetcher fetchSongsWithMusician:musician_id
                               callback:^(BOOL success) {
                                   if (success) {
                                       waitingItem = nil;
                                       [self skip];
                                       [diumooPanel invokeChannelWithCid:0
                                                                andTitle:NSLocalizedString(@"PRIVATE_MHZ", nil)
                                                                 andPlay:NO];
                                   }
                               }];
    }
    else if ([type isEqualToString:@"soundtrack"]) {
        NSString* soundtrack = n.userInfo[@"soundtrack_id"];
        [fetcher fetchSongsWithSoundtrackID:soundtrack
                                   callback:^(BOOL success) {
                                       if (success) {
                                           waitingItem = nil;
                                           [self skip];
                                           [diumooPanel invokeChannelWithCid:10
                                                                    andTitle:NSLocalizedString(@"SOUNDTRACK_MHZ", nil)
                                                                     andPlay:NO];
                                       }
                                   }];
    }
    else if ([type isEqualToString:@"channel"]) {
        NSInteger cid = [n.userInfo[@"cid"] integerValue];
        NSString* title = n.userInfo[@"title"];
        [diumooPanel invokeChannelWithCid:cid andTitle:title andPlay:YES];
    }
}
//--------------------------------------------------------------------

- (void)qualityChanged
{
    if (playingItem) {
        if (!OSAtomicCompareAndSwap32(PAUSE_PASS, PAUSE_NEW_PLAYLIST, (int32_t*)&pauseType))
            return;

        [fetcher clearPlaylist];
        [self pause];
        [notificationCenter notifyBitrate];
    }
}

#pragma Player_controller
- (void)play
{
    if (musicPlayer == nil) {
        musicPlayer = [[AVPlayer alloc] initWithPlayerItem:playingItem];
        [musicPlayer addObserver:self forKeyPath:@"rate" options:0 context:nil];
        musicPlayer.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    }

    if (musicPlayer.currentItem.status == AVPlayerItemStatusFailed) {
        return;
    }

    if (playingItem.playState == ItemPlayStateWaitToPlay) {
        NSLog(@"player volume : %f", playerVolume);
        playingItem.playState = ItemPlayStatePlaying;
        musicPlayer.volume = playerVolume;
    }
    else
        playingItem.playState = ItemPlayStateReplaying;

    CFStringRef reasonForActivity = CFSTR("Diumoo playing");
    if (musicPlayer.rate == 0.f) {
        if (timer) {
            [timer invalidate];
        }
        timer = [NSTimer timerWithTimeInterval:TIMER_INTERVAL
                                        target:self
                                      selector:@selector(timerPulse:)
                                      userInfo:kTimerPulseTypePlay
                                       repeats:YES];
        CFRunLoopAddTimer(CFRunLoopGetMain(), (__bridge CFRunLoopTimerRef)timer, kCFRunLoopCommonModes);
        [musicPlayer play];
        [timer fire];
        IOPMAssertionCreateWithName(kIOPMAssertionTypeNoIdleSleep,
            kIOPMAssertionLevelOn, reasonForActivity, &idleSleepAssertionID);
    }
    [self playableItemDidPlay:playingItem];
}

- (void)pause
{
    if (musicPlayer.rate != 0.f) {
        if (timer)
            [timer invalidate];

        timer = [NSTimer timerWithTimeInterval:TIMER_INTERVAL
                                        target:self
                                      selector:@selector(timerPulse:)
                                      userInfo:kTimerPulseTypePause
                                       repeats:YES];

        CFRunLoopAddTimer(CFRunLoopGetMain(), (__bridge CFRunLoopTimerRef)timer, kCFRunLoopCommonModes);
        [self playableItemWillPause:playingItem];
        [timer fire];

        IOPMAssertionRelease(idleSleepAssertionID);
        idleSleepAssertionID = 0;
    }
    else {
        [self playableItemDidPause:playingItem];
        IOPMAssertionRelease(idleSleepAssertionID);
        idleSleepAssertionID = 0;
    }
}

- (void)replay
{
    [musicPlayer pause];
    [self setCurrentTime:0.f];
    [musicPlayer play];
}

- (void)invalidateTimer
{
    CFRunLoopRemoveTimer(CFRunLoopGetMain(), (__bridge CFRunLoopTimerRef)timer, kCFRunLoopCommonModes);
    [timer invalidate];
    timer = nil;
}

- (void)timerPulse:(NSTimer*)aTimer
{
    float delta = playerVolume - musicPlayer.volume;

    if ([[aTimer userInfo] isEqual:kTimerPulseTypePlay]) {
        if (fabsf(delta) < 0.08) {
            [self invalidateTimer];
            musicPlayer.volume = playerVolume;
        }
        else {
            musicPlayer.volume += delta > 0 ? 0.08 : -0.08;
        }
    }
    else if ([[aTimer userInfo] isEqual:kTimerPulseTypePause]) {
        if (musicPlayer.volume > 0.0 && musicPlayer.rate > 0)
            musicPlayer.volume -= 0.08;
        else {
            [self invalidateTimer];
            [musicPlayer pause];
        }
    }
    else {
        if (fabsf(delta) < 0.1) {
            [self invalidateTimer];
            musicPlayer.volume = playerVolume;
        }
        else {
            musicPlayer.volume += delta > 0 ? 0.08 : -0.08;
        }
    }
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
    if ([keyPath isEqualToString:@"rate"]) {
        if (musicPlayer.rate == 1.f) {
            [self playableItemDidPlay:musicPlayer.currentItem];
        }
        else if ((playingItem.floatDuration > 5) && (playingItem.floatDuration - [self currentTime]) < 1) {
            [self playableItemDidEnd:musicPlayer.currentItem];
        }
        else {
            [self playableItemDidPause:musicPlayer.currentItem];
        }
    }
}

- (float)currentTime
{
    return CMTimeGetSeconds([musicPlayer currentTime]);
}

- (void)setCurrentTime:(double)time
{
    [musicPlayer seekToTime:CMTimeMakeWithSeconds(time, 1) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

@end
