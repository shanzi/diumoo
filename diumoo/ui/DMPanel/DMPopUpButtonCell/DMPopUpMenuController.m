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
@synthesize currentChannelID,specialMode;


-(void) awakeFromNib
{
    

    currentChannelID = [[[NSUserDefaults standardUserDefaults]
                         valueForKey:@"channel"]integerValue];
    
    if (currentChannelID == 0 || currentChannelID == -3) {
        self.currentChannelMenuItem = [mainMenu itemWithTag:currentChannelID];
    }
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
    
    
    NSMenu* menuToPopup = nil;
    
    if ([sender tag] == -1) {
        menuToPopup = shareMenu;
    }
    else if (self.specialMode) {
        menuToPopup = exitSpecialMenu;
    }
    else if ([sender tag]) {
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
    
    if (channelDict != nil) {
        double timestamp = [[channelDict valueForKey:@"timestamp"] doubleValue];
        if(([NSDate timeIntervalSinceReferenceDate] - timestamp) > 3600 * 24){
            DMLog(@"获取新的列表");
            // -------------------------获取新的列表--------------------------
            NSURL* updateUrl = [NSURL URLWithString:UPDATE_URL];
            NSURLRequest* urlrequest = [NSURLRequest requestWithURL:updateUrl
                                                        cachePolicy:NSURLCacheStorageAllowed
                                                    timeoutInterval:3.0];
            NSURLResponse* response = NULL;
            NSError* error = NULL;
            NSData* data = [NSURLConnection sendSynchronousRequest:urlrequest
                                                 returningResponse:&response
                                                             error:&error];
            
            
            if(error==NULL){
                NSDictionary* dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
                
                if(error == NULL){
                    public_list = [dict valueForKey:@"public"];
                    dj_list = [dict valueForKey:@"dj"];
                    
                    if ([public_list count] && [dj_list count]) {
                        
                        NSNumber* timestamp = [NSNumber numberWithDouble:
                                               [NSDate timeIntervalSinceReferenceDate]];
                        
                        NSDictionary* writedic = [NSDictionary
                                                  dictionaryWithObjectsAndKeys:
                                                  public_list,@"public",
                                                  dj_list,@"dj",
                                                  timestamp,@"timestamp",nil ];
                        DMLog(@"写入电台列表");
                        [writedic writeToFile:filepath atomically:YES];
                        [self updateMenuItemsWithPublicList:public_list andDJList:dj_list];
                        
                        return;
                    }
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
    DMLog(@"update");
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
                NSInteger tag = [[dic valueForKey:@"id"] integerValue];
                [item setTag:tag];
                [item setTarget:self];
                [djcollectedmenu addItem:item];
                [item autorelease];
            }
            self.djCollectMenu = [djcollectedmenu retain];
            [[djMenu itemWithTag:-11] setSubmenu:djcollectedmenu];
            [djcollectedmenu autorelease];
        }
        else 
        {
            self.djCollectMenu = nil;
        }
        [djSaveItem setHidden:NO];
    }
    else 
    {
        [djSaveItem setHidden:YES];
    }
    
    NSArray* oldRecentDJ = [djMenu itemArray];
    for (NSMenuItem* item in oldRecentDJ) {
        if ([item tag]>1000000) {
            [djMenu removeItem:item];
        }
    }
    
    NSArray* recentlyPlayedDJ = nil;
    
    recentlyPlayedDJ = [[NSUserDefaults standardUserDefaults] valueForKey:@"recentdj"];
    
    if ([recentlyPlayedDJ count]>0) {
        [[djMenu itemWithTag:-13] setHidden:YES];
        for (NSDictionary* channel in recentlyPlayedDJ) {
            NSInteger tag = [[channel valueForKey:@"cid"] integerValue];
            NSString* title = [channel valueForKey:@"title"];
            NSMenuItem* item = [[NSMenuItem alloc] initWithTitle:title 
                                                          action:@selector(changeChannelAction:)
                                                   keyEquivalent:@""] ;
            [item setTarget:self];
            [item setIndentationLevel:1];
            [item setTag:tag];
            [djMenu addItem:item];
            if (tag == currentChannelID) {
                self.currentChannelMenuItem = item;
            }
            [item autorelease];
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
                                    keyEquivalent:@""] ;
            [menu addItem:cateitem];
            [cateitem autorelease];
            
            NSArray* channelsArray = [dic valueForKey:@"channels"];
            for (NSDictionary* channel in channelsArray) {
                NSMenuItem* item = [[NSMenuItem alloc] 
                                    initWithTitle:[channel valueForKey:@"name"]
                                    action:@selector(changeChannelAction:)
                                    keyEquivalent:@""];
                
                NSInteger tag = [[channel valueForKey:@"channel_id"] integerValue];
                [item setTag:tag];
                [item setIndentationLevel:1];
                [item setTarget:self];
                [menu addItem:item];
                if (tag == currentChannelID) {
                    self.currentChannelMenuItem = item;
                }
                [item autorelease];
            }
        }
    }
    return [menu autorelease];
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
    
    NSString* cid = [NSString stringWithFormat:@"%ld",currentChannelID];
    
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
                    NSMenuItem * newItem = [currentChannelMenuItem copy] ;
                    [djCollectMenu addItem:newItem];
                    [newItem autorelease];
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
    DMLog(@"ismain: %d,%@",[NSThread isMainThread],[NSThread currentThread]);
    NSMenuItem* citem = currentChannelMenuItem;
    NSMenuItem* newItem = nil;
    
    while (citem != nil) {
        [citem setState:NSOffState];
        citem = [citem parentItem];
    }
    
    
    NSInteger tag = [sender tag];
    
    
    if (tag <1) {
        newItem = sender;
        [longMainButton setTitle:[sender title]];
        [longMainButton setHidden:NO];

    }
    else {
        
        if (tag > 1000000) 
        {
            NSMenuItem* djMenuItem = [mainMenu itemWithTag:1000000];
            [mainButton setTitle:djMenuItem.title];
            [subButton setTitle:[sender title]];
            
            if ([djCollectMenu itemWithTag:tag])
            {
                [djSaveItem setState:NSOnState];
            }
            
            
            // -------------------------- 处理dj兆赫的菜单和记录 --------------------------

            newItem = [djMenu itemWithTag:tag]; //先检查当前的dj兆赫是不是已经在最近播放的列表里了
            if(newItem == nil){
                // 当前的dj兆赫还没被加入到最近播放列表，现在加入它
                newItem = [sender copy];
                
                // 先获取到当前dj菜单下所有item，检查item的数量是否超过了要求，超过了的话，就删掉一些
                NSArray* menuarray = [djMenu itemArray]; 
                if ([menuarray count]>20) {
                    NSMenuItem* itemToRemove = [menuarray lastObject];
                    if ([itemToRemove tag] > 1000000) {
                        [djMenu removeItem:itemToRemove];
                    }
                }
                
                
                // 把“空”字样那个菜单项隐藏掉
                NSMenuItem* itemToHide = [djMenu itemWithTag:-13];
                [itemToHide setHidden:YES];
                
                // 计算将新item插入的index
                NSInteger indexToInsert = [djMenu indexOfItem:itemToHide] +1;
                [newItem setIndentationLevel:1];
                [djMenu insertItem:newItem atIndex:indexToInsert];
                
                // 现在将新的最近播放列表保存到用户偏好里
                NSArray* newMenuArray = [djMenu itemArray];
                NSMutableArray* arrayToSave = [[NSMutableArray alloc] init];
                for (NSMenuItem* menuItem in newMenuArray) {
                    NSInteger ttag = [menuItem tag];
                    if(ttag > 1000000){
                        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [NSNumber numberWithInteger:ttag],@"cid",
                                              [menuItem title],@"title", nil];
                        [arrayToSave addObject:dict];
                    }
                }
                
                id values = [[NSUserDefaultsController sharedUserDefaultsController] values];
                [values setValue:arrayToSave forKey:@"recentdj"];
                [arrayToSave autorelease];
            }
        }
        else if(tag >0 )
        {
            newItem = sender;
            NSMenuItem* publicMenuItem = [mainMenu itemWithTag:1];
            [mainButton setTitle:publicMenuItem.title];
            [subButton setTitle:[newItem title]];
            
        }
        
        [longMainButton setHidden:YES];
    }

    [newItem setState:NSOnState];
    NSMenuItem* pitem = [newItem parentItem];
    while (pitem!=nil) {
        [pitem setState:NSMixedState];
        pitem = [pitem parentItem];
    }
    
    
    
    self.currentChannelID = tag;
    self.currentChannelMenuItem = newItem;
    
    
    id values = [[NSUserDefaultsController sharedUserDefaultsController] values];
    [values setValue:[NSNumber numberWithInteger:tag] forKey:@"channel"]; // 把当前的兆赫记录到偏好设置里

}

