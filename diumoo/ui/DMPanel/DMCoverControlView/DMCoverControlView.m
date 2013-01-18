//
//  DMCoverControlView.m
//  diumoo-main-ui
//
//  Created by Shanzi on 12-5-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DMCoverControlView.h"

@implementation DMCoverControlView
@synthesize slide;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        mainLayer = [[CALayer alloc] init];
        
        mainLayer.frame = frame;
        mainLayer.masksToBounds = YES;
        
        slide = [[DMCoverSlide alloc] init];
        slide.anchorPoint = CGPointMake(0, 0);
        slide.position =slide.anchorPoint;
        
        [mainLayer addSublayer:slide];
        
        bitratelayer = [[DMBitrateControlLayer alloc] init];
        bitratelayer.position = CGPointMake(0, frame.size.height);
        
        [mainLayer addSublayer:bitratelayer];
        
        [self setWantsLayer:YES];
        [self setLayer:mainLayer];
        
        [self addTrackingRect:self.bounds
                        owner:self
                     userData:NULL assumeInside:NO];
        
    }
    
    return self;
}

-(BOOL) acceptsFirstResponder
{
    return YES;
}

-(void) mouseEntered:(NSEvent *)event
{
    [slide setOpacity:0.6];
    bitratelayer.position = CGPointMake(0, self.frame.size.height-30);
    
}

-(void) mouseExited:(NSEvent *)event
{
    [slide setOpacity:1.0];
    bitratelayer.position = CGPointMake(0, self.frame.size.height);
}

-(void) mouseDown:(NSEvent *)theEvent
{
    NSPoint location = [self convertPoint:[theEvent locationInWindow] fromView:self.window.contentView];
    
    if (![bitratelayer hitPostion:location]) {
        [NSApp sendAction:self.action to:self.target from:self];
    }

}


-(void) setPlayingInfo:(NSString *)musictitle :(NSString *)artist :(NSString *)albumTitle 
{
    [self.slide setTitle:musictitle artist:artist andAlbum:albumTitle];
    
}

-(void) setAlbumImage:(NSImage *)albumImage
{
    [self.slide setFrontCoverImage:albumImage];
}


@end
