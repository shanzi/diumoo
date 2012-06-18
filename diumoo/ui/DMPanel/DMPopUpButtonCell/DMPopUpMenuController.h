//
//  DMPopUpMenuController.h
//  diumoo
//
//  Created by Shanzi on 12-6-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DMPopUpMenuController : NSObjectController
@property(retain) IBOutlet NSButton* mainButton;
@property(retain) IBOutlet NSButton* subButton;
@property(retain) IBOutlet NSMenu* mainMenu;
@property(retain) IBOutlet NSMenu* subMenu;

-(IBAction)popUpMenu:(id)sender;

@end
