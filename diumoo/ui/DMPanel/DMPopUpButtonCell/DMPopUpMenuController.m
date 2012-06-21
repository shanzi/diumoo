//
//  DMPopUpMenuController.m
//  diumoo
//
//  Created by Shanzi on 12-6-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DMPopUpMenuController.h"
#import "DMDoubanAuthHelper.h"

//#define UPDATE_URL @"http://diumoo.xiuxiu.de/j/channels/"
#define UPDATE_URL @"http://diumoo.xiuxiu.de/fmlist/2?timestamp=1331269290.0"
#define DJ_EXPLORER_URL @"http://douban.fm/explore/"
#define kDMCollectChannel @"collect_channel"
#define kDMUncollectChannel @"uncollect_channel"

#import "CJSONDeserializer.h"
#import "NSDictionary+UrlEncoding.h"

@implementation DMPopUpMenuController
@synthesize mainMenu,publicMenu,djMenu,djExploreMenu,djCollectMenu,popupCell;
@synthesize currentChannelID;

-(void) awakeFromNib
{
    //[[mainButton cell] setMenu:mainMenu];
    self.popupCell = [[NSPopUpButtonCell alloc] init];
    [popupCell setPullsDown:YES];
    [popupCell setPreferredEdge:NSMaxYEdge];
    
    currentChannelID = 1;
    
    [self updateChannelList];
}

-(void)popUpMenu:(id)sender
{
    
    NSView* view = sender;
    NSPoint point = [view convertPoint:NSMakePoint(0, 40) toView:nil];
    
    
    NSEvent* event = [NSEvent mouseEventWithType:NSLeftMouseUp
                                        location:point
                                   modifierFlags:0
                                       timestamp:0
                                    windowNumber:view.window.windowNumber 
                                         context:nil
                                     eventNumber:0
                                      clickCount:1 
                                        pressure:1];
    
    NSMenu* menuToPopup;
    
    if ([sender tag]) {
        menuToPopup = mainMenu;
    }
    else {
        if (currentChannelID > 1000000) {
            if (djCollectMenu == nil) {
                [[djMenu itemWithTag:-11] setHidden:YES];
            }
            menuToPopup = djMenu;
        }
        else if(currentChannelID > 0) {
            menuToPopup = publicMenu;
        }
    }
    

    
    [NSMenu popUpContextMenu:menuToPopup withEvent:event forView:sender];

}

-(void) updateChannelList
{
    NSString* filepath = [[NSBundle mainBundle] pathForResource:@"channels" ofType:@"plist"];
    
    NSDictionary* channelDict = [NSDictionary dictionaryWithContentsOfFile:filepath];
    
    NSArray* public_list = nil;
    NSArray* dj_list = nil;
    
    if (channelDict == nil) {
        double timestamp = [[channelDict valueForKey:@"timestamp"] doubleValue];
        if(([NSDate timeIntervalSinceReferenceDate] - timestamp) > 3600 * 24){
            
            // -------------------------获取新的列表--------------------------
            NSURL* updateUrl = [NSURL URLWithString:UPDATE_URL];
            NSURLRequest* urlrequest = [NSURLRequest requestWithURL:updateUrl
                                                        cachePolicy:NSURLCacheStorageAllowed
                                                    timeoutInterval:1.0];
            
            NSURLResponse* response = NULL;
            NSError* error = NULL;
            NSData* data = [NSURLConnection sendSynchronousRequest:urlrequest
                                                 returningResponse:&response
                                                             error:&error];
            
            
            if(error==NULL){
                channelDict = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
                if(error == NULL){
                    public_list = [channelDict valueForKey:@"public"];
                    dj_list = [channelDict valueForKey:@"dj"];
                    
                    NSNumber* timestamp = [NSNumber numberWithDouble:
                                           [NSDate timeIntervalSinceReferenceDate]];
                    
                    NSDictionary* writedic = [NSDictionary
                                              dictionaryWithObjectsAndKeys: 
                                              public_list,@"public",
                                              dj_list,@"dj",
                                              timestamp,@"timestamp",nil ];
                    
                    [writedic writeToFile:filepath atomically:YES];
                    [self updateMenuItemsWithPublicList:public_list andDJList:dj_list];
                    
                    return;
                }
            }
            //----------------------------------------------------------------------
            
        }
    }
    
    
    public_list = [channelDict valueForKey:@"public"];
    dj_list = [channelDict valueForKey:@"dj"];
    [self updateMenuItemsWithPublicList:public_list andDJList:dj_list];
}

-(void) updateMenuItemsWithPublicList:(NSArray*) publiclist andDJList:(NSArray*) djlist
{
    if (publiclist) {
        self.publicMenu = [self buildMenuWithChannelListArray:publiclist];
        [[mainMenu itemWithTag:1] setSubmenu:publicMenu];
    }
    if (djlist)
    {
        self.djExploreMenu = [self buildMenuWithChannelListArray:djlist];
        [[mainMenu itemWithTag:1000000]setSubmenu:djExploreMenu];
    }
    
    DMDoubanAuthHelper* dmah = [DMDoubanAuthHelper sharedHelper];
    if (dmah.username) {
        NSArray* collected = [dmah.userinfo valueForKey:@"collected_chls"];
        if([collected count]>0)
        {
            NSMenu* djcollectedmenu = [[NSMenu alloc] init];
            for (NSDictionary* dic in collected) {
                NSMenuItem* item = [[NSMenuItem alloc]
                                    initWithTitle:[dic valueForKey:@"real_name"]
                                    action:@selector(menuItemAction:)
                                    keyEquivalent:@""];
                [item setTag:[[dic valueForKey:@"id"] integerValue]];
                [item setTarget:self];
                [djcollectedmenu addItem:item];
            }
            self.djCollectMenu = djcollectedmenu;
            [[djMenu itemWithTag:-11] setSubmenu:djcollectedmenu];
        }
        else {
            self.djCollectMenu = nil;
        }
    }
}

-(NSMenu*) buildMenuWithChannelListArray:(NSArray*)array
{
    NSMenu* menu = [[NSMenu alloc] init];
    for (NSDictionary* dic in array) {
        if([dic valueForKey:@"cate"])
        {
            if ([menu numberOfItems] > 0) {
                [menu addItem:[NSMenuItem separatorItem]];
            }
            
            NSMenuItem* cateitem = [[NSMenuItem alloc]
                                initWithTitle:[dic valueForKey:@"cate"] 
                                action:nil
                                keyEquivalent:@""];
            [menu addItem:cateitem];
            
            NSArray* channelsArray = [dic valueForKey:@"channels"];
            for (NSDictionary* channel in channelsArray) {
                NSMenuItem* item = [[NSMenuItem alloc] 
                                    initWithTitle:[channel valueForKey:@"name"]
                                    action:@selector(menuItemAction:)
                                    keyEquivalent:@""];
                [item setTag:[[channel valueForKey:@"channel_id"] integerValue]];
                [item setIndentationLevel:1];
                [item setTarget:self];
                [menu addItem:item];
            }
        }
    }
    return menu;
}

-(void) menuItemAction:(id)sender
{

    NSInteger tag = [sender tag];
    
        NSLog(@"%ld",tag);
    
    switch (tag) {
        case -11:
            // 收藏与解除收藏 dj 兆赫
            NSLog(@"save");
            break;
        case -13:
            // 打开豆瓣
            [[NSWorkspace sharedWorkspace] openURL:
             [NSURL URLWithString:@"http://douban.fm/explorer/"]
             ];
            break;
        default:
            // 改变电台兆赫
            break;
    }
}


@end
