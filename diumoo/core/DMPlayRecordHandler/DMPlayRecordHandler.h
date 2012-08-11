//
//  DMPlayRecordHandler.h
//  diumoo
//
//  Created by Shanzi on 12-7-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kPlaySongNotificationName @"playsong"
#define kPlayAlbumNotificationName @"playalbum"

@protocol DMPlayRecordHandlerDelegate <NSObject>
-(void) playSongWithSid:(NSString*)sid andSsid:(NSString*)ssid;
@end

@class DMPlayableCapsule;

@interface DMPlayRecordHandler : NSObject
{
    NSURL *recordFileURL;
    NSManagedObjectContext *context;
    id<DMPlayRecordHandlerDelegate> __strong delegate;
}
@property(nonatomic,copy) NSURL* recordFileURL;
@property(nonatomic,strong) NSManagedObjectContext* context;
@property(nonatomic,strong) id<DMPlayRecordHandlerDelegate> delegate;

+(DMPlayRecordHandler*) sharedRecordHandler;
-(NSManagedObject*) songWithSid:(NSString*) sid;
-(void) addRecordWithCapsule:(DMPlayableCapsule*) capsule;
-(void) addRecordAsyncWithCapsule:(DMPlayableCapsule*)capsule;
-(BOOL) addRecordWithDict:(NSDictionary*) dict;
-(void) open;
-(void) save;
-(void) removeCurrentVersion;
-(void) playSongWith:(NSString*)sid andSsid:(NSString*) ssid;
-(NSArray*) allSongs;

@end
