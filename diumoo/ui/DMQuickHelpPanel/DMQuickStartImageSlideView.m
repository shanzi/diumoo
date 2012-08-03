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
        viewLayer = [[[CALayer alloc] init] retain];
        viewLayer.frame = frame;
        
        rootLayer = [[[CALayer alloc] init] retain];
        rootLayer.frame = frame;
        rootLayer.anchorPoint = CGPointMake(0,0);
        rootLayer.position = rootLayer.anchorPoint;
        
        nextActionLayer = [[[CALayer alloc]init] retain];
        backActionLayer = [[[CALayer alloc]init] retain];
        nextActionLayer.frame = CGRectMake(0, 0, 48, 48);
        backActionLayer.frame = nextActionLayer.frame;
        
        backActionLayer.position = CGPointMake(34, 200);
        nextActionLayer.position = CGPointMake(560 - 34, 200);
        
        backActionLayer.zPosition = 1;
        nextActionLayer.zPosition = 1;
        
        backActionLayer.contents = [NSImage imageNamed:@"arrowleft"];
        nextActionLayer.contents = [NSImage imageNamed:@"arrowright"];
        
        backActionLayer.opacity = 0.4;
        nextActionLayer.opacity = 0.8;
        
        [viewLayer addSublayer:rootLayer];
        [viewLayer addSublayer:backActionLayer];
        [viewLayer addSublayer:nextActionLayer];
        
        [self setWantsLayer:YES];
        [self setLayer:viewLayer];
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
    firstLayer.contents = [NSImage imageNamed:imageNamesQueue[currentImageIndex]];
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
        nextLayer = array[currentImageIndex];
        
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
                              imageNamesQueue[currentImageIndex]];
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
    CALayer* layer = array[currentImageIndex];
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:1.0];
    layer.position = CGPointMake(self.frame.size.width, 0);
    [CATransaction commit];
    currentImageIndex -= 1;
}

-(void) mouseDown:(NSEvent *)theEvent
{
    NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    CALayer* hitted = [viewLayer hitTest:point];
    if( hitted == backActionLayer){
        if ([self canBack]) {
            [self back];
        }
    }
    else if(hitted == nextActionLayer){
        if ([self canNext]) {
            [self next];
        }
        else{
            [deleate performSelector:@selector(close)];
        }
    }
    
    if ([self canBack]) {
        backActionLayer.opacity = 0.8;
    }
    else
    {
        backActionLayer.opacity = 0.4;
    }
}

@end
