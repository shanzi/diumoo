//
//  DMVolumeControlLayer.m
//  diumoo-main-ui
//
//  Created by Shanzi on 12-5-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DMVolumeControlLayer.h"

@implementation DMVolumeControlLayer
@synthesize volume,volumeFrontBar;


-(id) initWithVolume:(float) vo;
{
    self = [super init];
    if (self) {
        
        self.bounds = VOLUME_LAYER_BOUNDS;
        self.masksToBounds = YES;
        self.contents = [NSImage imageNamed:@"volumeback.png"];
        self.backgroundColor = CGColorCreateGenericGray(0.8, 0.5);
        
        self.volumeFrontBar = [CALayer new];
        volumeFrontBar.anchorPoint =CGPointMake(0, 0);
        volumeFrontBar.bounds = self.bounds;
        volumeFrontBar.backgroundColor = CGColorCreateGenericRGB(0.1, 0.5, 1.0, 0.4);
        
        self.volume = vo;
        [self commit];
        
        [self addSublayer:volumeFrontBar];
        
    }
    return self;
}

-(void) commit{
    if(volume>1.0) volume = 1.0;
    if(volume<0.0) volume = 0.0;
    
    CGFloat left = self.bounds.size.width*(volume-1);
    volumeFrontBar.position = CGPointMake(left,0);
}

-(CALayer*) hitTest:(CGPoint)point
{
    
    CGPoint p = [self convertPoint:point fromLayer:nil];
    if(p.x > 0 && p.y>0 &&
       p.x < self.bounds.size.width && p.y < self.bounds.size.height)
        return self;
    else return nil;
}

@end
