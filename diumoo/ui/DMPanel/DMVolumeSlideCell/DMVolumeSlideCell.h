//
//  DMVolumeSlideCell.h
//  diumoo
//
//  Created by Shanzi on 12-6-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DMVolumeSlideCell : NSSliderCell {
    NSImage* backImage;
    NSImage* sliderImage;
    NSRect sliderRect;
    NSRect sliderDrawingRect;
    NSRect backFrame;
}

@end
