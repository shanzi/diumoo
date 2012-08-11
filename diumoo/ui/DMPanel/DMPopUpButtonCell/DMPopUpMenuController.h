//
//  DMPopUpMenuController.h
//  diumoo
//
//  Created by Shanzi on 12-6-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DMPopUpMenuController : NSObjectController
{
    IBOutlet NSButton* mainButton;
    IBOutlet NSButton* longMainButton;
    IBOutlet NSButton* subButton;
    
    IBOutlet NSMenu * mainMenu;
    IBOutlet NSMenu * moreChannelMenu;
    IBOutlet NSMenu* exitSpecialMenu;
    
    IBOutlet NSMenu* shareMenu;
}

@property(strong) IBOutlet id delegate;

@property(strong) NSMenu* publicMenu;
@property(strong) NSMenu* suggestMenu;

@property NSInteger currentChannelID;
@property(strong) id currentChannelMenuItem;

@property BOOL specialMode;

-(IBAction)popUpMenu:(id)sender;
-(IBAction)changeChannelAction:(id)sender;
-(void) updateChannelMenuWithSender:(id)sender;
-(void) updateChannelList;

-(void) enterSpecialPlayingModeWithTitle:(NSString *)title artist:(NSString*)artist andTypeString:(NSString*) type;
-(void) exitSepecialPlayingMode;
-(void) setPrivateChannelEnabled:(BOOL) enable;
-(void) unlockChannelMenuButton;

@end
