//
//  DMNotificationCenter.m
//  diumoo
//
//  Created by Shanzi on 12-7-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DMNotificationCenter.h"


@implementation DMNotificationCenter

#pragma init and dealloc

-(id) init
{
    if (self = [super init]) {
        if(!NSClassFromString(@"NSUserNotification")) {
        [GrowlApplicationBridge setGrowlDelegate:self];
        }
    }
    return self;
}

-(void) dealloc
{
    [GrowlApplicationBridge setGrowlDelegate:nil];
    [super dealloc];
}

#pragma ---

-(NSDictionary*) registrationDictionaryForGrowl
{
    NSArray* array = @[@"Music",@"Account"];
    return @{GROWL_NOTIFICATIONS_ALL: array,GROWL_NOTIFICATIONS_DEFAULT: array};
}

-(void) growlNotificationWasClicked:(id)clickContext
{
    [[DMPanelWindowController sharedWindowController] togglePanel:nil];
}

-(void) notifyMusicWithCapsule:(DMPlayableCapsule*) capsule
{
    NSUserDefaults* values = [NSUserDefaults standardUserDefaults];
    if ([[values valueForKey:@"enableGrowl"] integerValue] == NSOnState)
    {
        NSString* detail = [NSString stringWithFormat:@"%@ - <%@>",capsule.artist,capsule.albumtitle];
        NSData* data = [capsule.picture TIFFRepresentation];
        if(NSClassFromString(@"NSUserNotification")) {
            NSUserNotification *notification = [[NSUserNotification alloc] init];
            NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
            [center setDelegate:self];
            notification.title = capsule.title;
            notification.informativeText = detail;
            notification.soundName = nil;
            [notification setDeliveryDate:[NSDate dateWithTimeIntervalSinceNow:0]];
            [center scheduleNotification: notification];
            [notification release];
        } else {
        [GrowlApplicationBridge notifyWithTitle:capsule.title   
                                    description:detail
                               notificationName:@"Music"
                                       iconData:data
                                       priority:0
                                       isSticky:NO 
                                   clickContext:capsule.sid];
        }
    }
    if([[values valueForKey:@"enableEmulateITunes"] integerValue]==NSOnState)
    {
        NSDictionary* postDict = @{@"Player State": @"Playing",
                                                @"Album": capsule.albumtitle,
                                                @"Name": capsule.title,
                                                @"Artist": capsule.artist};
        [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.apple.iTunes.playerInfo"
                                                                       object:@"com.apple.iTunes.player"
                                                                     userInfo:postDict];
    }
    
    if([[values valueForKey:@"displayAlbumCoverOnDock"] integerValue]==NSOnState)
    {
        [NSApp setApplicationIconImage:capsule.picture];
    }
}

-(void) clearNotifications
{
    if(NSClassFromString(@"NSUserNotification")){
        [[NSUserNotificationCenter defaultUserNotificationCenter] removeAllDeliveredNotifications];
    }
}

//this method forced Notification Center present notification whatever the application is foreground
- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification{
    return YES;
}

@end
