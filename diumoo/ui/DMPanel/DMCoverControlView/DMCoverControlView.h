//
//  DMCoverControlView.h
//  diumoo-main-ui
//
//  Created by Shanzi on 12-5-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DMCoverSlide.h"
#import "DMVolumeControlLayer.h"

@interface DMCoverControlView : NSView
{
    DMCoverSlide* slide;
    DMVolumeControlLayer* volumeControl;
    
    CALayer* rootLayer;
}
@property(assign,readonly)DMCoverSlide* slide;
@property(assign,readonly)DMVolumeControlLayer* volumeControl;

@end
