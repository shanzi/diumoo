//
//  DMOpenURLWindowController.h
//  diumoo
//
//  Created by Shanzi on 12-8-5.
//
//

#import <Cocoa/Cocoa.h>

@interface DMOpenURLWindowController : NSWindowController
{
    IBOutlet NSComboBox* urlbox;
}

-(IBAction)urlOpenAction:(id)sender;


@end
