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
    
    IBOutlet NSMenuItem* djSaveItem;
    
    IBOutlet NSMenu * mainMenu;
    IBOutlet NSMenu * djMenu;
    IBOutlet NSMenu* exitSpecialMenu;
}

@property(retain) IBOutlet id delegate;

@property(retain) NSMenu* publicMenu;
@property(retain) NSMenu* djExploreMenu;
@property(retain) NSMenu* djCollectMenu;

@property NSInteger currentChannelID;
@property(retain) id currentChannelMenuItem;

@property BOOL specialMode;

-(IBAction)popUpMenu:(id)sender;

-(IBAction)saveDJChannelAction:(id)sender;
-(IBAction)changeChannelAction:(id)sender;
-(void) updateChannelMenuWithSender:(id)sender;
-(void) updateChannelList;

-(void) enterSpecialPlayingModeWithTitle:(NSString *)title artist:(NSString*)artist andTypeString:(NSString*) type;
-(void) exitSepecialPlayingMode;
-(void) setPrivateChannelEnabled:(BOOL) enable;

@end
