//
//  DMPlayRecordHandler.h
//  diumoo
//
//  Created by Shanzi on 12-7-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DMPlayableCapsule;

@interface DMPlayRecordHandler : NSObject
{
    
}


@property(nonatomic,copy) NSURL* recordFileURL;
@property(nonatomic,retain) NSManagedObjectContext* context;

+(DMPlayRecordHandler*) sharedRecordHandler;
+(NSString*) pathToDataFileFolder;
-(NSManagedObject*) songWithSid:(NSString*) sid;
-(void) addRecordWithCapsule:(DMPlayableCapsule*) capsule;
-(void) addRecordAsyncWithCapsule:(DMPlayableCapsule*)capsule;
-(void) open;
@end
