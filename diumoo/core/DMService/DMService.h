//
//  DMService.h
//  diumoo
//
//  Created by Shanzi on 12-8-3.
//
//

#import <Cocoa/Cocoa.h>
#import "NSData+AESCrypt.h"
#import "NSData+Base64.h"
#import "DMErrorLog.h"


#define CURRENT_VERSION 1


#define SERVICE_KEY @"-%ZxYx1@99D|ifwN{>*u'<.Rqw]6I:j'"
#define REGISTER_SONG_SERVICE_URL @"http://127.0.0.1:8000/registersong/"

@interface DMService : NSObject

+(NSOperationQueue*) serviceQueue;

+(void)performOnServiceQueue:(void(^)(void))block;
+(void)performOnMainQueue:(void(^)(void))block;
+(NSString*) cleanStartAttribute:(NSString*)start;
+(BOOL) openDiumooLink:(NSString*)url;
+(void) importRecordOperation;
+(void) importRecordOperationWithFilePath:(NSURL*)fp;
+(void) exportRecordOperation;
+(void) showDMNotification;
+(void) shareLinkWithDictionary:(NSDictionary*) dict callback:(void(^)(NSString* url)) block;
@end
