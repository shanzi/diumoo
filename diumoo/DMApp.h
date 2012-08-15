//
//  DMApp.h
//  diumoo
//
//  Created by Shanzi on 12-6-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SPMediaKeyTap.h"

@interface DMApp : NSApplication
{
    NSString *openedURLString;
}

@property (copy) NSString *openedURLString;

@end
