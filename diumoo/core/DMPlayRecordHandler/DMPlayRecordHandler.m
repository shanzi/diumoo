//
//  DMPlayRecordHandler.m
//  diumoo
//
//  Created by Shanzi on 12-7-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DMPlayRecordHandler.h"
#import "DMPlayableCapsule.h"

static DMPlayRecordHandler* recordHandler;

@interface DMPlayableCapsule ()

+(NSString*) pathToDataFileFolder;

-(NSManagedObjectContext*) makeContextWithPath:(NSString*) datapath;

@end

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


+(NSString*) pathToDataFileFolder
{
    NSArray* dirs = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory,
                                                        NSUserDomainMask, YES);
    
    NSString* pathToUserApplicationSupportFolder = [dirs objectAtIndex:0];
    NSString* pathToDiumooDataFolder = [pathToUserApplicationSupportFolder
                                        stringByAppendingPathComponent:@"diumoo"];
    
    NSFileManager* manager = [NSFileManager defaultManager];
    if(![manager fileExistsAtPath:pathToDiumooDataFolder])
    {
        NSError* err = nil;
        [manager createDirectoryAtPath:pathToDiumooDataFolder
           withIntermediateDirectories:YES attributes:nil error:&err];
        if (err) {
            return nil;
        }
    }
    return pathToDiumooDataFolder;
}
#pragma ---

#pragma init and dealloc
-(id) init
{
    self = [super init];
    if (self) {
        NSString* pathToFolder = [DMPlayRecordHandler pathToDataFileFolder];
        NSString* recordFilePath = [pathToFolder stringByAppendingPathComponent:@"record.dmsid"];
        self.recordFileURL = [NSURL fileURLWithPath:recordFilePath];
        self.context = [self makeContextWithPath:pathToFolder];;
    }
    return self;
}

-(void)dealloc
{
    self.delegate = nil;
    [recordFileURL release];
    [context release];
    [super dealloc];
}
#pragma ---

#pragma private methods
-(NSManagedObjectContext*) makeContextWithPath:(NSString*) datapath
{
    DMLog(@"DMPlayerRecordDatabase Path = %@",datapath);
    
    datapath = [datapath stringByAppendingPathComponent:@"dmdata.db"];
    
    NSManagedObjectModel* model = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc]
                   initWithManagedObjectModel:model];
    
    NSError *err = nil;

    [coordinator addPersistentStoreWithType:NSBinaryStoreType
                              configuration:nil 
                                        URL:[NSURL fileURLWithPath:datapath]
                                    options:nil
                                      error:&err];
    if (err) {
        DMLog(@"Load RecordDatabase with #Error# = %@",err);
    }
    
    context = [[NSManagedObjectContext alloc] initWithConcurrencyType:
                NSPrivateQueueConcurrencyType];
    
    [context setPersistentStoreCoordinator:coordinator];
    
    [coordinator release];
    
    return  [context autorelease];
}
#pragma ---


-(NSManagedObject*) songWithSid:(NSString*) sid
{

    NSFetchRequest* fetchRequset = [NSFetchRequest fetchRequestWithEntityName:@"Song"];
    [fetchRequset setPredicate:[NSPredicate predicateWithFormat:@"sid = %@",sid]];
    
    NSError* fetchErr = nil;
    NSArray* results = [context executeFetchRequest:fetchRequset error:&fetchErr];
    
    if ([results count]>0) {
        // 找到了之前的记录
        return [results objectAtIndex:0];
    }
    return nil;
}

-(void) addRecordWithCapsule:(DMPlayableCapsule *)capsule
{
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
        [song setValue:[NSNumber numberWithFloat:capsule.rating_avg]
                forKey:@"rating_avg"];
        [song setValue:date forKey:@"date"];
        
        
        NSError* err = nil;
        [context save:&err];
        if (err) {
            DMLog(@"Context save with #Error# = %@",err);
        }
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

@end
