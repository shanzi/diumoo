//
//  DMPannelWindowController.h
//  diumoo
//
//  Created by Shanzi on 12-6-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DMButton.h"
#import "DMCoverControlView.h"
#import "diumoo-Swift.h"
#import "DMPopUpMenuController.h"
#import "MenubarController.h"
#import <Cocoa/Cocoa.h>

typedef enum {
    DOUBAN = 1,
    FANFOU = 2,
    SINA_WEIBO = 3,
    TWITTER = 4,
    FACEBOOK = 5,
    SYS_TWITTER = 6,
    SYS_FACEBOOK = 7,
    SYS_WEIBO = 8,
    COPY_LINK = 9

} SNS_CODE;

@protocol DMPanelWindowDelegate <NSObject>

- (void)playOrPause;
- (void)skip;
- (void)rateOrUnrate;
- (void)ban;
- (void)volumeChange:(float)volume;
- (BOOL)channelChangedTo:(NSString*)channel;
- (void)exitedSpecialMode;
- (void)share:(SNS_CODE)code;

@end

@interface DMPanelWindowController : NSWindowController {
    IBOutlet DMCoverControlView* coverView;
    IBOutlet DMPopUpMenuController* popupMenuController;

    IBOutlet DMButton* playPauseButton;
    IBOutlet DMButton* skipButton;
    IBOutlet DMButton* rateButton;
    IBOutlet DMButton* banButton;

    IBOutlet NSButton* userIconButton;
    IBOutlet NSTextField* usernameTextField;

    IBOutlet NSProgressIndicator* loadingIndicator;
    IBOutlet NSTextField* indicateString;

    BOOL _hasActivePanel;
    MenubarController* menubarController;
}

@property (nonatomic, strong) IBOutlet DMCoverControlView* coreView;

@property (copy) NSString* openURL;
@property (nonatomic) BOOL hasActivePanel;

@property (strong) IBOutlet id<DMPanelWindowDelegate> delegate;

+ (DMPanelWindowController*)sharedWindowController;

- (void)channelChangeActionWithSender:(id)sender;
- (IBAction)controlAction:(id)sender;
- (IBAction)showAlbumWindow:(id)sender;
- (IBAction)specialAction:(id)sender;
- (IBAction)shareAction:(id)sender;

- (void)unlockUIWithError:(BOOL)has_err;
- (void)setRated:(BOOL)rated;
- (void)setPlaying:(BOOL)playing;
- (void)setPlayingItem:(DMPlayableItem*)item;
- (void)playDefaultChannel;

- (NSString*)switchToDefaultChannel;
- (void)invokeChannelWithCid:(NSInteger)cid andTitle:(NSString*)title andPlay:(BOOL)immediately;

- (void)toggleSpecialWithDictionary:(NSDictionary*)info;
- (IBAction)togglePanel:(id)sender;
- (void)mouseScroll:(NSEvent*)event;

@end
