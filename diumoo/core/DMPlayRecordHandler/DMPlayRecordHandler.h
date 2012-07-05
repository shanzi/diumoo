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
    
}


@property(nonatomic,copy) NSURL* recordFileURL;
@property(nonatomic,retain) NSManagedObjectContext* context;
@property(nonatomic,assign) id<DMPlayRecordHandlerDelegate> delegate;

+(DMPlayRecordHandler*) sharedRecordHandler;
+(NSString*) pathToDataFileFolder;
-(NSManagedObject*) songWithSid:(NSString*) sid;
-(void) addRecordWithCapsule:(DMPlayableCapsule*) capsule;
-(void) addRecordAsyncWithCapsule:(DMPlayableCapsule*)capsule;
-(void) open;

-(void) removeCurrentVersion;
-(void) playSongWith:(NSString*)sid andSsid:(NSString*) ssid;

@end
