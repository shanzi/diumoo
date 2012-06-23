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
//        CGRect bounds = CGRectMake(0, 0, frame.size.width, frame.size.height);
        
        slide = [DMCoverSlide new];
        slide.anchorPoint = CGPointMake(0, 0);
        slide.position =slide.anchorPoint;
        
        
        [self setWantsLayer:YES];
        [self setLayer:slide];
        
        //[self addTrackingRect:bounds owner:self userData:NULL assumeInside:NO];
    }
    
    return self;
}

-(BOOL) acceptsFirstResponder
{
    return YES;
}

-(void) mouseEntered:(NSEvent *)event
{

    
}

-(void) mouseExited:(NSEvent *)event
{

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