-(void) enterSpecialPlayingModeWithTitle:(NSString *)title artist:(NSString*)artist andTypeString:(NSString*) type
{
    self.specialMode = YES;
    
    NSString* typeTitle = [NSString stringWithFormat:@"%@:%@",type,title];
    NSString* fullTitle = [@"名称 : " stringByAppendingString:title];
    
    [longMainButton setTitle:typeTitle];
    [longMainButton setHidden:NO];
    
    NSString* exitTitle = [NSString stringWithFormat:@"返回“%@”兆赫",[currentChannelMenuItem title]];
    NSString* fulltype = [@"类型 : " stringByAppendingString:type];
    
    [[exitSpecialMenu itemWithTag:0] setTitle:exitTitle];
    [[exitSpecialMenu itemWithTag:1] setTitle:fullTitle];
    [[exitSpecialMenu itemWithTag:2] setTitle:artist];
    [[exitSpecialMenu itemWithTag:3] setTitle:fulltype];
    
}

-(void) exitSepecialPlayingMode
{
    if (self.currentChannelID < 1) {
        [longMainButton setTitle:[currentChannelMenuItem title]];
    }
    else {
        [longMainButton setHidden:YES];
    }
    
    self.specialMode = NO;
}

-(void) setPrivateChannelEnabled:(BOOL)enable
{

    NSMenuItem* itemHeartChannel = [mainMenu itemWithTag:-3];
    NSMenuItem* itemPrivateChannel = [mainMenu itemWithTag:0];
    
    if (enable == NO) {
        itemPrivateChannel.action = nil;
        itemHeartChannel.action = nil;
        if (itemHeartChannel.state != NSOffState || itemHeartChannel.state != NSOffState) {
            [self changeChannelAction:[publicMenu itemWithTag:1]];
        }
    }
    else {
        [itemHeartChannel setAction:@selector(changeChannelAction:)];
        [itemPrivateChannel setAction:@selector(changeChannelAction:)];
    }
    
}


-(void) unlockChannelMenuButton
{
    [longMainButton setEnabled:YES];
    [mainButton setEnabled:YES];
    [subButton setEnabled:YES];
}

@end
