//
//  DMCoverSlide.m
//  diumoo-main-ui
//
//  Created by Shanzi on 12-5-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DMCoverSlide.h"

@implementation DMCoverSlide
@synthesize frontCover;

-(id) init
{
    self = [super init];
    if (self) {
        self.bounds = BOUNDS;
        self.masksToBounds = YES;
        
        // init
        frontCover = [CALayer new];
        frontFadeTransitionLayer = [CALayer new];

        titleLayer = [CATextLayer new];
        artistLayer = [CATextLayer new];
        albumLayer = [CATextLayer new];
        
        // anchor
        CGPoint anchor = CGPointMake(0, 0);
        
        frontCover.anchorPoint = anchor;
        frontFadeTransitionLayer.anchorPoint = anchor;

        titleLayer.anchorPoint = anchor;
        artistLayer.anchorPoint = anchor;
        albumLayer.anchorPoint = anchor;
        
        // position
        frontCover.position = FRONT_POSITION;
        frontFadeTransitionLayer.position = anchor;

        titleLayer.position = TITLE_POSITION;
        artistLayer.position = ARTIST_POSITION;
        albumLayer.position = ALBUM_POSITION;
        
        // bounds
        frontCover.bounds = FRONT_BOUNDS;
        frontFadeTransitionLayer.bounds = FRONT_BOUNDS;
        titleLayer.bounds = TITLE_BOUNDS;
        artistLayer.bounds = ARTIST_BOUNDS;
        albumLayer.bounds = ALBUM_BOUNDS;
        
        
        // gravity
        frontCover.contentsGravity = kCAGravityResizeAspectFill;
        frontFadeTransitionLayer.contentsGravity = kCAGravityResizeAspectFill;
        
        frontCover.backgroundColor = CGColorCreateGenericGray(0.95, 1.0);
        
        // text
        CGFontRef helveticaConsensedBold = CGFontCreateWithFontName((__bridge CFStringRef)@"Helvetica Neue Condensed Bold");
        CGFontRef helveticaLight = CGFontCreateWithFontName((__bridge CFStringRef)@"Helvetica Neue Light");
        CGColorRef titleColor = CGColorCreateGenericRGB(0.2, 0.5, 1.0, 1.0);
        CGColorRef lighterColor = CGColorCreateGenericGray(0.2, 1.0);
        
        titleLayer.font = helveticaConsensedBold;
        artistLayer.font = helveticaLight;
        albumLayer.font = helveticaLight;
        
        titleLayer.fontSize = 18;
        artistLayer.fontSize = 13;
        albumLayer.fontSize = 13;
        
        titleLayer.foregroundColor = titleColor;
        artistLayer.foregroundColor = lighterColor;
        albumLayer.foregroundColor = lighterColor;
        
        titleLayer.truncationMode = kCATruncationEnd;
        artistLayer.truncationMode = kCATruncationEnd;
        albumLayer.truncationMode = kCATruncationEnd;
        
        CGFontRelease(helveticaConsensedBold);
        CGFontRelease(helveticaLight);
        
        
        // opacity
        frontFadeTransitionLayer.opacity = 0;

        // sublayer
        [frontCover setMasksToBounds:YES];
        [frontCover addSublayer:frontFadeTransitionLayer];
        [self addSublayer:frontCover];
        [self addSublayer:titleLayer];
        [self addSublayer:artistLayer];
        [self addSublayer:albumLayer];
    }
    return self;
}


-(void)setTitle:(NSString *)title artist:(NSString *)artist andAlbum :(NSString *)album
{  
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        titleLayer.string = title;
        artistLayer.string = artist;
        albumLayer.string = album;
        
        titleLayer.opacity = 1;
        artistLayer.opacity = 1;
        albumLayer.opacity = 1;
        
    }];
    titleLayer.opacity = 0;
    artistLayer.opacity = 0;
    albumLayer.opacity = 0;
    [CATransaction commit];

}

-(void) setFrontCoverImage:(NSImage *)image
{
    frontFadeTransitionLayer.contents = image;
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:1.0];
    [CATransaction setAnimationTimingFunction:
     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [CATransaction setCompletionBlock:^{
        [CATransaction begin];
        [CATransaction setAnimationDuration:0.0];
        frontCover.contents = image;
        frontFadeTransitionLayer.opacity = 0.0;
        [CATransaction commit];
    }];
    frontFadeTransitionLayer.opacity = 1.0;
    [CATransaction commit];
}


@end
