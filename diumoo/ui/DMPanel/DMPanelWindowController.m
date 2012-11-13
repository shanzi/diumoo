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
#import "StatusItemView.h"
#import "DMPrefsPanelDataProvider.h"
#import "DMSearchPanelController.h"

DMPanelWindowController *sharedWindow;

@implementation DMPanelWindowController
@synthesize coreView,delegate,openURL;

+(DMPanelWindowController*)sharedWindowController
{
    if (sharedWindow == nil) {
        sharedWindow = [[DMPanelWindowController alloc] init];
    }
    return sharedWindow;
}

-(id) init
{
    if(self = [super initWithWindowNibName:@"DMPanelWindowController"]){
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(accountStateChanged:)
                                                     name:AccountStateChangedNotification
                                                   object:nil];
        
        menubarController = [[MenubarController alloc] init];
        [menubarController setAction:@selector(togglePanel:) withTarget:self];
        
        [self awakeFromNib];
        
        
        [loadingIndicator startAnimation:nil];
        
    }
    return self;
}

-(void)windowDidLoad {
    SInt32 minor;
    Gestalt(gestaltSystemVersionMinor,&minor);
    // Make the window visible on all Spaces
    if (minor >= 8)
        [[self window] setCollectionBehavior: NSWindowCollectionBehaviorCanJoinAllSpaces];
    else
        [[self window] setCollectionBehavior:NSWindowCollectionBehaviorMoveToActiveSpace];
}

-(void) awakeFromNib
{
    [super awakeFromNib];
    [self.window setLevel:NSPopUpMenuWindowLevel];
    [self.window setBackgroundColor:[NSColor whiteColor]];
    [self.window setOpaque:NO];
}

-(void) accountStateChanged:(NSNotification*)n
{
    DMDoubanAuthHelper* helper = [DMDoubanAuthHelper sharedHelper];
    [CATransaction begin];
    if (helper.username) {

        [userIconButton setImage:helper.icon];
        [usernameTextField setStringValue:helper.username];
        
        NSString* ratedCountString= [NSString stringWithFormat:@"♥ %ld",helper.likedSongsCount];
        [ratedCountTextField setStringValue:ratedCountString];
        
        [ratedCountTextField setHidden:NO];
        [usernameTextField setHidden:NO];
        
        [rateButton setEnabled:YES];
        [banButton setEnabled:[self.delegate canBanSong]];
        
        [popupMenuController setPrivateChannelEnabled:YES];
    }
    else {
        [userIconButton setImage:[NSImage imageNamed:NSImageNameUser]];
        [ratedCountTextField setStringValue:@""];
        [usernameTextField setStringValue:@""];
        [ratedCountTextField setHidden:YES];
        [usernameTextField setHidden:YES];
        
        [popupMenuController setPrivateChannelEnabled:NO];
        
        [rateButton setImage:[NSImage imageNamed:@"rate"]];
        [rateButton setEnabled:NO];
        [banButton setEnabled:NO];
    }
    [popupMenuController updateChannelList];
    [CATransaction commit];
}


