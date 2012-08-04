//
//  DMCoverSlide.h
//  diumoo-main-ui
//
//  Created by Shanzi on 12-5-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#define BOUNDS CGRectMake(0,0,250,330)
#define FRONT_BOUNDS CGRectMake(0,0,250,250)
#define TITLE_BOUNDS CGRectMake(0,0,230,30)
#define ARTIST_BOUNDS CGRectMake(0,0,230,20)
#define ALBUM_BOUNDS CGRectMake(0,0,230,20)

#import <QuartzCore/QuartzCore.h>

@interface DMCoverSlide : CALayer
{
    CGPoint frontPosition;
    CGPoint titlePosition;
    CGPoint artistPosition;
    CGPoint albumPosition;
    
    CALayer* frontCover;
    CALayer* frontFadeTransitionLayer;
    
    CATextLayer* titleLayer;
    CATextLayer* artistLayer;
    CATextLayer* albumLayer;
}
@property(assign,readonly) CALayer* frontCover;


-(void) setTitle:(NSString*) title artist:(NSString*)artist andAlbum:(NSString*) album;

-(void) setFrontCoverImage:(NSImage*) image;

@end
