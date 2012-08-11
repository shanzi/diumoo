//
//  SMBar.m
//  Drawings
//
//  Created by Stephan Michels on 12.02.12.
//  Copyright (c) 2012 Stephan Michels Softwareentwicklung und Beratung. All rights reserved.
//

#import "SMBar.h"

@implementation SMBar

#pragma mark - Drawing

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    // Draw bar gradient
    static NSGradient *gradient = nil;
    static NSColor *borderColor = nil;
    if (!gradient) {
        NSColor *color1 = [NSColor colorWithCalibratedRed:0.851 green:0.851 blue:0.851 alpha:1.];
        NSColor *color2 = [NSColor colorWithCalibratedRed:0.700 green:0.700 blue:0.700 alpha:1.];
        gradient = [[NSGradient alloc] initWithStartingColor:color1 
                                                             endingColor:color2];
        borderColor = [NSColor colorWithDeviceWhite:0.2 alpha:1.0f]; //[NSColor colorWithCalibratedRed:0.333 green:0.333 blue:0.333 alpha:1.];
    }
    
    [gradient drawInRect:self.bounds angle:90.0];
    
    // Draw drak gray bottom border
    [borderColor setStroke];
    [NSBezierPath setDefaultLineWidth:0.0f];
    [NSBezierPath strokeLineFromPoint:NSMakePoint(NSMinX(self.bounds), NSMaxY(self.bounds)) 
                              toPoint:NSMakePoint(NSMaxX(self.bounds), NSMaxY(self.bounds))];
}

- (BOOL)isFlipped {
    return YES;
}

@end
