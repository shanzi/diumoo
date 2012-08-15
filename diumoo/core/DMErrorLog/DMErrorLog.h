//
//  DMErrorLog.h
//  diumoo
//
//  Created by AnakinGWY on 12-8-10.
//
//

#import <Foundation/Foundation.h>

@interface DMErrorLog : NSObject
+(id) sharedErrorLog;
+(void) logErrorWith:(id)object method:(SEL)methodName andError:(NSError*)error;
+(void) logStateWith:(id)object fromMethod:(SEL)methodName andString:(NSString*)aString;
@end
