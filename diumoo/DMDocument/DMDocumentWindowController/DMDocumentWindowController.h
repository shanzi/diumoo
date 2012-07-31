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
    
    IBOutlet SMTabBar *tabBar;
    IBOutlet NSTabView *tabView;
    
    // -------------------------预览标签页--------------------------
    IBOutlet EDStarRating *starRating;
    IBOutlet NSButton *revertButton;
    IBOutlet NSButton *albumCoverButton;
    IBOutlet NSTextField *songTitle;
    IBOutlet NSTextField *artist;
    
    // ------------------------详细信息标签页------------------------
    IBOutlet NSTextField *indicatorText;
    IBOutlet NSProgressIndicator *progressIndicator;
    
    // -----------------------其他---------------------------------
    NSString* albumTitle;
    NSString* aid;
    NSString* albumLocation;
    
    NSLock *lock;
}






-(id) init;

-(void)setupWindowForDocument:(NSDocument*) doc;

-(IBAction)revert:(id)sender;
-(IBAction)playAlbum:(id)sender;
-(IBAction)openAlbumLocation:(id)sender;
@end
