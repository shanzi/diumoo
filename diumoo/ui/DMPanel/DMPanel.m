//
//  DMPanel.m
//  diumoo
//
//  Created by Anakin Zheng on 12-8-14.
//
//

#import "DMPanel.h"
#import "DMPanelWindowController.h"

@implementation DMPanel

- (BOOL)canBecomeKeyWindow;
{
    return YES; // Allow Search field to become the first responder
}

- (void)scrollWheel:(NSEvent*)theEvent
{
    [self.delegate performSelector:@selector(mouseScroll:)
                        withObject:theEvent];
}

@end
