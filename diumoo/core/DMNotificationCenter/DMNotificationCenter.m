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
        [GrowlApplicationBridge setGrowlDelegate:self];
        if (NSClassFromString(@"NSUserNotification")) {
            [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
        }
    }
    return self;
}

-(void) dealloc
{
    [GrowlApplicationBridge setGrowlDelegate:nil];
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:nil];
}

#pragma ---

-(NSDictionary*)registrationDictionaryForGrowl
{
    NSArray* array = @[@"Music",@"Account",@"Bitrate"];
    return @{GROWL_NOTIFICATIONS_ALL: array,GROWL_NOTIFICATIONS_DEFAULT: array};
}

-(void) growlNotificationWasClicked:(id)clickContext
{
    [[DMPanelWindowController sharedWindowController] togglePanel:nil];
}

-(void) notifyMusicWithItem:(DMPlayableItem *)item
{
    NSUserDefaults* values = [NSUserDefaults standardUserDefaults];
    
    if ([[values valueForKey:@"enableGrowl"] integerValue] == NSOnState)
    {
        NSString* detail = [NSString stringWithFormat:@"%@ - <%@>",item.musicInfo[@"artist"],item.musicInfo[@"albumtitle"]];
        if([[values valueForKey:@"usesGrowlUnderML"] integerValue] !=  NSOnState && NSClassFromString(@"NSUserNotification")) {
            NSUserNotification *notification = [[NSUserNotification alloc] init];
            NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
            notification.title = item.musicInfo[@"title"];
            notification.informativeText = detail;
            notification.soundName = nil;
            [center deliverNotification: notification];
        } else {            
            NSData* data = [item.cover TIFFRepresentation];
            
            [GrowlApplicationBridge notifyWithTitle:item.musicInfo[@"title"]
                                        description:detail
                                   notificationName:@"Music"
                                           iconData:data
                                           priority:0
                                           isSticky:NO
                                       clickContext:item.musicInfo[@"sid"]];
        }
    }
    
    if([[values valueForKey:@"useGlobalNotification"] integerValue]==NSOnState){
        NSDictionary* userInfo = @{
        @"Player State" : @"Playing",
        @"Store URL":item.musicInfo[@"albumLocation"],
        @"Album":item.musicInfo[@"albumtitle"],
        @"Name":item.musicInfo[@"title"],
        @"Artist":item.musicInfo[@"artist"],
        @"Total Time":@([item.musicInfo[@"length"] integerValue]),
        };
        [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.apple.iTunes.playerInfo"
                                                                       object:@"com.apple.iTunes.player"
                                                                     userInfo:userInfo];
    }
    
    if([[values valueForKey:@"displayAlbumCoverOnDock"] integerValue]==NSOnState){
        [NSApp setApplicationIconImage:item.cover];
    }
}

-(void) notifyBitrate
{
    NSLog(@"Bitrate changed Notification");
    NSUserDefaults* values = [NSUserDefaults standardUserDefaults];
    
    if ([[values valueForKey:@"enableGrowl"] integerValue] == NSOnState)
    {
        NSString* title = NSLocalizedString(@"BITRATE_CHANGED", nil);
        NSString* detail = [NSLocalizedString(@"BITRATE_CHANGED_TO_VALUE", nil)
                            stringByAppendingFormat:@"%@ Kbps",[values valueForKey:@"musicQuality"]];
        
        if([[values valueForKey:@"usesGrowlUnderML"] integerValue] ==  NSOffState && NSClassFromString(@"NSUserNotification")) {
            NSUserNotification *notification = [[NSUserNotification alloc] init];
            NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
            notification.title = title;
            notification.informativeText = detail;
            notification.soundName = nil;
            [center deliverNotification: notification];
        } else {
            
            [GrowlApplicationBridge notifyWithTitle:title
                                        description:detail
                                   notificationName:@"Bitrate"
                                           iconData:[[NSImage imageNamed:@"icon"] TIFFRepresentation]
                                           priority:0
                                           isSticky:NO
                                       clickContext:nil];
        }
    }

}

-(void) clearNotifications
{
    if(NSClassFromString(@"NSUserNotification")){
        [[NSUserNotificationCenter defaultUserNotificationCenter] removeAllDeliveredNotifications];
    }
}

//this method forced Notification Center present notification whatever the application is foreground
- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}

-(BOOL) hasNetworkClientEntitlement
{
    return YES;
}

@end
