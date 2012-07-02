//
//  JUInspectorBaseView.m
//  JUInspectorView
//
//  Created by Jon Gilkison on 9/28/11.
//  Copyright 2011 Interfacelab LLC. All rights reserved.
//

#import "JUInspectorBaseView.h"


@implementation JUInspectorBaseView

#pragma mark - Init/Dealloc

- (id)initWithFrame:(NSRect)frame
{
    if((self = [super initWithFrame:frame]))
    {
        [self setupView];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if((self = [super initWithCoder:decoder]))
    {
        [self setupView];
    }
    
    return self;
}

- (void)setupView
{
}

@end
