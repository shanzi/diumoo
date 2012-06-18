//
//  DMPopUpMenuController.m
//  diumoo
//
//  Created by Shanzi on 12-6-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DMPopUpMenuController.h"

@implementation DMPopUpMenuController
@synthesize mainButton,subButton,mainMenu,subMenu;

-(void) awakeFromNib
{
    [[mainButton cell] setMenu:mainMenu];
    [[mainButton cell] setPullsDown:YES];
    [[mainButton cell] setPreferredEdge:NSMaxYEdge];
}

-(void)popUpMenu:(id)sender
{
    [[sender cell] attachPopUpWithFrame:[sender bounds] inView:nil];
}

@end
