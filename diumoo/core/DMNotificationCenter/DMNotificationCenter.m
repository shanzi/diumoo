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
    NSArray* array = [NSArray arrayWithObjects:@"Music",@"Account",nil];
    return [NSDictionary dictionaryWithObjectsAndKeys:array,GROWL_NOTIFICATIONS_ALL,
                                                                    array,GROWL_NOTIFICATIONS_DEFAULT,nil];
}

-(void) growlNotificationWasClicked:(id)clickContext
{
    [[DMPanelWindowController sharedWindowController] togglePanel:nil];
}

-(void) notifyMusicWithCapsule:(DMPlayableCapsule*) capsule
{
    NSUserDefaults* values = [NSUserDefaults standardUserDefaults];
    
    if([[values valueForKey:@"displayAlbumCoverOnDock"] integerValue]==NSOnState)
    {
        [NSApp setApplicationIconImage:capsule.picture];
    }
    
    if ([[values valueForKey:@"enableGrowl"] integerValue] == NSOnState)
    {
        NSString* detail = [NSString stringWithFormat:@"%@ - <%@>",capsule.artist,capsule.albumtitle];
        
        NSData* data = [capsule.picture TIFFRepresentation];
        if(NSClassFromString(@"NSUserNotification")) {
            NSUserNotification *notification = [[NSUserNotification alloc] init];
            NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
            [center setDelegate:self];
            notification.hasActionButton = NO;
            notification.title = capsule.title;
            notification.informativeText = detail;
            notification.soundName = nil;
            [notification setDeliveryDate:[NSDate dateWithTimeIntervalSinceNow:0]];
            [center scheduleNotification: notification];
            [center release];
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
        NSDictionary* postDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                @"Playing",@"Player State",
                                                capsule.albumtitle,@"Album",
                                                capsule.title,@"Name",
                                                capsule.artist,@"Artist",nil];
        [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.apple.iTunes.playerInfo"
                                                                       object:@"com.apple.iTunes.player"
                                                                     userInfo:postDict];
    }
}

-(void) clearNotifications
{
    [[NSUserNotificationCenter defaultUserNotificationCenter] removeAllDeliveredNotifications];
}

//this method forced Notification Center present notification whatever the application is foreground
- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification{
    return YES;
}

@end
