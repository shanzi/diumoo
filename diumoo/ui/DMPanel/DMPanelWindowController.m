//
//  DMPannelWindowController.m
//  diumoo
//
//  Created by Shanzi on 12-6-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DMPanelWindowController.h"

@interface DMPanelWindowController ()

@end

@implementation DMPanelWindowController
@synthesize view;

-(id) init
{
    self = [super initWithWindowNibName:@"DMPanelWindowController"];
    if(self){
        
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    [self.window setBackgroundColor:[NSColor whiteColor]];
}

@end
