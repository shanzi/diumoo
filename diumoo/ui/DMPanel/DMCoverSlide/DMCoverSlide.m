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
    
    if (self = [super init]) {
        SInt32 major,minor;
        Gestalt(gestaltSystemVersionMajor, &major);
        Gestalt(gestaltSystemVersionMinor,&minor);
        if (major == 10 && minor < 8) {
            frontPosition = CGPointMake(0,80);
            titlePosition = CGPointMake(10,40);
            artistPosition = CGPointMake(13,25);
            albumPosition = CGPointMake(13,10);
        }
        else {
            frontPosition = CGPointMake(0,0);
            titlePosition = CGPointMake(10,260);
            artistPosition = CGPointMake(13,280);
            albumPosition = CGPointMake(13,295);
        }
        self.bounds = BOUNDS;
        self.masksToBounds = YES;
        
        // init
        frontCover = [[CALayer alloc] init];
        frontFadeTransitionLayer = [[CALayer alloc] init];

        titleLayer = [[CATextLayer alloc] init];
        artistLayer = [[CATextLayer alloc] init];
        albumLayer = [[CATextLayer alloc] init];
        
        // anchor
        CGPoint anchor = CGPointMake(0, 0);
        
        frontCover.anchorPoint = anchor;
        frontFadeTransitionLayer.anchorPoint = anchor;

        titleLayer.anchorPoint = anchor;
        artistLayer.anchorPoint = anchor;
        albumLayer.anchorPoint = anchor;
        
        // position
        frontCover.position = frontPosition;
        frontFadeTransitionLayer.position = anchor;

        titleLayer.position = titlePosition;
        artistLayer.position = artistPosition;
        albumLayer.position = albumPosition;
        
        // bounds
        frontCover.bounds = FRONT_BOUNDS;
        frontFadeTransitionLayer.bounds = FRONT_BOUNDS;
        titleLayer.bounds = TITLE_BOUNDS;
        artistLayer.bounds = ARTIST_BOUNDS;
        albumLayer.bounds = ALBUM_BOUNDS;
        
        
        // gravity
        frontCover.contentsGravity = kCAGravityResizeAspectFill;
        frontFadeTransitionLayer.contentsGravity = kCAGravityResizeAspectFill;
        
        // text
        CGFontRef helveticaConsensedBold = CGFontCreateWithFontName(( CFStringRef)@"Helvetica Neue Condensed Bold");
        CGFontRef helveticaLight = CGFontCreateWithFontName((CFStringRef)@"Helvetica Neue Light");
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
        CGColorRelease(titleColor);
        CGColorRelease(lighterColor);

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
