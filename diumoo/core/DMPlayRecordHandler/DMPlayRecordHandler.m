//
//  DMPlayRecordHandler.m
//  diumoo
//
//  Created by Shanzi on 12-7-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DMPlayRecordHandler.h"
#import "DMPlayableCapsule.h"
#import "DMService.h"
#import "DMErrorLog.h"

static DMPlayRecordHandler* recordHandler;

@implementation DMPlayRecordHandler
@synthesize recordFileURL,context,delegate;

#pragma class methods
+(DMPlayRecordHandler*) sharedRecordHandler
{
    if (recordHandler==nil) {
        recordHandler = [[DMPlayRecordHandler alloc] init];
    }
    return recordHandler;
}

#pragma ---

#pragma init and dealloc
-(id) init
{
    if (self = [super init]) {
        NSString* pathToFolder = [DMService pathToDataFileFolder];
        NSString* recordFilePath = [pathToFolder stringByAppendingPathComponent:@"record.dmsid"];
        recordFileURL = [NSURL fileURLWithPath:recordFilePath];
        context = [self makeContextWithPath:pathToFolder];
    }
    return self;
}

#pragma ---

#pragma private methods
-(NSManagedObjectContext*) makeContextWithPath:(NSString*) datapath
{    
    datapath = [datapath stringByAppendingPathComponent:@"dmdata.db"];
    
    NSManagedObjectModel* model = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc]
                   initWithManagedObjectModel:model];
    
    NSError *error;

    [coordinator addPersistentStoreWithType:NSSQLiteStoreType
                              configuration:nil 
                                        URL:[NSURL fileURLWithPath:datapath]
                                    options:nil
                                      error:&error];
    if (error) {
        [DMErrorLog logErrorWith:self method:_cmd andError:error];
        [[NSFileManager defaultManager] removeItemAtPath:datapath error:nil];
    }
    
    context = [[NSManagedObjectContext alloc] initWithConcurrencyType:
                NSPrivateQueueConcurrencyType];
    
    [context setPersistentStoreCoordinator:coordinator];
    
    return  context;
}
#pragma ---


-(NSManagedObject*) songWithSid:(NSString*) sid
{

    NSFetchRequest* fetchRequset = [NSFetchRequest fetchRequestWithEntityName:@"Song"];
    [fetchRequset setPredicate:[NSPredicate predicateWithFormat:@"sid = %@",sid]];
    
    NSError* fetchErr = nil;
    //DMLog(@"%@",context);
    NSArray* results = [context executeFetchRequest:fetchRequset error:&fetchErr];

    if ([results count]>0) {
        // 找到了之前的记录
        return results[0];
    }
    return nil;
}

-(void) addRecordWithCapsule:(DMPlayableCapsule *)capsule
{
    if (capsule.ssid == nil) {
        return;
    }
    
    NSString* sid = capsule.sid;
    NSManagedObject* theSong = [self songWithSid:sid];
    
    if (theSong) {
        [theSong setValue:[NSDate date] forKey:@"date"];
    }
    else {
        // 没有找到之前的记录
        NSDate* date = [NSDate date];
        
        NSManagedObject* song = [NSEntityDescription insertNewObjectForEntityForName:@"Song"
                                                              inManagedObjectContext:context];        
        [song setValue:capsule.sid forKey:@"sid"];
        [song setValue:capsule.ssid forKey:@"ssid"];
        [song setValue:capsule.aid forKey:@"aid"];
        [song setValue:capsule.title forKey:@"title"];
        [song setValue:capsule.albumtitle forKey:@"albumtitle"];
        [song setValue:capsule.artist forKey:@"artist"];
        [song setValue:capsule.largePictureLocation forKey:@"picture"];
        [song setValue:capsule.albumLocation forKey:@"url"];
        [song setValue:@(capsule.rating_avg)
                forKey:@"rating_avg"];
        [song setValue:date forKey:@"date"];
        
        [context save:nil];
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.recordFileURL.path]) {
        
        [NSFileVersion addVersionOfItemAtURL: self.recordFileURL
                           withContentsOfURL: self.recordFileURL
                                     options: 0
                                       error: nil];
    }
    
    [sid writeToURL:self.recordFileURL atomically:YES encoding:NSASCIIStringEncoding error:nil];
    
}

-(void) addRecordAsyncWithCapsule:(DMPlayableCapsule *)capsule
{
    NSBlockOperation* addrecord = [NSBlockOperation blockOperationWithBlock:^{
        [self addRecordWithCapsule:capsule]; 
    }];
    [[NSOperationQueue currentQueue] addOperation:addrecord];
}

-(BOOL) addRecordWithDict:(NSDictionary *)dict
{
    NSString* sid = dict[@"sid"];
    NSString* ssid = dict[@"ssid"];
    NSString* aid = dict[@"aid"];
    NSString* date = dict[@"date"];
    NSString* picture = dict[@"picture"];
    NSString* albumtitle = dict[@"albumtitle"];
    NSString* rating_avg = dict[@"rating_avg"];
    NSString* title = dict[@"title"];
    NSString* url = dict[@"url"];
    NSString* artist = dict[@"artist"];
    
    NSManagedObject* theSong = [self songWithSid:sid];
    if (theSong) {
        return YES;
    }
    else if (sid && ssid && aid && date && picture && albumtitle && rating_avg
        && title && url && artist
        )
    {
        NSManagedObject* song = [NSEntityDescription insertNewObjectForEntityForName:@"Song"
                                                              inManagedObjectContext:context];
        [song setValue:sid forKey:@"sid"];
        [song setValue:ssid forKey:@"ssid"];
        [song setValue:aid forKey:@"aid"];
        [song setValue:title forKey:@"title"];
        [song setValue:albumtitle forKey:@"albumtitle"];
        [song setValue:artist forKey:@"artist"];
        [song setValue:picture forKey:@"picture"];
        [song setValue:url forKey:@"url"];
        [song setValue:rating_avg forKey:@"rating_avg"];
        [song setValue:date forKey:@"date"];
        return YES;
    }
    return NO;
}

-(void) open
{
    NSDocumentController* controller =[NSDocumentController sharedDocumentController];
    NSArray* documents = [controller documents];
    if ([documents count]>0) {
        [documents makeObjectsPerformSelector:@selector(close)];
    }
    
    [controller openDocumentWithContentsOfURL:self.recordFileURL
                                          display:YES
                                            error:nil];
}

-(void) removeCurrentVersion
{
    NSFileVersion* current = [NSFileVersion currentVersionOfItemAtURL:self.recordFileURL];
    [current removeAndReturnError:nil];
}

-(void) playSongWith:(NSString *)sid andSsid:(NSString *)ssid
{
    [self.delegate playSongWithSid:sid andSsid:ssid];
}


-(void) save
{
    [context save:nil];
}

-(NSArray*)allSongs
{
    NSFetchRequest* fetchRequset = [NSFetchRequest fetchRequestWithEntityName:@"Song"];
    return [context executeFetchRequest:fetchRequset error:nil];
}

-(void) removeVersionsToLimit{
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.recordFileURL.path]) {
        
        NSInteger limit = [[[NSUserDefaults standardUserDefaults] valueForKey:@"versionsLimit"] integerValue];
        NSArray* versions = [NSFileVersion otherVersionsOfItemAtURL:self.recordFileURL];
        for (NSInteger i = ([versions count] - 1); i > limit; i--) {
            [[versions objectAtIndex:i] removeAndReturnError:nil];
        }
    }
    [context save:nil];
}

@end
