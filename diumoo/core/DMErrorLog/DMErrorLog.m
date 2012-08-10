//
//  DMErrorLog.m
//  diumoo
//
//  Created by AnakinGWY on 12-8-10.
//
//

#import "DMErrorLog.h"

@implementation DMErrorLog

+(void)logErrorWith:(id)object method:(SEL)methodName andError:(NSError *)error
{
    if (NSOnState) {
        NSLog(@"%@ %@ returns an Error = %@",object,NSStringFromSelector(methodName),error);
    }
}

@end
