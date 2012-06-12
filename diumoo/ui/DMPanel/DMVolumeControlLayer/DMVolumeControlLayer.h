//
//  DMVolumeControlLayer.h
//  diumoo-main-ui
//
//  Created by Shanzi on 12-5-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#define VOLUME_LAYER_BOUNDS CGRectMake(0,0,250,20)

#import <QuartzCore/QuartzCore.h>


@interface DMVolumeControlLayer : CALayer
{
    CALayer* volumeFrontBar;
    
    float volume;
}

@property float volume;
@property(assign) CALayer* volumeFrontBar;


-(id) initWithVolume:(float) volume;
-(void) commit;

@end
