//
//  DMSearchPanelControllerWindowController.h
//  diumoo
//
//  Created by Shanzi on 12-10-9.
//
//

#import <Cocoa/Cocoa.h>

@interface DMSearchPanelController : NSWindowController
@property(readonly) NSManagedObjectContext* contextObject;
@property(readonly) NSArray* sortDescriptors;

+(DMSearchPanelController*) sharedSearchPanel;
+(void) rearrage;

@end
