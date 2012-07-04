//
//  DMDocument.h
//  documentTest
//
//  Created by Shanzi on 12-6-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>



@interface DMDocument : NSDocument <NSWindowDelegate>


@property(nonatomic,assign)NSDictionary* baseSongInfo;

@property(nonatomic,copy) NSString* sid;
@property(nonatomic,copy) NSString* ssid;
@property(nonatomic,copy) NSString* aid;


@end
