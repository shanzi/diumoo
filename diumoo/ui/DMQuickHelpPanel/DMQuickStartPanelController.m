//
//  DMQuickHelpPanelController.m
//  diumoo
//
//  Created by Shanzi on 12-7-31.
//
//

#import "DMQuickStartPanelController.h"
#import "DMQuickStartImageSlideView.h"


@interface DMQuickStartPanelController ()

@end

@implementation DMQuickStartPanelController

+(void) showPanel
{
    NSUserDefaults* values = [NSUserDefaults standardUserDefaults];
    NSInteger version = [[values valueForKey:@"quickStartVersion"]integerValue];
    
    if (version < CURRENT_QUICKSTART_VERSION) {
        DMQuickStartPanelController* quickstart = nil;
        quickstart = [[DMQuickStartPanelController alloc] init];
        [quickstart showWindow:nil];
        [quickstart autorelease];
    }
    
}

- (id)init
{
    self = [super initWithWindowNibName:@"DMQuickStartPanel"];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void) awakeFromNib
{
    NSArray* imageNames = nil;
    imageNames = [NSArray arrayWithObjects:
                  @"slide1",
                  @"slide2",
                  @"slide3",
                  @"slide4",
                  nil];
    [slideView setImageNames:imageNames];
    [backButton setEnabled:[slideView canBack]];
    if (![slideView canNext]) {
        [nextButton setTitle:@"完成"];
    }
}

-(void) navigation:(id)sender
{
    if (sender == nextButton) {
        if([slideView canNext]) {
            [slideView next];
            if (![slideView canNext]) {
                [nextButton setTitle:@"完成"];
            }
        }
        else{
            id values = [[NSUserDefaultsController sharedUserDefaultsController] values];
            [values setValue:[NSNumber numberWithInteger:CURRENT_QUICKSTART_VERSION]
                      forKey:@"quickStartVersion"];
            [self close];
        }
            
    }
    else{
        if ([slideView canBack])
            [slideView back];
        if ([slideView canNext]) {
            [nextButton setTitle:@"下一步"];
        }
    }
    
    [backButton setEnabled:[slideView canBack]];
}

@end
