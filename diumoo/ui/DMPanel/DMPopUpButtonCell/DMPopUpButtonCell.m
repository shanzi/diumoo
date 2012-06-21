//
//  DMPopUpButtonCell.m
//  DMSubclassNSCellTest
//
//  Created by Shanzi on 12-6-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DMPopUpButtonCell.h"

#define HIGH_LIGHT_ATTRIBUTE [NSDictionary dictionaryWithObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName]

@implementation DMPopUpButtonCell

-(void) dealloc
{
    [stringAttribute release];
    [stringHighligtAttribute release];
    [super dealloc];
}

-(void) drawTitleWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    NSString* label = self.title;
    NSAttributedString* string = [[NSAttributedString alloc] initWithString:label
                                                                 attributes:[self stringAttribute]];
    NSSize stringSize = string.size;
    NSRect stringRect = NSMakeRect(cellFrame.origin.x + 10,
                                   NSMidY(cellFrame) - stringSize.height/2, 
                                   cellFrame.size.width - 40, stringSize.height);
    [string drawInRect:stringRect];
    
}

-(NSDictionary*) stringAttribute
{
    if ([self isHighlighted]) {
        if (stringHighligtAttribute) {
            return stringHighligtAttribute;
        }
        else {
            NSMutableParagraphStyle* ps = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
            [ps setLineBreakMode:NSLineBreakByTruncatingTail];
            
            stringHighligtAttribute = [[NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSColor selectedMenuItemTextColor],NSForegroundColorAttributeName,
                                        ps, NSParagraphStyleAttributeName,
                                       self.font,NSFontAttributeName,
                                       nil] retain];
            return stringHighligtAttribute;
        }
    }
    else {
        if (stringAttribute) {
            return stringAttribute;
        }
        else {
            NSMutableParagraphStyle* ps = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
            [ps setLineBreakMode:NSLineBreakByTruncatingTail];
            
            stringAttribute = [[NSDictionary dictionaryWithObjectsAndKeys:
                                [NSColor blackColor],NSForegroundColorAttributeName,
                                ps, NSParagraphStyleAttributeName,
                                self.font,NSFontAttributeName,
                                nil] retain];
            return stringAttribute;
        }
    }
}

-(void) drawBorderAndBackgroundWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    NSBezierPath* rect = [NSBezierPath bezierPathWithRect:cellFrame];
    [rect setLineWidth:1.0];
    [[NSColor colorWithGenericGamma22White:0.6 alpha:1.0] setStroke];
    
    NSBezierPath* tri = [[NSBezierPath alloc] init];
    [tri moveToPoint:NSMakePoint(cellFrame.size.width - 20, NSMidY(cellFrame) - 5)];
    [tri lineToPoint:NSMakePoint(cellFrame.size.width - 20, NSMidY(cellFrame) + 5)];
    [tri lineToPoint:NSMakePoint(cellFrame.size.width + 5*sqrt(3) - 20, NSMidY(cellFrame))];
    [tri closePath];
    
    if([self isHighlighted])
    {
        [[NSColor selectedMenuItemColor] setFill];
        [rect fill];
        [rect stroke];
        
        [[NSColor whiteColor]setFill];
        [tri fill];
    }
        
    else 
    {
        [[NSColor whiteColor] setFill];
        [rect fill];
        [rect stroke];
        [tri stroke];
    }

}

-(void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    [self drawBorderAndBackgroundWithFrame:cellFrame inView:controlView];
    [self drawTitleWithFrame:cellFrame inView:controlView];
}


@end
