//
//  PLTabPreferenceControl.h
//  PLTabPreferencePanel
//
//  Created by xhan on 3/23/11.
//  Copyright 2011 Baidu.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol PLTabPreferenceDelegate;

@interface PLTabPreferenceControl : NSWindowController<NSToolbarDelegate> 
{
    @private
    NSToolbar *toolbar;
    NSArray* prefIdentifyAry;
    id<PLTabPreferenceDelegate> delegate;
}

@property(nonatomic,assign) IBOutlet id<PLTabPreferenceDelegate> delegate;

- (void)selectPanelAtIndex:(int)index;


@end


@protocol PLTabPreferenceDelegate <NSObject>

@required

- (int)countOfPreferencePanels;
- (NSString*)titleForPreferencePanelAt:(int)index;
- (NSImage*)imageForPreferencePanelAt:(int)index;
- (NSView*)panelViewForPreferencePanelAt:(int)index;

@optional
- (NSString*)identifyForPreferencePanelAt:(int)index;
- (void)prefViewWillAppear:(NSView*)view atIndex:(NSInteger)index;
- (void)prefViewDidAppear:(NSView*)view atIndex:(NSInteger)index;
@end