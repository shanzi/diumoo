//
//  DMDocument.h
//  documentTest
//
//  Created by Shanzi on 12-6-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>



@interface DMDocument : NSDocument <NSWindowDelegate>
{
    NSString *sid;
    NSString *ssid;
    NSString *aid;
    
    NSDictionary *baseSongInfo;
}

@end
