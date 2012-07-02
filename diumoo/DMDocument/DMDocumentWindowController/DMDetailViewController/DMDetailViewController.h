//
//  DMDetailViewController.h
//  documentTest
//
//  Created by Shanzi on 12-7-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JUInspectorViewContainer.h"

@interface DMDetailViewController : JUInspectorViewContainer <NSTableViewDelegate,NSTableViewDataSource>
{
    NSDictionary* baseInfoDict;
    NSArray* baseInfoKeys;
    NSArray* songsArray;
}

@property(nonatomic,retain) NSTableView* baseInformationView;
@property(nonatomic,retain) NSTextView* summaryView;
@property(nonatomic,retain) NSTableView* songsView;


-(id) initWithBaseInformation:(NSDictionary*) info summary:(NSString*) summary andSongs:(NSArray*)songs;

@end
