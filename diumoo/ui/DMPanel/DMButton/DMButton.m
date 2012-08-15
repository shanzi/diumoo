//
//  DMControlButtonCell.m
//  diumoo
//
//  Created by AnakinGWY on 12-8-15.
//
//

#import "DMButton.h"

@implementation DMButton

- (id) init
{
    if (self = [super init]) {
    }
    return  self;
}

- (void)awakeFromNib
{
    [[self window] setAcceptsMouseMovedEvents: YES];
    [super awakeFromNib];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    [self highlight:YES];
}
- (void)mouseExited:(NSEvent *)theEvent
{
    [self highlight:NO];
}

- (void)updateTrackingAreas
{
    [self removeTrackingArea:trackingArea];
    
    NSTrackingAreaOptions options = NSTrackingMouseEnteredAndExited|NSTrackingActiveInKeyWindow;
    trackingArea  = [[NSTrackingArea alloc] initWithRect:[self bounds] options:options owner:self userInfo:nil];
    
    [self addTrackingArea:trackingArea];
    
    [super updateTrackingAreas];
}


@end
