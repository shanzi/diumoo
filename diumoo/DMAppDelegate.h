//
//  DMAppDelegate.h
//  diumoo
//
//  Created by Shanzi on 12-6-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPMediaKeyTap.h"
#import "DMControlCenter.h"
#import "DMDoubanAuthHelper.h"
#import "DMPanelWindowController.h"
#import "DMPrefsPanelDataProvider.h"

@interface DMAppDelegate : NSObject<NSApplicationDelegate>
{
    IBOutlet DMControlCenter* center;
    DMPrefsPanelDataProvider *pref;
}
//@property(assign) DMPanelWindowController* panel;

-(IBAction)showPreference:(id)sender;

@end
