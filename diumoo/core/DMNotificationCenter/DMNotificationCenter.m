//
//  DMNotificationCenter.m
//  diumoo
//
//  Created by Shanzi on 12-7-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DMNotificationCenter.h"
#import "DMPlayableCapsule.h"
#import "DMPanelWindowController.h"

@implementation DMNotificationCenter
-(id) init
{
    self = [super init];
    if (self) {
        [GrowlApplicationBridge setGrowlDelegate:self];
    }
    return self;
}

-(NSDictionary*) registrationDictionaryForGrowl
{
    NSArray* array = [NSArray arrayWithObjects:@"Music",@"Account",nil];
    NSDictionary* dict = nil;
    dict = [NSDictionary dictionaryWithObjectsAndKeys:
            array,
            GROWL_NOTIFICATIONS_ALL,
            array,
            GROWL_NOTIFICATIONS_DEFAULT
            , nil];
    return dict;
}

-(void) growlNotificationWasClicked:(id)clickContext
{
    [[DMPanelWindowController sharedWindowController] openPanel];
}

-(void) notifyMusicWithCapsule:(DMPlayableCapsule*) capsule
{
    id values = [[NSUserDefaultsController sharedUserDefaultsController] values];
    if ([[values valueForKey:@"enableGrowl"] integerValue] == NSOnState)
    {
        NSString* detail = [NSString stringWithFormat:@"%@ - <%@>",capsule.artist,capsule.albumtitle];
        
        NSData* data = [capsule.picture TIFFRepresentation];
        [GrowlApplicationBridge notifyWithTitle:capsule.title
                                    description:detail
                               notificationName:@"Music"
                                       iconData:data
                                       priority:0
                                       isSticky:NO 
                                   clickContext:capsule.sid];
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




@end
