//
//  DMCoverSlide.m
//  diumoo-main-ui
//
//  Created by Shanzi on 12-5-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DMCoverSlide.h"

@implementation DMCoverSlide
@synthesize frontCover,backCover;

-(id) init
{
    self = [super init];
    if (self) {
        self.bounds = BOUNDS;
        self.masksToBounds = YES;
        
        // init
        frontCover = [CALayer new];
        frontFadeTransitionLayer = [CALayer new];
        backCover = [CALayer new];
        backFadeTransitionLayer = [CALayer new];
        titleLayer = [CATextLayer new];
        artistLayer = [CATextLayer new];
        albumLayer = [CATextLayer new];
        
        // anchor
        CGPoint anchor = CGPointMake(0, 0);
        frontCover.anchorPoint = anchor;
        frontFadeTransitionLayer.anchorPoint = anchor;
        backCover.anchorPoint = CGPointMake(1.0,0.5);
        backFadeTransitionLayer.anchorPoint = anchor;
        titleLayer.anchorPoint = anchor;
        artistLayer.anchorPoint = anchor;
        albumLayer.anchorPoint = anchor;
        
        // position
        frontCover.position = FRONT_POSITION;
        frontFadeTransitionLayer.position = anchor;
        backCover.position = BACK_POSITION;
        backFadeTransitionLayer.position = anchor;
        titleLayer.position = TITLE_POSITION;
        artistLayer.position = ARTIST_POSITION;
        albumLayer.position = ALBUM_POSITION;
        
        // bounds
        frontCover.bounds = FRONT_BOUNDS;
        frontFadeTransitionLayer.bounds = frontCover.bounds;
        titleLayer.bounds = TITLE_BOUNDS;
        artistLayer.bounds = ARTIST_BOUNDS;
        albumLayer.bounds = ALBUM_BOUNDS;
        
        // shadow
        CGColorRef shadowColor = CGColorCreateGenericGray(0.0, 0.8);
        CGSize shadowOffset = CGSizeMake(0, 0);
        
        frontCover.shadowColor = shadowColor;
        frontCover.shadowOpacity = 0.4;
        frontCover.shadowRadius = 1.0;
        frontCover.shadowOffset = shadowOffset;
        
        backCover.shadowColor = shadowColor;
        backCover.shadowOpacity = 0.8;
        backCover.shadowRadius = 1.0;
        backCover.shadowOffset = shadowOffset;
        
        // border
        CGColorRef borderColor = CGColorCreateGenericGray(1.0, 0.8);
        frontCover.borderColor = borderColor;
        backCover.borderColor = borderColor;
        frontCover.borderWidth = 1.0;
        backCover.borderWidth = 2.0;
        
        // gravity
        frontCover.contentsGravity = kCAGravityResizeAspectFill;
        backCover.contentsGravity = kCAGravityResize;
        
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
        backFadeTransitionLayer.opacity = 0;
        backCover.opacity = 0;
        
        // sublayer
        [frontCover addSublayer:frontFadeTransitionLayer];
        [backCover addSublayer:backFadeTransitionLayer];
        [self addSublayer:frontCover];
        [self addSublayer:backCover];
        [self addSublayer:titleLayer];
        [self addSublayer:artistLayer];
        [self addSublayer:albumLayer];
    }
    return self;
}


-(void)setTitle:(NSString *)title artist:(NSString *)artist andAlbum :(NSString *)album
{
    titleLayer.string = title;
    artistLayer.string = artist;
    albumLayer.string = album;
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

-(void) setBackCoverImage:(NSImage *)image
{
    CGFloat imgwidth = image.size.width;
    CGFloat imgheight = image.size.height;
    
    CGFloat width = imgwidth * 100 / imgheight;
    CGRect backBounds = CGRectMake(0, 0, width, 100.0);
    
    backFadeTransitionLayer.contents = image;
    backFadeTransitionLayer.bounds = backBounds;
     backCover.bounds = backBounds;
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:1.0];
    [CATransaction setAnimationTimingFunction:
     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [CATransaction setCompletionBlock:^{
        [CATransaction begin];
        [CATransaction setAnimationDuration:0.0];
        backCover.contents = image;
        backFadeTransitionLayer.opacity = 0;
        [CATransaction commit];
    }];
   
    backFadeTransitionLayer.opacity = 1.0;
    [CATransaction commit];
    
    
}

@end
