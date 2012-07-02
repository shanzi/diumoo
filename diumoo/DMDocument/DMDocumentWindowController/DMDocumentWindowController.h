//
//  DMDocumentWindowController.h
//  documentTest
//
//  Created by Shanzi on 12-7-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class SMTabBar;
@class EDStarRating;

@interface DMDocumentWindowController : NSWindowController <NSWindowDelegate>



@property(nonatomic,retain) IBOutlet SMTabBar *tabBar;
@property(nonatomic,retain)IBOutlet NSTabView * tabView;

// -------------------------预览标签页--------------------------
@property(nonatomic,retain) IBOutlet EDStarRating* starRating;
@property(nonatomic,retain) IBOutlet NSButton* revertButton;
@property(nonatomic,retain) IBOutlet NSButton* albumCoverButton;
@property(nonatomic,retain) IBOutlet NSTextField* songTitle;
@property(nonatomic,retain) IBOutlet NSTextField* artist;

// ------------------------详细信息标签页------------------------
@property(nonatomic,retain) IBOutlet NSTextField* indicatorText;
@property(nonatomic,retain) IBOutlet NSProgressIndicator* progressIndicator;


// --------------------------其他------------------------------
@property(copy) NSString* albumTitle;
@property(nonatomic,assign) NSLock* lock;

-(id) init;

-(void)setupWindowForDocument;
-(void)updateDocumentContent;

-(IBAction)revert:(id)sender;
@end
