//
//  DMErrorLog.m
//  diumoo
//
//  Created by AnakinGWY on 12-8-10.
//
//

#import "DMErrorLog.h"

static DMErrorLog *sharedErrorLogger;

@implementation DMErrorLog

+(id) sharedErrorLog
{
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"enableLog"] integerValue] == NSOnState) {
        sharedErrorLogger = [[DMErrorLog alloc] init];
    } else
        sharedErrorLogger = nil;
    
    return sharedErrorLogger;
}

+(void) logErrorWith:(id)object method:(SEL)methodName andError:(NSError *)error
{
    if (sharedErrorLogger != nil) {
        NSLog(@"ERROR Log: %@ %@ returns an Error = %@",object,NSStringFromSelector(methodName),error);
    }
}

+(void) logStateWith:(id)object fromMethod:(SEL)methodName andString:(NSString *)aString
{
    if (sharedErrorLogger != nil) {
        NSLog(@"State Log: %@ %@ has a state = %@",object,NSStringFromSelector(methodName),aString);
    }
}

@end
