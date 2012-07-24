//
//  DMVolumeSlideCell.m
//  diumoo
//
//  Created by Shanzi on 12-6-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DMVolumeSlideCell.h"

@implementation DMVolumeSlideCell


-(void) drawBarInside:(NSRect)aRect flipped:(BOOL)flipped
{
    NSBezierPath* bar = [NSBezierPath bezierPathWithRect:aRect];
    [[NSColor colorWithGenericGamma22White:0.9 alpha:1.0] setFill];
    [bar fill];
}

-(void) drawKnob:(NSRect)knobRect
{
    CGFloat midY = NSMidY(knobRect);
    CGFloat maxX = knobRect.origin.x + knobRect.size.width;
    
    NSRect knobR = NSMakeRect(0, 0, maxX, knobRect.size.height);
    
    NSBezierPath* knob = [NSBezierPath bezierPathWithRect:knobR];
    
    
    NSColor* color = [NSColor colorWithSRGBRed:0.4 green:0.8 blue:1.0 alpha:0.8];
    [color setFill];
    [knob fill];
    
    
   
    
    // 绘制声音图像
    double rate = (self.floatValue - self.minValue)/self.maxValue;
    NSImage* image =nil;
    if (rate > 0.6) {
        image = [NSImage imageNamed:@"sound_high"];
    }
    else if(rate > 0.1)
    {
        image = [NSImage imageNamed:@"sound_low"];
    }
    else {
        image = [NSImage imageNamed:@"sound_mute"];
    }
    
    NSRect fromRect = NSMakeRect(0, 0, image.size.width, image.size.height);
    NSRect toRect = NSMakeRect(5 , midY-8,
                               16, 16);
    [image drawInRect:toRect
             fromRect: fromRect
            operation:NSCompositeSourceOver
             fraction:1.0];
}

@end
