//
//  DMSearchPanelControllerWindowController.m
//  diumoo
//
//  Created by Shanzi on 12-10-9.
//
//

#import "DMSearchPanelController.h"
#import "DMPlayRecordHandler.h"

static DMSearchPanelController* sharedSearchPanel;

@interface DMSearchPanelController ()
{
    IBOutlet NSCollectionView* collectionview;
    NSFetchRequest* sharedSearchRequest;
    NSOperationQueue* searchQueue;
    int searchsig;
}
@end

@implementation DMSearchPanelController

- (id)init
{
    self = [super initWithWindowNibName:@"DMSearchPanelController"];
    if (self) {
        searchQueue = [[NSOperationQueue alloc] init];
        sharedSearchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Song"];
        [sharedSearchRequest setFetchLimit:25];
        [sharedSearchRequest setSortDescriptors:
         @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]
         ];
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self.window setLevel: NSModalPanelWindowLevel];
    [self search:nil];
}

+(DMSearchPanelController*) sharedSearchPanel
{
    if(sharedSearchPanel) return sharedSearchPanel;
    else{
        sharedSearchPanel = [[DMSearchPanelController alloc] init];
        return sharedSearchPanel;
    }
}


-(IBAction)search:(id)sender
{

    __block NSManagedObjectContext* context = [DMPlayRecordHandler sharedRecordHandler].context;
    if(OSAtomicCompareAndSwapInt(0, 1, &searchsig)){
        [searchQueue addOperationWithBlock:^{
            NSString* string = [sender stringValue];
            
            DMLog(@"search string before: %@",string);
            if([string length]){
                NSPredicate* predicate = [NSPredicate predicateWithFormat:
                                          @"(title contains[c] %@) OR (albumtitle contains[c] %@) OR (artist contains[c] %@)",string,string,string];
                [sharedSearchRequest setPredicate:predicate];
                self.window.title = @"搜索结果";
            }
            else{
                [sharedSearchRequest setPredicate:nil];
                self.window.title = @"最近播放";
            }
            
            NSError* error =nil;
            NSArray* array = [context executeFetchRequest:sharedSearchRequest
                                                    error:&error];
            
            self.searchResults = array;
            
            for (int i=0;i<[array count];i++ ) {
                [collectionview itemAtIndex:i].view.alphaValue = 1.0;
            }
            
            DMLog(@"search string after: %@ string value: %@ ",
                  string,[sender stringValue]);
            searchsig = 0;
        }];
    }
}


@end
