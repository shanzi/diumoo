//
//  DMQuickHelpImageSlideView.m
//  diumoo
//
//  Created by Shanzi on 12-7-31.
//
//

#import "DMQuickStartImageSlideView.h"
#import <Quartz/Quartz.h>

@implementation DMQuickStartImageSlideView



- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        currentImageIndex = 0;
        rootLayer = [[[CALayer alloc] init] retain];
        rootLayer.frame = frame;
        rootLayer.anchorPoint = CGPointMake(0,0);
        rootLayer.position = rootLayer.anchorPoint;
        [self setWantsLayer:YES];
        [self setLayer:rootLayer];
    }
    
    return self;
}

-(void)dealloc
{
    [rootLayer release];
    [imageNamesQueue release];
    [super dealloc];
}

-(void)setImageNames:(NSArray *)array
{
    imageNamesQueue = [array retain];
    CALayer* firstLayer =[[CALayer alloc] init];

    firstLayer.frame = self.frame;
    firstLayer.anchorPoint = CGPointMake(0, 0);
    firstLayer.position = CGPointMake(0, 0);
    firstLayer.contents = [NSImage imageNamed:[imageNamesQueue objectAtIndex:currentImageIndex]];
    [rootLayer addSublayer:firstLayer];
}

-(BOOL)canBack
{
    return currentImageIndex > 0;
}

-(BOOL) canNext
{
    return (currentImageIndex+1) <[imageNamesQueue count];
}

-(void) next
{
    NSArray* array = [rootLayer sublayers];
    CALayer* nextLayer = nil;
    currentImageIndex+=1;
    

    
    if ([array count] > currentImageIndex) {
        nextLayer = [array objectAtIndex:currentImageIndex];
        
        [CATransaction begin];
        [CATransaction setAnimationDuration:1.0];
        nextLayer.position = CGPointMake(0, 0);
        [CATransaction commit];
        
    }
    else{
        nextLayer = [[CALayer alloc] init];
        nextLayer.frame = self.frame;
        nextLayer.anchorPoint = CGPointMake(0, 0);
        nextLayer.contents = [NSImage imageNamed:
                              [imageNamesQueue objectAtIndex:currentImageIndex]];
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        [CATransaction setCompletionBlock:^{
            
            [CATransaction begin];
            [CATransaction setAnimationDuration:1.0];
            nextLayer.position = CGPointMake(0, 0);
            [CATransaction commit];
            
        }];
        nextLayer.position = CGPointMake(self.frame.size.width, 0);
        [rootLayer addSublayer:nextLayer];
        [CATransaction commit];
    }

    
}

-(void) back
{
    NSArray* array = [rootLayer sublayers];
    CALayer* layer = [array objectAtIndex:currentImageIndex];
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:1.0];
    layer.position = CGPointMake(self.frame.size.width, 0);
    [CATransaction commit];
    currentImageIndex -= 1;
}

@end
