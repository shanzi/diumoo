//
//  DMSearchPanelControllerWindowController.m
//  diumoo
//
//  Created by Shanzi on 12-10-9.
//
//

#import "DMSearchPanelController.h"
#import "DMPlayRecordHandler.h"
#import "DMSearchItemView.h"

static DMSearchPanelController* sharedSearchPanel;

@interface DMSearchPanelController ()
{
    IBOutlet DMSearchCollectionView* collectionview;
    IBOutlet NSArrayController* arrayController;
}
@end

@implementation DMSearchPanelController
@synthesize sortDescriptors=_sortDescriptors;



- (id)init
{
    self = [super initWithWindowNibName:@"DMSearchPanelController"];
    if (self) {
        _sortDescriptors = @[
        [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]
        ];
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self.window setLevel: NSModalPanelWindowLevel];
}

+(DMSearchPanelController*) sharedSearchPanel
{
    if(sharedSearchPanel) return sharedSearchPanel;
    else{
        sharedSearchPanel = [[DMSearchPanelController alloc] init];
        return sharedSearchPanel;
    }
}

+(void) rearrage
{
    if (sharedSearchPanel) {
        [sharedSearchPanel rearrageObjects];
    }
}

-(NSManagedObjectContext*) contextObject
{
    return [DMPlayRecordHandler sharedRecordHandler].context;
}

-(void) rearrageObjects
{
    if(self.window.isVisible)[arrayController rearrangeObjects];
}

@end
