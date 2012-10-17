//
//  DMSearchPanelControllerWindowController.h
//  diumoo
//
//  Created by Shanzi on 12-10-9.
//
//

#import <Cocoa/Cocoa.h>

@interface DMSearchPanelController : NSWindowController
@property(nonatomic) NSArray* searchResults;

+(DMSearchPanelController*) sharedSearchPanel;
-(IBAction)search:(id)sender;

@end
