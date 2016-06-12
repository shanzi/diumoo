//
//  DMControlButtonCell.m
//  diumoo
//
//  Created by AnakinGWY on 12-8-15.
//
//

#import "DMButton.h"

@implementation DMButton

- (id)init
{
    if (self = [super init]) {
    }
    return self;
}

- (void)awakeFromNib
{
    [[self window] setAcceptsMouseMovedEvents:YES];
    [super awakeFromNib];
}

- (void)mouseEntered:(NSEvent*)theEvent
{
    if ([self isEnabled]) {
        NSString* name = [[self image] name];
        NSImage* mouseoverImage = [NSImage imageNamed:[name stringByAppendingString:@"_mouseover"]];
        if (mouseoverImage != nil) {
            [self setImage:mouseoverImage];
        }
    }
}
- (void)mouseExited:(NSEvent*)theEvent
{
    if ([self isEnabled]) {
        NSString* name = [[self image] name];
        NSImage* normalImage = [NSImage imageNamed:[name stringByReplacingOccurrencesOfString:@"_mouseover" withString:@""]];
        if (normalImage != nil) {
            [self setImage:normalImage];
        }
    }
}

- (void)updateTrackingAreas
{
    [self removeTrackingArea:trackingArea];

    NSTrackingAreaOptions options = NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow;
    trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds] options:options owner:self userInfo:nil];

    [self addTrackingArea:trackingArea];

    [super updateTrackingAreas];
}

@end
