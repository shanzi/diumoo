//
//  DMPrefsPanelDataProvider.m
//  diumoo
//
//  Created by Shanzi on 12-6-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DMPrefsPanelDataProvider.h"
#import "DMDoubanAuthHelper.h"
#import "MASShortcutView+UserDefaults.h"
#import "NSImage+AsyncLoadImage.h"



@implementation DMPrefsPanelDataProvider
@synthesize captcha_code;


- (void)showPreferences
{
    tabcontroller = [[PLTabPreferenceControl alloc] initWithWindowNibName:@"DMPrefsPanel"];
    [tabcontroller showWindow:nil];
}

- (void)dealloc
{
    [tabcontroller release];
    [super dealloc];
}

- (int)countOfPreferencePanels
{
    return  PANEL_VIEW_COUNT;
}

- (NSString*)titleForPreferencePanelAt:(NSInteger)index
{
    switch (index) {
        case GENERAL_PANEL_ID:
            return @"通用";
            break;
        case ACCOUNT_PANEL_ID:
            return @"账户";
            break;
        case KEYBINDINGS_PANNEL_ID:
            return @"快捷键";
            break;
        case INFO_PANEL_ID:
            return @"关于";
            break;
        default:
            return @"";
            break;
    }
}

- (NSImage*)imageForPreferencePanelAt:(NSInteger)index
{
    switch (index) {
        case GENERAL_PANEL_ID:
            return [NSImage imageNamed:NSImageNamePreferencesGeneral];
            break;
        case ACCOUNT_PANEL_ID:
            return [NSImage imageNamed:NSImageNameUser];
            break;
        case KEYBINDINGS_PANNEL_ID:
            return [NSImage imageNamed:NSImageNameAdvanced];
            break;
        case INFO_PANEL_ID:
            return [NSImage imageNamed:NSImageNameInfo];
            break;
        default:
            return nil;
            break;
    }
}

- (NSView*)panelViewForPreferencePanelAt:(NSInteger)index
{
    switch (index) {
        case GENERAL_PANEL_ID:
            return general;
            break;
        case ACCOUNT_PANEL_ID:
            return [self accountView];
            break;
        case KEYBINDINGS_PANNEL_ID:
            return keybindings;
            break;
        case INFO_PANEL_ID:
            return info;
            break;
        default:
            return nil;
            break;
    }
}

-(NSString*) identifyForPreferencePanelAt:(NSInteger)index
{
    if (index == SPACE_PANEL_ID) {
        return NSToolbarFlexibleSpaceItemIdentifier;
    }
    else {
        return [NSString stringWithFormat:@"%ld",index];
    }
}

//------------------------------界面的action------------------------------
-(void) loginAction:(id)sender
{
    switch ([sender tag]) {
        case 0: // 获取验证码
            [sender setEnabled:NO];
            [indicator setHidden:NO];
            [indicator startAnimation:self];
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                self.captcha_code = [DMDoubanAuthHelper getNewCaptchaCode];
                NSString* captcha_url = [@"http://douban.fm/misc/captcha?size=m&id=" stringByAppendingString:self.captcha_code];
                
                [NSImage AsyncLoadImageWithURLString:captcha_url andCallBackBlock:^(NSImage * image) {
                    if (image == nil) {
                        [sender setImage:nil];
                        [sender setTitle:@"获取失败，请重试"];
                        [sender setBordered:YES];
                    }
                    else {
                        [sender setImage:image];
                        [sender setBordered:NO];
                        [sender setTitle:@""];
                    }
                    [sender setEnabled:YES];
                    [indicator stopAnimation:self];
                    [indicator setHidden:YES];
                }];
            }];
            break;
            
        case 1: // 登陆操作
            [self loginOperationAction];
            break;
        case 2:
            [self resetLoginForm];
            break;
        default:
            break;
    }
}

-(void) lockLoginForm:(BOOL) lock
{
    BOOL enable = (lock==NO);
    [email setEnabled:enable];
    [password setEnabled:enable];
    [captcha setEnabled:enable];
    [resetButton setEnabled:enable];
    [submitButton setEnabled:enable];
}

-(void) resetLoginForm
{
    [email setStringValue:@""];
    [password setStringValue:@""];
    [captcha setStringValue:@""];
}

