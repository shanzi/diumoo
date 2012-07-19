//
//  DMCoverSlide.h
//  diumoo-main-ui
//
//  Created by Shanzi on 12-5-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#define BOUNDS CGRectMake(0,0,250,330)
#define FRONT_POSITION CGPointMake(0,80)
#define BACK_POSITION CGPointMake(250,205)
#define TITLE_POSITION CGPointMake(10,40)
#define ARTIST_POSITION CGPointMake(11,25)
#define ALBUM_POSITION CGPointMake(11,10)
#define FRONT_BOUNDS CGRectMake(0,0,250,250)
#define TITLE_BOUNDS CGRectMake(0,0,230,30)
#define ARTIST_BOUNDS CGRectMake(0,0,230,20)
#define ALBUM_BOUNDS CGRectMake(0,0,230,20)

#import <QuartzCore/QuartzCore.h>

@interface DMCoverSlide : CALayer
{
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
