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

@implementation DMPlayRecordHandler
@synthesize recordFileURL,context;

+(DMPlayRecordHandler*) sharedRecordHandler
{
    if (recordHandler==nil) {
        recordHandler = [[[DMPlayRecordHandler alloc] init] retain];
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

-(NSManagedObjectContext*) makeContextWithPath:(NSString*) datapath
{
    if (datapath == nil) {
        datapath = [[DMPlayRecordHandler pathToDataFileFolder]
                    stringByAppendingPathComponent:@"dmdata.db"];
    }
    else {
        datapath = [datapath stringByAppendingPathComponent:@"dmdata.db"];
    }
    NSURL* databaseURL = [NSURL fileURLWithPath:datapath];
    
    NSManagedObjectModel* model = [NSManagedObjectModel mergedModelFromBundles:nil];
    NSPersistentStoreCoordinator* coordinator = nil;
    coordinator = [[NSPersistentStoreCoordinator alloc]
                   initWithManagedObjectModel:model];
    NSError* err = nil;
    

    [coordinator addPersistentStoreWithType:NSBinaryStoreType
                              configuration:nil 
                                        URL:databaseURL
                                    options:nil
                                      error:&err];
    if (err) {
        NSLog(@"%@",err);
    }
    
    context = [[[NSManagedObjectContext alloc] initWithConcurrencyType:
                NSPrivateQueueConcurrencyType] retain];
    
    [context setPersistentStoreCoordinator:coordinator];
    return  context;
}



-(NSManagedObject*) songWithSid:(NSString*) sid
{

    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"sid = %@",sid];
    NSFetchRequest* fetchRequset = [NSFetchRequest fetchRequestWithEntityName:@"Song"];
    [fetchRequset setPredicate:predicate];
    
    NSError* fetchErr = nil;
    NSArray* results = [context executeFetchRequest:fetchRequset error:&fetchErr];
    
    
    if ([results count]) {
        // 找到了之前的记录
        NSManagedObject* object = [results objectAtIndex:0];
        return object;
    }
    return  nil;
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
            NSLog(@"%@",err);
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

@end
