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
}

@property(retain) IBOutlet id delegate;

@property(retain) IBOutlet NSMenu* publicMenu;
@property(retain) IBOutlet NSMenu* djExploreMenu;
@property(retain) IBOutlet NSMenu* djCollectMenu;

@property NSInteger currentChannelID;
@property(retain) id currentChannelMenuItem;



-(IBAction)popUpMenu:(id)sender;

-(IBAction)saveDJChannelAction:(id)sender;
-(IBAction)changeChannelAction:(id)sender;
-(void) updateChannelMenuWithSender:(id)sender;

@end
