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

#define DOUBAN_API_URL @"http://api.douban.com/music/subject/"

@interface DMDocumentWindowController ()

-(void)buildTabButton;
@end

@implementation DMDocumentWindowController
@synthesize tabView,tabBar;
@synthesize starRating,revertButton,albumCoverButton,songTitle,artist;
@synthesize indicatorText,progressIndicator;
@synthesize albumTitle,lock;

-(id)init
{
    self = [super initWithWindowNibName:@"DMDocumentWindow"];
    if (self) {
        self.lock = [[NSLock alloc] init];
    }
    return self;
}

-(void)dealloc
{
    [lock release];
    [super dealloc];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    starRating.displayMode = EDStarRatingDisplayAccurate;
    starRating.editable = NO;
    starRating.starHighlightedImage = [NSImage imageNamed:@"starhighlighted.png"];
    starRating.starImage = [NSImage imageNamed:@"star.png"];
    [self buildTabButton];
    [self setupWindowForDocument:self.document];
    if ([self.document isInViewingMode]) {
        [revertButton setEnabled:NO];
    }
}

-(void)buildTabButton
{
    NSMutableArray *tabBarItems = [NSMutableArray arrayWithCapacity:2];
    {
        NSImage *image = [NSImage imageNamed:@"view_icon.png"];
        [image setTemplate:YES];
        SMTabBarItem *item = [[SMTabBarItem alloc] initWithImage:image tag:0];
        item.toolTip = @"预览";
        item.keyEquivalent = @"1";
        item.keyEquivalentModifierMask = NSCommandKeyMask;
        [tabBarItems addObject:item];
        [item release];
    }
    {
        NSImage *image = [NSImage imageNamed:@"detail_icon.png"];
        [image setTemplate:YES];
        SMTabBarItem *item = [[SMTabBarItem alloc] initWithImage:image tag:1];
        item.toolTip = @"详细信息";
        item.keyEquivalent = @"2";
        item.keyEquivalentModifierMask = NSCommandKeyMask;
        [tabBarItems addObject:item];
        [item release];
    }

    self.tabBar.items = tabBarItems;
}

-(void)setupWindowForDocument:(NSDocument *)doc
{
    
    NSDictionary* dict = [doc performSelector:@selector(baseSongInfo)];
    
    NSString* picture_url = [dict valueForKey:@"picture"];
    NSURL * purl = [NSURL URLWithString:picture_url];
    NSImage* image = [[NSImage alloc] initWithContentsOfURL:purl];
    
    self.albumCoverButton.image = image;
    self.artist.stringValue = [dict valueForKey:@"artist"];
    self.songTitle.stringValue = [dict valueForKey:@"title"];
    
    self.albumTitle = [dict valueForKey:@"albumtitle"]; 
    starRating.rating = [[dict valueForKey:@"rating_avg"] floatValue];
    [starRating setNeedsDisplay];
    [image release];
}


-(NSString*) windowTitleForDocumentDisplayName:(NSString *)displayName
{

    return [NSString stringWithFormat:@"专辑:《%@》", self.albumTitle];
}


-(void) revert:(id)sender
{
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
        if(![lock tryLock])return;
        [self.progressIndicator startAnimation:nil];
        NSBlockOperation* fetchDetailOperation = 
        [NSBlockOperation blockOperationWithBlock:^{
            NSString* apiurlString = [NSString stringWithFormat:@"%@%@?alt=json",
                                      DOUBAN_API_URL,
                                      [self.document performSelector:@selector(aid)]];
            NSURL* url = [NSURL URLWithString:apiurlString];
            NSURLRequest* request = [NSURLRequest requestWithURL:url cachePolicy:NSURLCacheStorageAllowed timeoutInterval:2.0];
            
            
            
            NSError* error = nil;
            NSURLResponse* response = nil;
            
            NSData* data = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&response 
                                                             error:&error];
            
            if (error) {
                self.indicatorText.stringValue = @"获取详细信息失败" ;
                [self.progressIndicator stopAnimation:nil];
                [lock unlock];
            }
            else {
                NSDictionary* dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:data
                                                                                         error:&error];
                
                if (error) {
                    self.indicatorText.stringValue = @"解析信息失败（来自豆瓣音乐人的专辑无法获取详细信息）" ;
                    [self.progressIndicator stopAnimation:nil];
                }
                else {
                    self.indicatorText.stringValue = @"解析信息成功！" ;
                    [self.progressIndicator stopAnimation:nil];
                    
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
    
    
    NSArray* attribtes = [dict objectForKey:@"db:attribute"];
    
    for (NSDictionary* d in attribtes) {
        NSString* name = [d objectForKey: @"@name"];
        if (name==nil) {
            continue;
        }
        if ([name isEqualToString:@"track"]) {
            [songs addObject:[d valueForKey:@"$t"]];
        }
        else if ([name isEqualToString:@"discs"]) {
            [dictOfDetail setObject:[d valueForKey:@"$t"] forKey:@"唱片数"];
        }
        else if([name isEqualToString:@"version"]){
            [dictOfDetail setObject:[d valueForKey:@"$t"] forKey:@"版本特性"];
        }
        else if([name isEqualToString:@"ean"]){
            [dictOfDetail setObject:[d valueForKey:@"$t"] forKey:@"条形码"];
        }
        else if([name isEqualToString:@"pubdate"]){
            [dictOfDetail setObject:[d valueForKey:@"$t"] forKey:@"发行时间"];
        }
        else if([name isEqualToString:@"title"]){
            [dictOfDetail setObject:[d valueForKey:@"$t"] forKey:@"专辑名"];
        }
        else if([name isEqualToString:@"singer"]){
            [dictOfDetail setObject:[d valueForKey:@"$t"] forKey:@"艺术家"];
        }
        else if([name isEqualToString:@"publisher"]){
            [dictOfDetail setObject:[d valueForKey:@"$t"] forKey:@"出版者"];
        }
        else if([name isEqualToString:@"media"]){
            [dictOfDetail setObject:[d valueForKey:@"$t"] forKey:@"介质"];
        }
    }
    
    NSDictionary* rating = [dict valueForKey:@"gd:rating"];
    NSString* rating_string = [NSString stringWithFormat:@"%@ (%@ 人评价)",
                               [rating objectForKey:@"@average"],
                               [rating objectForKey:@"@numRaters"]];
    
    [dictOfDetail setObject:rating_string forKey:@"豆瓣评分"];
    
    NSString* summary = [[dict objectForKey:@"summary"] objectForKey:@"$t"];
    
    
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

@end
