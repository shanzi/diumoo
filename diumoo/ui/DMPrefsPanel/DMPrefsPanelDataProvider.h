//
//  DMPrefsPanelDataProvider.h
//  diumoo
//
//  Created by Shanzi on 12-6-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLTabPreferenceControl.h"

#define PANEL_VIEW_COUNT 4
#define GENERAL_PANEL_ID 0
#define ACCOUNT_PANEL_ID 1
#define SPACE_PANEL_ID 2
#define INFO_PANEL_ID 3

@interface DMPrefsPanelDataProvider : NSObject <PLTabPreferenceDelegate>
{
    // tab controller ( file owner )
    IBOutlet PLTabPreferenceControl* tabcontroller;
    
    //-----------view outlet -----------
    IBOutlet NSView* general;
    IBOutlet NSView* login;
    IBOutlet NSView* account;
    IBOutlet NSView* info;
    //----------------------------------
    
    //------- login view outlet --------
    IBOutlet NSProgressIndicator* indicator;
    IBOutlet NSButton* captchaButton;
    IBOutlet NSButton* submitButton;
    IBOutlet NSButton* resetButton;
    IBOutlet NSTextField* email;
    IBOutlet NSSecureTextField* password;
    IBOutlet NSTextField* captcha;
    IBOutlet NSTextField* errorLabel;
    //----------------------------------
    
    //------ account view outlet -------
    IBOutlet NSButton* userIconButton;
    IBOutlet NSTextField* usernameTextField;
    IBOutlet NSSegmentedControl* playrecordButton;
    //----------------------------------
    
}

@property(copy) NSString* captcha_code;

-(IBAction)loginAction:(id)sender;
-(IBAction)logoutAction:(id)sender;
-(IBAction)showPlayRecord:(id)sender;

@end