-(void) channelChangeActionWithSender:(id)sender
{
    NSInteger tag = [sender tag];
    NSString* channel = [NSString stringWithFormat:@"%ld",tag];
    [CATransaction begin];
    if ([self.delegate channelChangedTo:channel]) {
        
        if (tag == 0 || tag == -3) {
            if ([DMDoubanAuthHelper sharedHelper].username) {
                [banButton setEnabled:YES];
            }
        }
        else {
            [banButton setEnabled:NO];
        }
        [popupMenuController updateChannelMenuWithSender:sender];
    }
    [CATransaction commit];
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
        case 5:
            [PLTabPreferenceControl showPrefsAtIndex:ACCOUNT_PANEL_ID];
            break;
        case 6:
            [self togglePanel:self];
            [[NSApplication sharedApplication] terminate:nil];
            break;
        case 7:
            [PLTabPreferenceControl showPrefsAtIndex:0];
            break;
        case 8:
            [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://diumoo.net/channels"]];
            break;
        case 9:
            [[DMSearchPanelController sharedSearchPanel] showWindow:nil];
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

-(void)shareAction:(id)sender
{
    [self.delegate share:(SNS_CODE)[sender tag]];
}

-(void)unlockUIWithError:(BOOL)has_err
{
    [loadingIndicator stopAnimation:nil];
    [loadingIndicator setHidden:YES];
    [popupMenuController unlockChannelMenuButton];
    
    if(has_err){
        [coverView setHidden:YES];
        [indicateString setStringValue:NSLocalizedString(@"NETWORK_ERROR_INDICADTE_STRING", @"发生网络错误，请尝试重启应用")];
    }
    else{
        [indicateString setHidden:YES];
    }
}

-(void) setRated:(BOOL)rated
{
    if ([rateButton isEnabled]) {
        if (rated){
            [menubarController setMixed:YES];
            [rateButton setImage:[NSImage imageNamed:@"rate_red"]];
        }
        else {
            [menubarController setMixed:NO];
            [rateButton setImage:[NSImage imageNamed:@"rate"]];
        }
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
        [playPauseButton setImage:[NSImage imageNamed:@"pause"]];
    }
    else {
        [playPauseButton setImage:[NSImage imageNamed:@"play"]];
    }
}

-(void) setPlayingCapsule:(DMPlayableCapsule *)capsule
{
    if (![loadingIndicator isHidden]) {
        [self unlockUIWithError:NO];
    }

    [capsule prepareCoverWithCallbackBlock:^(NSImage *image) {
            [coverView setAlbumImage:image];
    }];

    
    [coverView setPlayingInfo:capsule.title :capsule.artist :capsule.albumtitle];
}

-(void) showAlbumWindow:(id)sender
{
    [NSApp activateIgnoringOtherApps:YES];
    [[DMPlayRecordHandler sharedRecordHandler] open];
}

-(NSMenuItem*) prepareCurrentMenuItem
{
    if (popupMenuController.publicMenu == nil) {
        [popupMenuController updateChannelList];
    }
    
    NSMenuItem* currentItem=popupMenuController.currentChannelMenuItem;
    
    [CATransaction begin];
    if ([DMDoubanAuthHelper sharedHelper].username == nil) {
        [popupMenuController setPrivateChannelEnabled:NO];
        [rateButton setEnabled:NO];
        [banButton setEnabled:NO];
        if (currentItem && currentItem.tag <= 0) {
            [CATransaction commit];
            return [popupMenuController.publicMenu
                                                 itemWithTag:1];
            
        }
    }
    
    if(currentItem){
        [CATransaction commit];
        return currentItem;
    }
    else {
        [CATransaction commit];
        return [popupMenuController.publicMenu
                                itemWithTag:1];
    }
}

-(void) playDefaultChannel
{
    NSMenuItem* currentItem = [self prepareCurrentMenuItem];
    [self channelChangeActionWithSender:currentItem];
}

-(NSString*) switchToDefaultChannel
{
    NSMenuItem* item = [self prepareCurrentMenuItem];
    [popupMenuController updateChannelMenuWithSender:item];
    if ([item tag]==0 || [item tag] == -3) {
        [banButton setEnabled:YES];
    }
    else{
        [banButton setEnabled:NO];
    }
    return [NSString stringWithFormat:@"%ld",item.tag];
}

-(void)invokeChannelWithCid:(NSInteger)cid andTitle:(NSString *)title andPlay:(BOOL)immediately
{
    [popupMenuController invokeChannelWith:cid andTitle:title andPlay:immediately];
}

-(void) toggleSpecialWithDictionary:(NSDictionary *)info;
{
    if (info) {
        DMLog(@"play info : %@",info);
        NSString* title = info[@"title"];
        NSString* artist = info[@"artist"];
        NSString* type = info[@"typestring"];

        self.openURL = info[@"album_location"];
        
        [popupMenuController enterSpecialPlayingModeWithTitle:title
                                                       artist:artist
                                                andTypeString:type];
    }
    else {
        self.openURL = nil;
        [popupMenuController exitSepecialPlayingMode];
    }
}

// ------------------------------ 弹出窗口 ----------------------------

- (NSRect)statusRectForWindow:(NSWindow *)window
{
    NSRect statusRect = NSZeroRect;
    StatusItemView *statusItemView = nil;

    statusItemView = menubarController.statusItemView;

    statusRect = statusItemView.globalRect;
    statusRect.origin.y = NSMinY(statusRect) - NSHeight(statusRect);

    return statusRect;
}

- (BOOL)hasActivePanel
{
    return _hasActivePanel;
}

- (void)setHasActivePanel:(BOOL)flag
{
    if (_hasActivePanel != flag)
    {
        _hasActivePanel = flag;
        
        if (_hasActivePanel)
        {
            [self openPanel];
        }
        else
        {
            [self closePanel];
        }
    }
}

- (void)windowDidResignKey:(NSNotification *)notification;
{
    if ([[self window] isVisible])
    {
        [self windowWillClose:nil];
    }
}

- (void)windowWillClose:(NSNotification *)notification
{
    self.hasActivePanel = NO;
    menubarController.hasActiveIcon = NO;
}

-(void) openPanel
{
    NSWindow *panel = [self window];
    
    NSRect screenRect = [[panel screen] frame];
    NSRect statusRect = [self statusRectForWindow:panel];
    
    NSRect panelRect = [panel frame];
    CGFloat panelWidth = NSWidth(panelRect);
    CGFloat screenWidth = NSWidth(screenRect);
    CGFloat left = NSMinX(statusRect);
    CGFloat leftSafe = screenWidth - panelWidth;
    
    panelRect.origin.x = roundf(left<leftSafe?left:leftSafe);
    panelRect.origin.y = NSMaxY(statusRect) - NSHeight(panelRect);
    
    
    [NSApp activateIgnoringOtherApps:NO];
    [panel setFrame:panelRect display:YES];
    [panel makeKeyAndOrderFront:nil];
}

-(void) closePanel
{
    NSWindow *panel = [self window];
    [panel orderOut:self];
}

- (IBAction)togglePanel:(id)sender
{
    if (sender == nil && menubarController.hasActiveIcon) return;
    
    menubarController.hasActiveIcon = !menubarController.hasActiveIcon;
    self.hasActivePanel = menubarController.hasActiveIcon;
}

-(void) mouseScroll:(NSEvent *)event
{
    DMLog(@"scroll %@",event);
    float delta = [event deltaY]/100.0;
    float volume = [[[NSUserDefaults standardUserDefaults]
                     valueForKey:@"volume"]floatValue]+delta;
    [self.delegate volumeChange:volume];
}

@end
