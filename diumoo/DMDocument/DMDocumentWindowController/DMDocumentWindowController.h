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
{
    
}

@property(nonatomic,assign) IBOutlet SMTabBar *tabBar;
@property(nonatomic,assign) IBOutlet NSTabView *tabView;

// -------------------------预览标签页--------------------------
@property(nonatomic,assign) IBOutlet EDStarRating *starRating;
@property(nonatomic,assign) IBOutlet NSButton *revertButton;
@property(nonatomic,assign) IBOutlet NSButton *albumCoverButton;
@property(nonatomic,assign) IBOutlet NSTextField *songTitle;
@property(nonatomic,assign) IBOutlet NSTextField *artist;

// ------------------------详细信息标签页------------------------
@property(nonatomic,assign) IBOutlet NSTextField *indicatorText;
@property(nonatomic,assign) IBOutlet NSProgressIndicator *progressIndicator;


// --------------------------其他------------------------------
@property(copy) NSString *albumTitle;
@property(nonatomic,assign) NSLock *lock;

-(id) init;

-(void)setupWindowForDocument:(NSDocument*) doc;

-(IBAction)revert:(id)sender;
@end
