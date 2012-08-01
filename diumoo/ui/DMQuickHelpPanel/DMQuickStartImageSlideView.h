//
//  DMQuickHelpImageSlideView.h
//  diumoo
//
//  Created by Shanzi on 12-7-31.
//
//

#import <Cocoa/Cocoa.h>

@interface DMQuickStartImageSlideView : NSView
{
    CALayer* rootLayer;
    NSArray* imageNamesQueue;
    NSInteger currentImageIndex;
}

-(void) setImageNames:(NSArray*)array;
-(BOOL) canBack;
-(BOOL) canNext;
-(void) back;
-(void) next;


@end
