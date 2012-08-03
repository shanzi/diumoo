//
//  DMQuickHelpPanelController.h
//  diumoo
//
//  Created by Shanzi on 12-7-31.
//
//

#import <Cocoa/Cocoa.h>

//----------------------------------
// Quick Start Version Is Here
// Update This Number Everytime
// Quick Start Images Has Updated
//----------------------------------

#define CURRENT_QUICKSTART_VERSION 1

//----------------------------------



@class DMQuickStartImageSlideView;

@interface DMQuickStartPanelController : NSWindowController
{
    IBOutlet DMQuickStartImageSlideView* slideView;
}

+(void) showPanel;

@end
