//
//  DMPannelWindowController.m
//  diumoo
//
//  Created by Shanzi on 12-6-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DMPanelWindowController.h"
#import "DMDoubanAuthHelper.h"
#import "DMPlayRecordHandler.h"

DMPanelWindowController *sharedWindow;

@interface DMPanelWindowController ()

@end

@implementation DMPanelWindowController
@synthesize view,delegate,openURL;

+(DMPanelWindowController*)sharedWindowController
{
    if (sharedWindow == nil) {
        sharedWindow = [[DMPanelWindowController alloc] init];
    }
    return sharedWindow;
}

-(id) init
{
    self = [super initWithWindowNibName:@"DMPanelWindowController"];
    if(self){
        
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    [self.window setBackgroundColor:[NSColor whiteColor]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(accountStateChanged:)
                                                 name:AccountStateChangedNotification
                                               object:nil];
    
}

-(void) accountStateChanged:(NSNotification*)n
{
    DMDoubanAuthHelper* helper = [DMDoubanAuthHelper sharedHelper];
    if (helper.username) {
        [userIconButton setImage:[helper getUserIcon]];
        [usernameTextField setStringValue:helper.username];
        
        NSString* ratedCountString= [NSString stringWithFormat:@"♥ %ld",helper.likedSongsCount];
        [ratedCountTextField setStringValue:ratedCountString];
        
        [ratedCountTextField setHidden:NO];
        [usernameTextField setHidden:NO];
        
    }
    else {
        
        [userIconButton setImage:[NSImage imageNamed:NSImageNameUser]];
        [ratedCountTextField setStringValue:@""];
        [usernameTextField setStringValue:@""];
        [ratedCountTextField setHidden:YES];
        [usernameTextField setHidden:YES];
    }

    [popupMenuController updateChannelList];
}


-(void) channelChangeActionWithSender:(id)sender
{
    NSInteger tag = [sender tag];
    NSString* channel = [NSString stringWithFormat:@"%d",tag];
    if ([self.delegate channelChangedTo:channel]) {
        [popupMenuController updateChannelMenuWithSender:sender];
    }
}


-(void) controlAction:(id)sender
{
    NSInteger tag = [sender tag];
    switch (tag) {
        case 0:
            [self.delegate playOrPause];
            break;
        case 1:
            [self.delegate skip];
            break;
        case 2:
            [self.delegate rateOrUnrate];
            break;
        case 3:
            [self.delegate ban];
            break;
        case 4:
            [self.delegate volumeChange:[sender floatValue]];
            break;
    }
}

-(void) specialAction:(id)sender
{
    NSInteger tag = [sender tag];
    switch (tag) {
        case 0:
            // 退出special
            [self.delegate exitedSpecialMode];
            break;
        case -2:
            // 打开网页
        {
            NSURL* url = [NSURL URLWithString:self.openURL];
            [[NSWorkspace sharedWorkspace] openURL:url];
        }
        break;
    }
}

-(void) setRated:(BOOL)rated
{
    if (rated){
        [rateButton setImage:[NSImage imageNamed:@"rate_red.png"]];
    }
    else {
        [rateButton setImage:[NSImage imageNamed:@"rate.png"]];
    }     
}

-(void) countRated:(NSInteger)count
{
    DMDoubanAuthHelper* helper = [DMDoubanAuthHelper sharedHelper];
    if(helper.username){
        helper.likedSongsCount += count ;
        NSString* ratedCountString= [NSString stringWithFormat:@"♥ %ld",helper.likedSongsCount];
        [ratedCountTextField setStringValue:ratedCountString];
    }
}

-(void) setPlaying:(BOOL)playing
{
    if (playing) {
        [playPauseButton setImage:[NSImage imageNamed:@"pause.png"]];
    }
    else {
        [playPauseButton setImage:[NSImage imageNamed:@"play.png"]];
    }
}

-(void) setPlayingCapsule:(DMPlayableCapsule *)capsule
{

    [capsule prepareCoverWithCallbackBlock:^(NSImage *image) {
            [coverView setAlbumImage:image];
    }];

    
    [coverView setPlayingInfo:capsule.title :capsule.artist :capsule.albumtitle];
}

-(void) showAlbumWindow:(id)sender
{
    [[DMPlayRecordHandler sharedRecordHandler] open];
}

-(void) playDefaultChannel
{
    if (popupMenuController.publicMenu == nil) {
        [popupMenuController updateChannelList];
    }
    
    if(popupMenuController.currentChannelMenuItem)
    {
        [self channelChangeActionWithSender:popupMenuController.currentChannelMenuItem];
    }
    else {
        [self channelChangeActionWithSender:[popupMenuController.publicMenu 
                                             itemWithTag:1]];
    }
}

-(void) toggleSpecialWithDictionary:(NSDictionary *)info;
{
    
    if (info) {
        DMLog(@"play info : %@",info);
        NSString* title = [info objectForKey:@"title"];
        NSString* artist = [info objectForKey:@"artist"];
        NSString* type = [info objectForKey:@"typestring"];

        self.openURL = [DOUBAN_URL_PRIFIX stringByAppendingFormat:@"subject/%@/",[info objectForKey:@"aid"]];
        
        [popupMenuController enterSpecialPlayingModeWithTitle:title
                                                       artist:artist
                                                andTypeString:type];
    }
    else {
        self.openURL = nil;
        [popupMenuController exitSepecialPlayingMode];
    }
}



@end
