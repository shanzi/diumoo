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

@property(nonatomic,strong) NSTableView* baseInformationView;
@property(nonatomic,strong) NSTextView* summaryView;
@property(nonatomic,strong) NSTableView* songsView;


-(id) initWithBaseInformation:(NSDictionary*) info summary:(NSString*) summary andSongs:(NSArray*)songs;

@end
