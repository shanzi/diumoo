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
#define DJ_EXPLORER_URL @"http://douban.fm/j/explore/"

#define kDMCollectChannel @"collect_channel"
#define kDMUncollectChannel @"uncollect_channel"

#import "CJSONDeserializer.h"
#import "NSDictionary+UrlEncoding.h"

@implementation DMPopUpMenuController

@synthesize delegate;
@synthesize publicMenu,djExploreMenu,djCollectMenu,currentChannelMenuItem;
@synthesize currentChannelID;


-(void) awakeFromNib
{

    
    currentChannelID = 1;
    
    [self updateChannelList];
}

-(void)popUpMenu:(id)sender
{
    
    NSView* view = sender;
    NSRect rect = [view convertRect:view.bounds toView:nil];
    NSPoint point = NSMakePoint(rect.origin.x + rect.size.width, 
                                rect.origin.y + rect.size.height
                                );
    
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
        [djSaveItem setHidden:YES]; 
    }
    else {
        if([djSaveItem tag]==-10)
            [djSaveItem setHidden:NO];
        
        if (currentChannelID > 1000000) {
            
            if ([djCollectMenu numberOfItems]<1) {
                [[djMenu itemWithTag:-11] setHidden:YES];
            }
            else {
                [[djMenu itemWithTag:-11] setHidden:NO];
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
        [[djMenu itemWithTag:-12] setSubmenu:djExploreMenu];
        [[mainMenu itemWithTag:1000000]setSubmenu:djMenu];
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
                                    action:@selector(changeChannelAction:)
                                    keyEquivalent:@""];
                [item setTag:[[dic valueForKey:@"id"] integerValue]];
                [item setTarget:self];
                [djcollectedmenu addItem:item];
            }
            self.djCollectMenu = djcollectedmenu;
            [[djMenu itemWithTag:-11] setSubmenu:djcollectedmenu];
        }
        else 
        {
            self.djCollectMenu = nil;
        }
        
        [djSaveItem setTag:-10];
        [djSaveItem setHidden:NO];
    }
    else {
        [djSaveItem setTag:-9];
        [djSaveItem setHidden:YES];
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
                                    action:@selector(changeChannelAction:)
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

-(BOOL) djChannelCollectRequestWithType:(NSString*) type andCid:(NSString*) cid
{
    
    NSURL* requestURL = [NSURL URLWithString:[DJ_EXPLORER_URL stringByAppendingString:type]];
    NSArray* cookies= [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:requestURL];
    NSString* ck = nil;
    
    for (NSHTTPCookie* cookie in cookies) {
        if([cookie.name isEqualToString:@"ck"]){
            ck = [cookie value];
            ck = [ck stringByReplacingOccurrencesOfString:@"\""
                                               withString:@""];
        }
    }
    
    NSDictionary* formdic=[NSDictionary dictionaryWithObjectsAndKeys:
                           cid,@"channel_id",
                           ck,@"ck",nil];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:requestURL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[[formdic urlEncodedString]dataUsingEncoding:NSUTF8StringEncoding]];
    [request setTimeoutInterval:2.0];
    
    NSURLResponse* r;
    NSError* e = NULL;
    NSData* d = [NSURLConnection sendSynchronousRequest:request returningResponse:&r error:&e];
    
    NSLog(@"%@",formdic);
    
    if(e==NULL){
        NSDictionary* dic = [[CJSONDeserializer deserializer] deserializeAsDictionary:d error:&e];
        
        NSLog(@"%@",dic);
        
        if(e==NULL && [[dic valueForKey:@"status"] boolValue])
        {
            return YES;
        }
    }
    return NO;
}


-(void) saveDJChannelAction:(id)sender
{
    if ([[NSThread currentThread] isMainThread]) {
        return [self performSelectorInBackground:@selector(saveDJChannelAction:)
                                      withObject:sender];
    }
    
    NSString* cid = [NSString stringWithFormat:@"%d",currentChannelID];
    
    if (currentChannelID > 1000000) {
        if ([sender state]==NSOnState) {
            // 取消收藏
            
            BOOL ok = [self djChannelCollectRequestWithType:kDMUncollectChannel 
                                           andCid:cid];
            if (ok) {
                [djCollectMenu removeItem:currentChannelMenuItem];
                [sender setState:NSOffState];
            }
        }
        else {
            // 收藏当前电台
            BOOL ok = [self djChannelCollectRequestWithType:kDMCollectChannel andCid:cid];
            if (ok) {
                if ([djCollectMenu indexOfItem:currentChannelMenuItem]<0) {
                    NSMenuItem * newItem = [currentChannelMenuItem copy];
                    [djCollectMenu addItem:newItem];
                }
                [sender setState:NSOnState];
            }
        }
    }
}

-(void) changeChannelAction:(id)sender
{
    [[self delegate] performSelector:@selector(channelChangeActionWithSender:) 
                          withObject:sender];
}

-(void) updateChannelMenuWithSender:(id)sender
{
    if (self.currentChannelMenuItem == sender) {
        return;
    }
    
    NSMenuItem* citem = currentChannelMenuItem;
    while (citem != nil) {
        [citem setState:NSOffState];
        citem = [citem parentItem];
    }
    
    
    NSInteger tag = [sender tag];
    
    if (tag <1) {
        
        [mainButton setTitle:[sender title]];
        
        
        NSRect frame = mainButton.frame;
        if (frame.size.width < 200) {
            NSRect  newframe = NSMakeRect(frame.origin.x, frame.origin.y, 
                                          frame.size.width*2, frame.size.height);
            
            [mainButton setFrame:newframe];

        }
        
    }
    else {
        
        if (tag > 1000000) 
        {
            NSMenuItem* djMenuItem = [mainMenu itemWithTag:1000000];
            [mainButton setTitle:djMenuItem.title];
            [subButton setTitle:[sender title]];
            
            if ([djCollectMenu itemWithTag:tag]) {
                [djSaveItem setState:NSOnState];
            }
            
        }
        else if(tag >0 )
        {
            NSMenuItem* publicMenuItem = [mainMenu itemWithTag:1];
            [mainButton setTitle:publicMenuItem.title];
            [subButton setTitle:[sender title]];
            
        }
        
        if (mainButton.bounds.size.width > 126) {
            NSRect frame = mainButton.frame;
            NSRect  newframe = NSMakeRect(frame.origin.x, frame.origin.y, 
                                          125, frame.size.height);
            
            [mainButton setFrame:newframe];
        }
        
        
    }
    
    [sender setState:NSOnState];
    NSMenuItem* pitem = [sender parentItem];
    while (pitem!=nil) {
        [pitem setState:NSMixedState];
        pitem = [pitem parentItem];
    }
    self.currentChannelID = tag;
    self.currentChannelMenuItem = sender;
}

@end
