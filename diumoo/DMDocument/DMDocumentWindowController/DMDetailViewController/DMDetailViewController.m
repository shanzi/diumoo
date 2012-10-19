//
//  DMDetailViewController.m
//  documentTest
//
//  Created by Shanzi on 12-7-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DMDetailViewController.h"
#import "JUInspectorView.h"


#define kColumnKey @"k"
#define kColumnValue @"v"

@interface DMDetailViewController ()

@end

@implementation DMDetailViewController
@synthesize baseInformationView,summaryView,songsView;

- (id)initWithBaseInformation:(NSDictionary *)info summary:(NSString *)summary andSongs:(NSArray *)songs
{
    self = [super init];
    if (self) {
        // Initialization code here
        
        baseInfoKeys = @[
        NSLocalizedString(@"DETAIL_ALBUM",@"专辑名"),
        NSLocalizedString(@"DETAIL_SINGER",@"艺术家"),
        NSLocalizedString(@"DETAIL_DOUBAN_RATING",@"豆瓣评分"),
        NSLocalizedString(@"DETAIL_VERSION",@"版本特性"),
        NSLocalizedString(@"DETAIL_PUBLISHER",@"出版者"),
        NSLocalizedString(@"DETAIL_PUBDATE", @"发行时间"),
        NSLocalizedString(@"DETAIL_MEDIA", @"介质"),
        NSLocalizedString(@"DETAIL_DISCS", @"唱片数"),
        NSLocalizedString(@"DETAIL_EAN", @"条形码")];
        
        self.baseInformationView = [self buildTableView];
        self.songsView = [self buildTableView];
        
        self.summaryView = [[NSTextView alloc]
                            initWithFrame:NSMakeRect(0, 0, 400, 200)];
        [summaryView setEditable:NO];
        [summaryView setAutoresizingMask:NSViewWidthSizable];

        if (summary) {
            self.summaryView.string = summary;
        }
        else {
            self.summaryView.string = NSLocalizedString(@"DETAIL_UNKNOWN", nil);
        }
        
        
        baseInfoDict = info;
        songsArray = songs;
        
        JUInspectorView* infoInspector = [[JUInspectorView alloc] init];
        infoInspector.name = NSLocalizedString(@"DETAIL_ALBUM_INFO",  @"专辑信息");
        infoInspector.body = baseInformationView;
        
        JUInspectorView* summaryInspector = [[JUInspectorView alloc] init];
        NSScrollView* scrollView = [[NSScrollView alloc]
                                    initWithFrame:NSMakeRect(0, 0, 400, 200)];
        
        [scrollView setDocumentView:summaryView];
        [scrollView setHasVerticalScroller:YES];
        [scrollView setAutohidesScrollers:YES];
        
        summaryInspector.name = NSLocalizedString(@"DETAIL_ABSTRACT", @"简介");
        summaryInspector.body = scrollView;
        
        JUInspectorView* songsInspector = [[JUInspectorView alloc] init];
        songsInspector.name = NSLocalizedString(@"DETAIL_SONGS", @"曲目");
        songsInspector.body = songsView;
        
        [self addInspectorView:infoInspector expanded:YES];
        [self addInspectorView:summaryInspector expanded:NO];
        [self addInspectorView:songsInspector expanded:YES];
        
    }
    return self;
}


-(NSTableView*) buildTableView
{
    NSTableView* tableview = [[NSTableView alloc]init];
    NSTableColumn* column1 = [[NSTableColumn alloc] initWithIdentifier:kColumnKey];
    NSTableColumn* column2 = [[NSTableColumn alloc] initWithIdentifier:kColumnValue];
    [tableview addTableColumn:column1];
    [tableview addTableColumn:column2];
    [tableview setDelegate:self];
    [tableview setDataSource:self];
    
    return tableview;
}



-(BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return NO;
}

-(BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    return NO;
}

-(BOOL) tableView:(NSTableView *)tableView shouldSelectTableColumn:(NSTableColumn *)tableColumn
{
    return NO;
}

-(BOOL) tabView:(NSTabView *)tableView shouldSelectTabViewItem:(NSTabViewItem*)tabViewItem
{
    return YES;
}

-(NSInteger) numberOfRowsInTableView:(NSTableView *)tableView
{
    if (tableView==songsView) {
        return [songsArray count];
    }
    else {
        return [baseInfoKeys count];;
    }
}


-(id) tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if (tableView == songsView) {
        if ([tableColumn.identifier isEqualToString:kColumnKey]) {
            return [NSString stringWithFormat:@"%ld",row+1];
        }
        else {
            return songsArray[row];
        }
    }
    else {
        if ([tableColumn.identifier isEqualToString:kColumnKey]) {
 
            return baseInfoKeys[row];

        }
        else {

            NSString* string = [baseInfoDict valueForKey:baseInfoKeys[row]];
            if (string == nil) {
                return  NSLocalizedString(@"DETAIL_UNKNOWN",@"未知");
            }
            else {
                return string;
            }
        }
    }
}


@end
