//
//  DMErrorLog.h
//  diumoo
//
//  Created by AnakinGWY on 12-8-10.
//
//

#import <Foundation/Foundation.h>

@interface DMErrorLog : NSObject
+(void) logErrorWith:(id)object method:(SEL)methodName andError:(NSError*)error;
@end
