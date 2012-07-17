//
//  DMPannelWindowController.h
//  diumoo
//
//  Created by Shanzi on 12-6-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DMCoverControlView.h"
#import "DMPlayableCapsule.h"
#import "DMPopUpMenuController.h"

@protocol DMPanelWindowDelegate <NSObject>

-(void)playOrPause;
-(void)skip;
-(void)rateOrUnrate;
-(void)ban;
-(void)volumeChange:(float)volume;
-(BOOL)channelChangedTo:(NSString*)channel;
-(void)exitedSpecialMode;

@end

@interface DMPanelWindowController : NSWindowController
{
    IBOutlet DMCoverControlView* coverView;
    IBOutlet DMPopUpMenuController* popupMenuController;
    
    IBOutlet NSButton* playPauseButton;
    IBOutlet NSButton* skipButton;
    IBOutlet NSButton* rateButton;
    IBOutlet NSButton* banButton;
    
    IBOutlet NSButton* userIconButton;
    IBOutlet NSTextField* usernameTextField;
    IBOutlet NSTextField* ratedCountTextField;
}

@property(assign) IBOutlet DMCoverControlView* view;
@property(retain) IBOutlet id<DMPanelWindowDelegate> delegate;
@property(copy) NSString* openURL;

+(DMPanelWindowController*)sharedWindowController;

-(void) channelChangeActionWithSender:(id)sender;
-(IBAction)controlAction:(id)sender;
-(IBAction)showAlbumWindow:(id)sender;
-(IBAction)specialAction:(id)sender;

-(void) setRated:(BOOL)rated;
-(void) countRated:(NSInteger)count;
-(void) setPlaying:(BOOL) playing;
-(void) setPlayingCapsule:(DMPlayableCapsule*) capsule;
-(void) playDefaultChannel;
-(void) toggleSpecialWithDictionary:(NSDictionary *)info;

@end
