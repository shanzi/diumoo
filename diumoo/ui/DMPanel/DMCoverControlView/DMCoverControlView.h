//
//  DMCoverControlView.h
//  diumoo-main-ui
//
//  Created by Shanzi on 12-5-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DMCoverSlide.h"
#import "DMBitrateControlLayer.h"

@interface DMCoverControlView : NSButton
{
    CALayer* mainLayer;
    DMCoverSlide* slide;
    DMBitrateControlLayer* bitratelayer;
}
@property(readonly)DMCoverSlide* slide;

-(void) setPlayingInfo:(NSString*) musictitle 
                      :(NSString*) artist 
                      :(NSString*) albumTitle ;
                    
-(void) setAlbumImage:(NSImage*) albumImage;

@end
