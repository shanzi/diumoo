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

+(PLTabPreferenceControl*) sharedPreferenceController;
+(void) showPrefsAtIndex:(NSInteger) index;

- (void)selectPanelAtIndex:(NSInteger)index;

@end


@protocol PLTabPreferenceDelegate <NSObject>

@required

- (int)countOfPreferencePanels;
- (NSString*)titleForPreferencePanelAt:(NSInteger)index;
- (NSImage*)imageForPreferencePanelAt:(NSInteger)index;
- (NSView*)panelViewForPreferencePanelAt:(NSInteger)index;

@optional
- (NSString*)identifyForPreferencePanelAt:(NSInteger)index;
- (void)prefViewWillAppear:(NSView*)view atIndex:(NSInteger)index;
- (void)prefViewDidAppear:(NSView*)view atIndex:(NSInteger)index;
@end