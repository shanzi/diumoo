//
//  DMNotificationCenter.m
//  diumoo
//
//  Created by Shanzi on 12-7-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DMNotificationCenter.h"


@implementation DMNotificationCenter
-(id) init
{
    self = [super init];
    if (self) {
        if(!NSClassFromString(@"NSUserNotification")) {
        [GrowlApplicationBridge setGrowlDelegate:self];
        }
    }
    return self;
}

-(NSDictionary*) registrationDictionaryForGrowl
{
    NSArray* array = [NSArray arrayWithObjects:@"Music",@"Account",nil];
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:array,GROWL_NOTIFICATIONS_ALL,
                                                                    array,GROWL_NOTIFICATIONS_DEFAULT,nil];
    return dict;
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
        if(NSClassFromString(@"NSUserNotification"))
        {
            NSUserNotification *notification = [[NSUserNotification alloc] init];
            NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
            [center setDelegate:self];
            notification.hasActionButton = NO;
            notification.title = capsule.title;
            notification.informativeText = detail;
            notification.soundName = nil;
            [notification setDeliveryDate:[NSDate dateWithTimeIntervalSinceNow:1]];
            [center scheduleNotification: notification];
            [center release];
        }
        else {
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
        NSDictionary* postDict = nil;
        postDict = [NSDictionary dictionaryWithObjectsAndKeys:
                    @"Playing",@"Player State",
                    capsule.albumtitle,@"Album",
                    capsule.title,@"Name",
                    capsule.artist,@"Artist",
                     nil];
        [[NSDistributedNotificationCenter defaultCenter] 
         postNotificationName:@"com.apple.iTunes.playerInfo"
         object:@"com.apple.iTunes.player"
         userInfo:postDict];
    }
    
    if([[values valueForKey:@"displayAlbumCoverOnDock"] integerValue]==NSOnState)
    {
        [NSApp setApplicationIconImage:capsule.picture];
    }
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification{
    return YES;
}

@end
