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
        
        baseInfoKeys = [[NSArray arrayWithObjects:
                        @"专辑名",
                        @"艺术家",
                        @"豆瓣评分",
                        @"版本特性",
                        @"出版者",
                        @"发行时间",
                        @"介质",
                        @"唱片数",
                        @"条形码",nil]
                        retain];
        
        self.baseInformationView = [self buildTableView];
        self.songsView = [self buildTableView];
        
        self.summaryView = [[NSTextView alloc]
                            initWithFrame:NSMakeRect(0, 0, 400, 400)];
        [summaryView setEditable:NO];
        [summaryView setAutoresizingMask:NSViewWidthSizable];
        self.summaryView.string = summary;
        
        
        baseInfoDict = [info retain];
        songsArray = [songs retain];
        
        JUInspectorView* infoInspector = [[JUInspectorView alloc] init];
        infoInspector.name = @"专辑信息";
        infoInspector.body = baseInformationView;
        
        JUInspectorView* summaryInspector = [[JUInspectorView alloc] init];
        NSScrollView* scrollView = [[NSScrollView alloc]
                                    initWithFrame:NSMakeRect(0, 0, 400, 300)];
        
        [scrollView setDocumentView:summaryView];
        [scrollView setHasVerticalScroller:YES];
        [scrollView setAutohidesScrollers:YES];
        
        summaryInspector.name = @"简介";
        summaryInspector.body = scrollView;
        
        JUInspectorView* songsInspector = [[JUInspectorView alloc] init];
        songsInspector.name = @"曲目";
        songsInspector.body = songsView;
        
        [self addInspectorView:infoInspector expanded:YES];
        [self addInspectorView:summaryInspector expanded:NO];
        [self addInspectorView:songsInspector expanded:YES];
        
        [infoInspector release];
        [summaryInspector release];
        [songsInspector release];
        [scrollView release];
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
    
    [column1 release];
    [column2 release];
    return [tableview autorelease];
}


-(void) dealloc
{

    [baseInformationView release];
    [summaryView release];
    [songsView release];
    
    [baseInfoDict release];
    [songsArray release];
    [baseInfoKeys release];
    
    [super dealloc];
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
            return [NSString stringWithFormat:@"%d",row+1];
        }
        else {
            return [songsArray objectAtIndex:row];
        }
    }
    else {
        if ([tableColumn.identifier isEqualToString:kColumnKey]) {
 
            return [baseInfoKeys objectAtIndex:row];

        }
        else {

            NSString* string = [baseInfoDict valueForKey:[baseInfoKeys objectAtIndex:row]];
            if (string == nil) {
                return  @"未知";
            }
            else {
                return string;
            }
        }
    }
}


@end
