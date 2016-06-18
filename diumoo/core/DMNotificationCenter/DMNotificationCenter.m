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
        if (NSClassFromString(@"NSUserNotification")) {
            [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
        }
    }
    return self;
}

-(void) dealloc
{
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:nil];
}

#pragma ---

-(void) notifyMusicWithItem:(DMPlayableItem *)item
{
    NSUserDefaults* values = [NSUserDefaults standardUserDefaults];
    
    if ([[values valueForKey:@"enableGrowl"] integerValue] == NSOnState)
    {
        NSString* detail = [NSString stringWithFormat:@"%@ - <%@>",item.musicInfo[@"artist"],item.musicInfo[@"albumtitle"]];
        
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
        notification.title = item.musicInfo[@"title"];
        notification.informativeText = detail;
        notification.soundName = nil;
        [center deliverNotification: notification];
    }
    
    if([[values valueForKey:@"useGlobalNotification"] integerValue]==NSOnState){
        NSDictionary* userInfo;
        if (item.musicInfo[@"sid"]) {
            
            userInfo = @{
                                       @"Player State" : @"Playing",
                                       @"Store URL":item.musicInfo[@"albumLocation"],
                                       @"Album":item.musicInfo[@"albumtitle"],
                                       @"Name":item.musicInfo[@"title"],
                                       @"Artist":item.musicInfo[@"artist"],
                                       @"Total Time":@([item.musicInfo[@"length"] integerValue]),
                                       };
        }
        else{
            userInfo = @{@"Player State": @"Paused"};
        }
        //[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.apple.iTunes.playerInfo"
                                                                       //object:@"com.apple.iTunes.player"
                                                                     //userInfo:userInfo];
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
        
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
        notification.title = title;
        notification.informativeText = detail;
        notification.soundName = nil;
        [center deliverNotification: notification];
    }
    
}

- (void) copylinkNotification:(NSString *)url
{
    NSUserDefaults* values = [NSUserDefaults standardUserDefaults];
    if ([[values valueForKey:@"enableGrowl"] integerValue] == NSOnState)
    {
        NSString* title = NSLocalizedString(@"SHARE_LINK_TITLE", nil);
        NSString* detail = url;
        
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
        notification.title = title;
        notification.informativeText = detail;
        notification.soundName = nil;
        [center deliverNotification: notification];
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



@end
