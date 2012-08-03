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
    CALayer* viewLayer;
    CALayer* rootLayer;
    CALayer* backActionLayer;
    CALayer* nextActionLayer;
    NSArray* imageNamesQueue;
    NSInteger currentImageIndex;
    
    IBOutlet id deleate;
}

-(void) setImageNames:(NSArray*)array;
-(BOOL) canBack;
-(BOOL) canNext;
-(void) back;
-(void) next;


@end
