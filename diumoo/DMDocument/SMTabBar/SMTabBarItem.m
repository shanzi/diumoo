//
//  SMTabBarItem.m
//  InspectorTabBar
//
//  Created by Stephan Michels on 03.02.12.
//  Copyright (c) 2012 Stephan Michels Softwareentwicklung und Beratung. All rights reserved.
//

#import "SMTabBarItem.h"

@implementation SMTabBarItem

@synthesize enabled = _enabled;
@synthesize image = _image;
@synthesize toolTip = _toolTip;
@synthesize keyEquivalent = _keyEquivalent;
@synthesize keyEquivalentModifierMask = _keyEquivalentModifierMask;
@synthesize tag = _tag;

- (id)initWithImage:(NSImage *)image tag:(NSInteger)tag {
    self = [super init];
    if (self) {
        self.image = image;
        self.tag = tag;
        self.enabled = YES;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"SMTabBarItem{tag=%i}", self.tag];
}

@end
