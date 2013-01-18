//
//  DMBitrateControlLayer.h
//  DMBitrateSelectLayer
//
//  Created by Shanzi on 13-1-18.
//  Copyright (c) 2013年 Shanzi. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface DMBitrateControlLayer : CALayer
{
    NSArray* LayerArray;
    CGColorRef black;
    CGColorRef focus;
}

-(BOOL) hitPostion:(NSPoint) point;

@end
