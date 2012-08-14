//
//  DMPanel.m
//  diumoo
//
//  Created by AnakinGWY on 12-8-14.
//
//

#import "DMPanel.h"

@implementation DMPanel

- (BOOL)canBecomeKeyWindow;
{
    return YES; // Allow Search field to become the first responder
}

@end
