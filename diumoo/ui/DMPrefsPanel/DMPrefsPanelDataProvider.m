//
//  DMPrefsPanelDataProvider.m
//  diumoo
//
//  Created by Shanzi on 12-6-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DMDoubanAuthHelper.h"
#import "DMPrefsPanelDataProvider.h"
#import "DMService.h"
#import "NSImage+AsyncLoadImage.h"
#import "Shortcut.h"

@implementation DMPrefsPanelDataProvider
@synthesize captcha_code;

- (void)showPreferences
{
    tabcontroller = [[PLTabPreferenceControl alloc] initWithWindowNibName:@"DMPrefsPanel"];
    [tabcontroller showWindow:nil];
}

- (int)countOfPreferencePanels
{
    return PANEL_VIEW_COUNT;
}

- (NSString*)titleForPreferencePanelAt:(NSInteger)index
{
    switch (index) {
    case GENERAL_PANEL_ID:
        return NSLocalizedString(@"PREF_GENERAL", @"通用");
        break;
    case ACCOUNT_PANEL_ID:
        return NSLocalizedString(@"PREF_ACCOUNT", @"账户");
        break;
    case KEYBINDINGS_PANNEL_ID:
        return NSLocalizedString(@"PREF_SHORTCUTS", @"快捷键");
        break;
    case INFO_PANEL_ID:
        return NSLocalizedString(@"PREF_ABOUT", @"关于");
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
        return [self generalView];
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

- (NSString*)identifyForPreferencePanelAt:(NSInteger)index
{
    if (index == SPACE_PANEL_ID) {
        return NSToolbarFlexibleSpaceItemIdentifier;
    }
    else {
        return [NSString stringWithFormat:@"%ld", index];
    }
}

//------------------------------界面的action------------------------------
- (void)loginAction:(id)sender
{
    switch ([sender tag]) {
        {
        case 0: // 获取验证码
            [sender setEnabled:NO];
            [indicator startAnimation:nil];
            captcha_code = [DMDoubanAuthHelper getNewCaptchaCode];

            NSString* captcha_url = [@"https://douban.fm/misc/captcha?size=m&id=" stringByAppendingString:captcha_code];

            [NSImage AsyncLoadImageWithURLString:captcha_url andCallBackBlock:^(NSImage* image) {
                if (image == nil) {
                    [sender setImage:nil];
                    [sender setTitle:NSLocalizedString(@"FETCH_CAPTCHA_FAILED", @"获取失败，请重试")];
                    [sender setBordered:YES];
                }
                else {
                    [sender setImage:image];
                    [sender setBordered:NO];
                    [sender setTitle:@""];
                }
                [sender setEnabled:YES];
                [indicator stopAnimation:nil];
            }];
            break;
        }

        {
        case 1: // 登陆操作
            [self loginOperationAction];
            break;
        }
        {
        case 2:
            [self resetLoginForm];
            break;
        }
        {
        default:
            break;
        }
    }
}

- (void)lockLoginForm:(BOOL)lock
{
    BOOL enable = (lock == NO);
    [email setEnabled:enable];
    [password setEnabled:enable];
    [captcha setEnabled:enable];
    [resetButton setEnabled:enable];
    [submitButton setEnabled:enable];
}

- (void)resetLoginForm
{
    [email setStringValue:@""];
    [password setStringValue:@""];
    [captcha setStringValue:@""];
}

- (void)loginOperationAction
{
    NSString* em = [email stringValue];
    NSString* pw = [password stringValue];
    NSString* captcha_solution = [captcha stringValue];

    NSString* errorstring = nil;
    if (!(em && [em length])) {
        errorstring = NSLocalizedString(@"EMAIL_MUST_NOT_BE_EMPTY", @"邮箱不能为空");
    }
    else if (!(pw && [pw length])) {
        errorstring = NSLocalizedString(@"PASSWORD_MUST_NOT_BE_EMPTY", @"密码不能为空");
    }
    else if (!(captcha_solution && [captcha_solution length])) {
        errorstring = NSLocalizedString(@"CAPTCHA_MUST_NOT_BE_EMPTY", @"验证码不能为空");
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
    [loginIndicator startAnimation:nil];
    NSDictionary* authDict =
        @{ kAuthAttributeUsername : em,
            kAuthAttributePassword : pw,
            kAuthAttributeCaptchaSolution : captcha_solution,
            kAuthAttributeCaptchaCode : self.captcha_code,
            @"remember" : @"on",
            @"task" : @"sync_channel_list"
        };

    [DMService performOnServiceQueue:^{
        NSError* error = NULL;
        error = [[DMDoubanAuthHelper sharedHelper] authWithDictionary:authDict];

        [self lockLoginForm:NO];
        [loginIndicator stopAnimation:nil];

        if (error) {
            if ([error code] == -2 && error.userInfo) {
                NSString* err_msg = [NSString stringWithFormat:@"%@", error.userInfo];
                [errorLabel setStringValue:err_msg];
            }
            else {
                [errorLabel setStringValue:NSLocalizedString(@"LOGIN_FAILED", @"登陆失败！")];
            }
            [errorLabel setHidden:NO];
            [captcha setStringValue:@""];
            [captchaButton performClick:nil];
        }
        else {
            [DMService performOnMainQueue:^{
                [tabcontroller selectPanelAtIndex:ACCOUNT_PANEL_ID];
            }];
        }
    }];
}

- (void)logoutAction:(id)sender
{
    [[DMDoubanAuthHelper sharedHelper] logoutAndCleanData];
    [self resetLoginForm];
    [tabcontroller selectPanelAtIndex:ACCOUNT_PANEL_ID];
}

- (id)accountView
{
    if ([DMDoubanAuthHelper sharedHelper].username) {
        // update account view
        DMDoubanAuthHelper* sh = [DMDoubanAuthHelper sharedHelper];

        [usernameTextField setStringValue:sh.username];

        [userIconButton setImage:[sh getUserIcon]];

        return account;
    }
    else
        return login;
}

- (id)generalView
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSNumber* quality = [defaults valueForKey:@"musicQuality"];

    if ([quality isEqualToNumber:@64])
        [muiscQuality selectItemAtIndex:0];
    else if ([quality isEqualToNumber:@128])
        [muiscQuality selectItemAtIndex:1];
    else
        [muiscQuality selectItemAtIndex:2];

    return general;
}

// ----------------------- 快捷键控制 ----------------------------
- (void)awakeFromNib
{
    NSDictionary* dict = [[NSBundle mainBundle] infoDictionary];
    [displayName setStringValue:dict[@"CFBundleDisplayName"]];
    version.stringValue = [NSString stringWithFormat:@"%@.%@",
                                    dict[@"CFBundleShortVersionString"],
                                    dict[@"CFBundleVersion"]];

    playShortcut.associatedUserDefaultsKey = keyPlayShortcut;
    skipShortcut.associatedUserDefaultsKey = keySkipShortcut;
    rateShortcut.associatedUserDefaultsKey = keyRateShortcut;
    banShortcut.associatedUserDefaultsKey = keyBanShortcut;
    showPrefsPanel.associatedUserDefaultsKey = keyShowPrefsPanel;
    togglePanelShortcut.associatedUserDefaultsKey = keyTogglePanelShortcut;

    if ([[[NSUserDefaults standardUserDefaults]
            valueForKey:@"usesMediaKey"] integerValue]
        == NSOnState) {
        [playShortcut setEnabled:NO];
        [skipShortcut setEnabled:NO];
    }
}

- (IBAction)donation:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://diumoo.net/"]];
}

@end
