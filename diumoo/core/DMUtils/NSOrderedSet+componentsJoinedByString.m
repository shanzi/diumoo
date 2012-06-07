//
//  NSSet+componetsJoinedByString.m
//  diumoo
//
//  Created by Shanzi on 12-6-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSOrderedSet+componentsJoinedByString.h"

@implementation NSOrderedSet (componetsJoinedByString)

-(id) componentsJoinedByString:(NSString*) string
{
    NSInteger count = [self count];
    NSMutableString* str = [NSMutableString stringWithCapacity:count];
    for (NSInteger i = 0; i<[self count]; i++) {
        if(i>0) [str appendString:string];
        [str appendFormat:@"%@",[self objectAtIndex:i]];
    }
    return [str autorelease];
}

@end
