//
//  main.m
//  diumoo
//
//  Created by Shanzi on 12-6-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DMApp.h"

int main(int argc, char *argv[])
{
    NSAutoreleasePool* pool = [NSAutoreleasePool new];
    [DMApp sharedApplication];
    [NSBundle loadNibNamed:@"MainMenu" owner:NSApp];
    [NSApp run];
    [pool drain];
    return 0;

}
