//
//  DMSearchPanelControllerWindowController.m
//  diumoo
//
//  Created by Shanzi on 12-10-9.
//
//

#import "DMPlayRecordHandler.h"
#import "DMSearchItemView.h"
#import "DMSearchPanelController.h"

static DMSearchPanelController* sharedSearchPanel;

@interface DMSearchPanelController () {
    IBOutlet DMSearchCollectionView* collectionview;
    IBOutlet NSArrayController* arrayController;
}
@end

@implementation DMSearchPanelController

- (id)init
{
    self = [super initWithWindowNibName:@"DMSearchPanelController"];
    if (self) {
    }

    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self.window setLevel:NSModalPanelWindowLevel];
    [arrayController setValue:@[
        [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]
    ]
                       forKey:@"sortDescriptors"];
}

+ (DMSearchPanelController*)sharedSearchPanel
{
    if (sharedSearchPanel)
        return sharedSearchPanel;
    else {
        sharedSearchPanel = [[DMSearchPanelController alloc] init];
        return sharedSearchPanel;
    }
}

- (NSManagedObjectContext*)contextObject
{
    return [DMPlayRecordHandler sharedRecordHandler].context;
}

@end
