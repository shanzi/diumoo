//
//  DMVolumeSlideCell.m
//  diumoo
//
//  Created by Shanzi on 12-6-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DMVolumeSlideCell.h"

@implementation DMVolumeSlideCell

- (void)awakeFromNib
{
    backImage = [NSImage imageNamed:@"volume_back"];
    sliderImage = [NSImage imageNamed:@"volume_slider"];

    [backImage setFlipped:YES];
    [sliderImage setFlipped:YES];

    sliderRect = NSMakeRect(0, 0, 32, 21);
    sliderDrawingRect = NSMakeRect(0, 0, 32, 21);
    backFrame = NSMakeRect(0, 0, 250, 21);
}
- (NSRect)knobRectFlipped:(BOOL)flipped
{
    sliderDrawingRect.origin.x = (250 - 32 * 2 - 10) * [self floatValue] + 21;
    return sliderDrawingRect;
}

- (void)drawBarInside:(NSRect)aRect flipped:(BOOL)flipped
{
    [backImage drawInRect:backFrame
                 fromRect:backFrame
                operation:NSCompositeSourceOver
                 fraction:1.0];
}

- (void)drawKnob:(NSRect)knobRect
{
    CGFloat midX = NSMidX(knobRect);
    sliderDrawingRect.origin.x = midX - 16;
    [sliderImage drawInRect:knobRect
                   fromRect:sliderRect
                  operation:NSCompositeSourceOver
                   fraction:1.0];
}

@end