-(void) loginOperationAction
{
    NSString* em = [email stringValue];
    NSString* pw = [password stringValue];
    NSString* captcha_solution = [captcha stringValue];
    
    NSString* errorstring = nil;
    if (!(em && [em length])) {
        errorstring = @"邮箱不能为空";
    }
    else if(!(pw && [pw length])) {
        errorstring = @"密码不能为空";
    }
    else if(!(captcha_solution && [captcha_solution length])){
        errorstring = @"验证码不能为空";
    }

    if (errorstring) {
        [errorLabel setStringValue:errorstring];
        [errorLabel setHidden:NO];
        return;
    }
    else {
        [errorLabel setHidden:YES];
    }
    
    [self lockLoginForm:YES];
    NSDictionary* authDict =
    @{kAuthAttributeUsername: em,
     kAuthAttributePassword: pw,
     kAuthAttributeCaptchaSolution: captcha_solution,
     kAuthAttributeCaptchaCode: self.captcha_code};
    
    NSBlockOperation* loginOperation = 
    [NSBlockOperation blockOperationWithBlock:^{
        NSError* error = NULL;
        error = [[DMDoubanAuthHelper sharedHelper] authWithDictionary:authDict];
        
        [self lockLoginForm:NO];
        if (error) {
            if ([error code] == -2 && error.userInfo) {
                NSString* err_msg = [NSString stringWithFormat:@"%@",error.userInfo];
                [errorLabel setStringValue:err_msg];
            }
            else {
                [errorLabel setStringValue:@"登陆失败！"];
            }
            [errorLabel setHidden:NO];
            [captcha setStringValue:@""];
            [captchaButton performClick:nil];
            
        }
        else {
            [tabcontroller selectPanelAtIndex:ACCOUNT_PANEL_ID];
        }
        
    }];
    [[NSOperationQueue mainQueue] addOperation:loginOperation];
}

-(void) logoutAction:(id)sender
{
    [[DMDoubanAuthHelper sharedHelper] logoutAndCleanData];
    [tabcontroller selectPanelAtIndex:ACCOUNT_PANEL_ID];
}

-(id) accountView
{
    if ([DMDoubanAuthHelper sharedHelper].username) {
        // update account view 
        DMDoubanAuthHelper* sh = [DMDoubanAuthHelper sharedHelper];
        
        NSString* playedString = [NSString stringWithFormat:@"%ld", sh.playedSongsCount];
        NSString* likedString = [NSString stringWithFormat:@"%ld", sh.likedSongsCount];
        NSString* bannedString = [NSString stringWithFormat:@"%ld",sh.bannedSongsCount];
        
        [usernameTextField setStringValue:sh.username];
        [userIconButton setImage:[sh getUserIcon]];
        
        [playrecordButton setLabel:playedString forSegment:0];
        [playrecordButton setLabel:likedString forSegment:1];
        [playrecordButton setLabel:bannedString forSegment:2];
        
        return account;
    }
    else return login;
}

-(void)showPlayRecord:(id)sender
{
    NSInteger selectedSegment = [sender selectedSegment];
    NSString* urlstring = nil;
    switch (selectedSegment) {
        case 0:
            urlstring = @"http://douban.fm/mine?type=played";
            break;
        case 1:
            urlstring = @"http://douban.fm/mine?type=liked";
            break;
        case 2:
            urlstring = @"http://douban.fm/mine?type=banned";
    }
    NSURL* openurl = [NSURL URLWithString:urlstring];
    [[NSWorkspace sharedWorkspace] openURL:openurl];
}
// ----------------------- 快捷键控制 ----------------------------

-(void) changePlayControlShortcutMode:(id)sender
{
    if ([sender state] == NSOnState) {
        [playShortcut setEnabled:NO];
        [skipShortcut setEnabled:NO];
    }
    else {
        [playShortcut setEnabled:YES];
        [skipShortcut setEnabled:YES];
    }
    [DMShortcutsHandler registrationShortcuts];
}

-(void) awakeFromNib
{
    NSDictionary* dict = [[NSBundle mainBundle] infoDictionary];
    [displayName setStringValue:dict[@"CFBundleDisplayName"]];
    version.stringValue = [NSString stringWithFormat:@"%@.%@",
                           dict[@"CFBundleShortVersionString"],
                           dict[@"CFBundleVersion"]
                           ];
    
    playShortcut.associatedUserDefaultsKey = keyPlayShortcut;
    skipShortcut.associatedUserDefaultsKey = keySkipShortcut;
    rateShortcut.associatedUserDefaultsKey = keyRateShortcut;
    banShortcut.associatedUserDefaultsKey = keyBanShortcut;
    showPrefsPanel.associatedUserDefaultsKey = keyShowPrefsPanel;
    togglePanelShortcut.associatedUserDefaultsKey = keyTogglePanelShortcut;
    

    if ([[[NSUserDefaults standardUserDefaults]
          valueForKey:@"usesMediaKey"] integerValue] == NSOnState) {
        [playShortcut setEnabled:NO];
        [skipShortcut setEnabled:NO];
    }
}

@end
