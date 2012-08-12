//
//  DMDocumentWindowController.m
//  documentTest
//
//  Created by Shanzi on 12-7-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DMDocumentWindowController.h"
#import "SMTabBar.h"
#import "SMTabBarItem.h"
#import "EDStarRating.h"
#import "CJSONDeserializer.h"
#import "DMDetailViewController.h"
#import "NSImage+AsyncLoadImage.h"

#define DOUBAN_API_URL @"http://api.douban.com/music/subject/"

@interface DMDocumentWindowController ()
-(void)buildTabButton;
@end

@implementation DMDocumentWindowController

-(id)init
{
    self = [super initWithWindowNibName:@"DMDocumentWindow"];
    if (self) {
        lock = [[NSLock alloc] init];
    }
    return self;
}


- (void)windowDidLoad
{
    [super windowDidLoad];
    
    DMLog(@"load");
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    starRating.displayMode = EDStarRatingDisplayAccurate;
    starRating.editable = NO;
    starRating.starHighlightedImage = [NSImage imageNamed:@"starhighlighted"];
    starRating.starImage = [NSImage imageNamed:@"star"];
    [self buildTabButton];
    [self setupWindowForDocument:self.document];
    if ([self.document isInViewingMode]) {
        [revertButton setEnabled:NO];
    }
}

-(void) windowDidExpose:(NSNotification *)notification
{
    [NSApp activateIgnoringOtherApps:YES];
}

-(void)buildTabButton
{
    NSMutableArray *tabBarItems = [NSMutableArray arrayWithCapacity:2];
    {
        NSImage *image = [NSImage imageNamed:@"view_icon"];
        [image setTemplate:YES];
        SMTabBarItem *item = [[SMTabBarItem alloc] initWithImage:image tag:0];
        item.toolTip = @"预览";
        item.keyEquivalent = @"1";
        item.keyEquivalentModifierMask = NSCommandKeyMask;
        [tabBarItems addObject:item];
    }
    {
        NSImage *image = [NSImage imageNamed:@"detail_icon"];
        [image setTemplate:YES];
        SMTabBarItem *item = [[SMTabBarItem alloc] initWithImage:image tag:1];
        item.toolTip = @"详细信息";
        item.keyEquivalent = @"2";
        item.keyEquivalentModifierMask = NSCommandKeyMask;
        [tabBarItems addObject:item];
    }

    tabBar.items = tabBarItems;
}

-(void)setupWindowForDocument:(NSDocument *)doc
{
    
    NSDictionary* dict = [doc performSelector:@selector(baseSongInfo)];
    
    NSString* picture_url = [dict valueForKey:@"picture"];
    [NSImage AsyncLoadImageWithURLString:picture_url andCallBackBlock:^(NSImage *image) {
        if (image) {
            albumCoverButton.image = image;
        }
        else
        {
            albumCoverButton.image = [NSImage imageNamed:@"albumfail.png"];
        }
    }];
    
    
    artist.stringValue = [dict valueForKey:@"artist"];
    songTitle.stringValue = [dict valueForKey:@"title"];
    
    albumTitle = [[dict valueForKey:@"albumtitle"] copy];
    aid = [[dict valueForKey:@"aid"] copy];
    albumLocation = [[dict valueForKey:@"url"] copy];
    starRating.rating = [[dict valueForKey:@"rating_avg"] floatValue];
    [starRating setNeedsDisplay];
}


-(NSString*) windowTitleForDocumentDisplayName:(NSString *)displayName
{

    return [NSString stringWithFormat:@"专辑:《%@》", albumTitle];
}


-(void) revert:(id)sender
{
    DMLog(@"%@",self.document);
    [self.document revertDocumentToSaved:nil];
}


-(NSSize) window:(NSWindow*) w willResizeForVersionBrowserWithMaxPreferredSize:(NSSize)maxPreferredFrameSize maxAllowedSize:(NSSize)maxAllowedFrameSize
{
    NSSize maxWindowSize = self.window.maxSize;
    if (maxAllowedFrameSize.width > (maxWindowSize.width * 2) &&
        maxAllowedFrameSize.height > (maxWindowSize.height * 2)
        ) {
        return self.window.maxSize;
    }
    return self.window.minSize;
}

-(void) windowWillEnterVersionBrowser:(NSNotification *)notification
{
    [revertButton setEnabled:NO];
}

-(void) windowDidExitVersionBrowser:(NSNotification *)notification
{
    [revertButton setEnabled:YES];
}

