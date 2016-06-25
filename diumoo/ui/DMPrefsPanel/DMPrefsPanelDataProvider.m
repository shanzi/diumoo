//
//  DMPrefsPanelDataProvider.m
//  diumoo
//
//  Created by Shanzi on 12-6-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "diumoo-Swift.h"
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
            captcha_code = [DMAuthHelper getNewCaptchaCode];

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
    [errorLabel setHidden:YES];
    
    if (!(em && [em length])) {
        [errorLabel setStringValue: NSLocalizedString(@"EMAIL_MUST_NOT_BE_EMPTY", @"邮箱不能为空")];
        [errorLabel setHidden:NO];
        return;
    }
    else if (!(pw && [pw length])) {
        [errorLabel setStringValue:NSLocalizedString(@"PASSWORD_MUST_NOT_BE_EMPTY", @"密码不能为空")];
        [errorLabel setHidden:NO];
        return;
    }
    else if (!(captcha_solution && [captcha_solution length])) {
        [errorLabel setStringValue: NSLocalizedString(@"CAPTCHA_MUST_NOT_BE_EMPTY", @"验证码不能为空")];
        [errorLabel setHidden:NO];
        return;
    }
    else if (!self.captcha_code) {
        [errorLabel setStringValue: NSLocalizedString(@"INVALID_CAPTCHA_CODE", @"未获取验证码")];
        [errorLabel setHidden:NO];
        return;
    }

    [self lockLoginForm:YES];
    [loginIndicator startAnimation:nil];
    NSDictionary* authDict =
        @{ [DMAuthHelper kAuthAttributeUsername] : em,
           [DMAuthHelper kAuthAttributePassword] : pw,
           [DMAuthHelper kAuthAttributeCaptchaSolution] : captcha_solution,
           [DMAuthHelper kAuthAttributeCaptchaCode] : self.captcha_code,
            @"remember" : @"on",
            @"task" : @"sync_channel_list"
        };

    [DMService performOnServiceQueue:^{
        NSError* error = [[DMAuthHelper sharedHelper] authWithDictionary:authDict];

        [self lockLoginForm:NO];
        [loginIndicator stopAnimation:nil];

        if (error) {
            [errorLabel setStringValue:NSLocalizedString(@"LOGIN_FAILED", @"登陆失败！")];
            [errorLabel setHidden:NO];
            [captcha setStringValue:@""];
            
            self.captcha_code = nil;
            [captchaButton setImage:nil];
            [captchaButton setTitle:NSLocalizedString(@"点击获取验证码", @"获取失败，请重试")];
            [captchaButton setBordered:YES];
            [loginIndicator setHidden: YES];
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
    [[DMAuthHelper sharedHelper] logout];
    [self resetLoginForm];
    [tabcontroller selectPanelAtIndex:ACCOUNT_PANEL_ID];
}

- (id)accountView
{
    if ([DMAuthHelper sharedHelper].username) {
        // update account view
        DMAuthHelper* sh = [DMAuthHelper sharedHelper];

        [usernameTextField setStringValue:sh.username];
        
        [userIconButton setImage:sh.userIcon];

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
