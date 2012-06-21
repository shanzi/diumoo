//
//  DMPopUpMenuController.h
//  diumoo
//
//  Created by Shanzi on 12-6-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DMPopUpMenuController : NSObjectController


@property(retain) IBOutlet NSMenu* mainMenu;
@property(retain) IBOutlet NSMenu* publicMenu;
@property(retain) IBOutlet NSMenu* djMenu;
@property(retain) IBOutlet NSMenu* djExploreMenu;
@property(retain) IBOutlet NSMenu* djCollectMenu;

@property(retain) NSPopUpButtonCell* popupCell;

@property NSInteger currentChannelID;

-(IBAction)popUpMenu:(id)sender;
-(IBAction)menuItemAction:(id)sender;

@end
