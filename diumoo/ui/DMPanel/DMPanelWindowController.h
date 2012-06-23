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
-(void)volumeChange:(id)sender;
-(BOOL)channelChangedTo:(NSString*)channel;

@end

@interface DMPanelWindowController : NSWindowController
{
    IBOutlet DMCoverControlView* coverView;
    IBOutlet DMPopUpMenuController* popupMenuController;
    
    IBOutlet NSButton* playPauseButton;
    IBOutlet NSButton* skipButton;
    IBOutlet NSButton* rateButton;
    IBOutlet NSButton* banButton;
}

@property(assign) IBOutlet DMCoverControlView* view;
@property(retain) IBOutlet id<DMPanelWindowDelegate> delegate;

-(void) channelChangeActionWithSender:(id)sender;
-(IBAction)controlAction:(id)sender;

-(void) setRated:(BOOL)rated;
-(void) setPlaying:(BOOL) playing;
-(void) setPlayingCapsule:(DMPlayableCapsule*) capsule;


@end