// ------------------------inspector tabbar delegate---------------------------
- (void)tabBar:(SMTabBar *)tabBar didSelectItem:(SMTabBarItem *)item
{
    NSInteger tag = [item tag];
    [tabView selectTabViewItemAtIndex:tag];
    if (tag == 1) {
        if(![lock tryLock])
            return;
        [progressIndicator startAnimation:nil];
        NSBlockOperation* fetchDetailOperation = 
        [NSBlockOperation blockOperationWithBlock:^{
            
            NSString* apiurlString = [NSString stringWithFormat:@"%@%@?alt=json",
                                      DOUBAN_API_URL,aid
                                      ];
            NSURL* url = [NSURL URLWithString:apiurlString];
            NSURLRequest* request = [NSURLRequest requestWithURL:url cachePolicy:NSURLCacheStorageAllowed timeoutInterval:2.0];
            
            
            
            NSError* error = nil;
            NSURLResponse* response = nil;
            
            NSData* data = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&response 
                                                             error:&error];
            
            if (error) {
                indicatorText.stringValue = @"获取详细信息失败" ;
                [progressIndicator stopAnimation:nil];
                [lock unlock];
            }
            else {
                NSDictionary* dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:data
                                                                                         error:&error];
                
                if (error) {
                    indicatorText.stringValue = @"解析信息失败（来自豆瓣音乐人的专辑无法获取详细信息）" ;
                    [progressIndicator stopAnimation:nil];
                }
                else {
                    indicatorText.stringValue = @"解析信息成功！" ;
                    [progressIndicator stopAnimation:nil];
                    
                    [self displayDetailView:dict];
                }
            }
        }];
        
        [[NSOperationQueue currentQueue] addOperation:fetchDetailOperation];
    }
}

-(void) displayDetailView:(NSDictionary* )dict
{
    NSMutableDictionary* dictOfDetail = [NSMutableDictionary dictionary];
    NSMutableArray* songs = [NSMutableArray array];
    
    
    NSArray* attribtes = dict[@"db:attribute"];
    
    for (NSDictionary* d in attribtes) {
        NSString* name = d[@"@name"];
        if (name==nil) {
            continue;
        }
        if ([name isEqualToString:@"track"]) {
            [songs addObject:[d valueForKey:@"$t"]];
        }
        else if ([name isEqualToString:@"discs"]) {
            dictOfDetail[@"唱片数"] = [d valueForKey:@"$t"];
        }
        else if([name isEqualToString:@"version"]){
            dictOfDetail[@"版本特性"] = [d valueForKey:@"$t"];
        }
        else if([name isEqualToString:@"ean"]){
            dictOfDetail[@"条形码"] = [d valueForKey:@"$t"];
        }
        else if([name isEqualToString:@"pubdate"]){
            dictOfDetail[@"发行时间"] = [d valueForKey:@"$t"];
        }
        else if([name isEqualToString:@"title"]){
            dictOfDetail[@"专辑名"] = [d valueForKey:@"$t"];
        }
        else if([name isEqualToString:@"singer"]){
            dictOfDetail[@"艺术家"] = [d valueForKey:@"$t"];
        }
        else if([name isEqualToString:@"publisher"]){
            dictOfDetail[@"出版者"] = [d valueForKey:@"$t"];
        }
        else if([name isEqualToString:@"media"]){
            dictOfDetail[@"介质"] = [d valueForKey:@"$t"];
        }
    }
    
    NSDictionary* rating = [dict valueForKey:@"gd:rating"];
    NSString* rating_string = [NSString stringWithFormat:@"%@ (%@ 人评价)",
                               rating[@"@average"],
                               rating[@"@numRaters"]];
    
    dictOfDetail[@"豆瓣评分"] = rating_string;
    
    NSString* summary = dict[@"summary"][@"$t"];
    
    
    DMDetailViewController* detailViewController = 
    [[DMDetailViewController alloc] initWithBaseInformation:dictOfDetail 
                                                    summary:summary 
                                                   andSongs:songs];
    
    NSScrollView* scrollview = [[NSScrollView alloc] init];
    [scrollview setHasVerticalScroller:YES];
    [scrollview setAutohidesScrollers:YES];
    
    [scrollview setDocumentView:detailViewController];
    [detailViewController setAutoresizingMask:NSViewWidthSizable|NSViewMinXMargin];
    
    NSTabViewItem* detailTabViewItem = [tabView tabViewItemAtIndex:1];
    [detailTabViewItem setView:scrollview];
    
}

-(void) playAlbum:(id)sender
{
    DMLog(@"post play album signal");
    NSString* type = @"album";
    NSString* typestring = @"专辑";
    NSString* artisttitle = [@"艺术家 : " stringByAppendingString:[artist stringValue]];
    NSDictionary* userinfo = @{@"aid": aid,
                              @"title": albumTitle,
                              @"artist": artisttitle,
                              @"type": type,
                              @"typestring": typestring,
                              @"album_location": albumLocation};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"playspecial" 
                                                        object:self
                                                      userInfo:userinfo];
}

-(void)openAlbumLocation:(id)sender
{

    NSURL* albumurl = [NSURL URLWithString:albumLocation];
    [[NSWorkspace sharedWorkspace] openURL:albumurl];
}

@end
