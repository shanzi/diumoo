//
//  DMAppDelegate.m
//  diumoo
//
//  Created by Shanzi on 12-6-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DMAppDelegate.h"

@implementation DMAppDelegate
@synthesize center,panel;

-(void) applicationDidFinishLaunching:(NSNotification *)notification
{
    NSLog(@"finishlaunching");
//    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
//                         @"airobot1@163.com",kAuthAttributeUsername,
//                         @"akirasphere",kAuthAttributePassword,
//                         @"K9Mr6E7212DEOWjN7pXRt8EV",kAuthAttributeCaptchaCode,
//                         @"mistake",kAuthAttributeCaptchaSolution,
//                         nil];
//
//    [[DMDoubanAuthHelper sharedHelper] authWithDictionary:dic asynchronousRequest:NO];
//    
//    NSLog(@"%@",[DMDoubanAuthHelper sharedHelper]);
//    //[center fireToPlay:nil];
    self.panel = [[DMPanelWindowController alloc] init];
    [self.panel showWindow:nil];
}

-(void) applicationWillTerminate:(NSNotification *)notification
{
    
}

-(void)mediaKeyTap:(SPMediaKeyTap*)keyTap receivedMediaKeyEvent:(NSEvent*)event{
    
    int keyCode = (([event data1] & 0xFFFF0000) >> 16);
    int keyFlags = ([event data1] & 0x0000FFFF);
    int keyState = (((keyFlags & 0xFF00) >> 8)) ==0xA;
    if(keyState==0)
        switch (keyCode) {
            case NX_KEYTYPE_PLAY:
                break;
            case NX_KEYTYPE_FAST:
                break;
            case NX_KEYTYPE_REWIND:
                break;
        }
    
}

-(BOOL) application:(NSApplication*)app openFile:(NSString *)filename
{
    NSLog(@"TEST");
    return NO;
}

-(void) showPreference:(id)sender
{
    PLTabPreferenceControl* pc = [[PLTabPreferenceControl alloc]initWithWindowNibName:@"DMPrefsPanel"];
    [pc showWindow:nil];
}


@end
