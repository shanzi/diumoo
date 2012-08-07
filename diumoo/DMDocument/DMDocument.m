//
//  DMDocument.m
//  documentTest
//
//  Created by Shanzi on 12-6-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DMDocument.h"
#import "DMDocumentWindowController.h"
#import "DMPlayRecordHandler.h"
#import "DMService.h"

@implementation DMDocument
@synthesize baseSongInfo,aid,sid,ssid;



- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
    }
    return self;
}


-(void)makeWindowControllers
{
    if(sid == nil) return;
    if ([self.windowControllers count]==0) {
        DMDocumentWindowController* windowController = [[DMDocumentWindowController allocWithZone:[self zone]] init];
        [self addWindowController:[windowController autorelease]];
    }
}


-(BOOL)revertToContentsOfURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError **)outError
{
    BOOL success = [super revertToContentsOfURL:url ofType:typeName error:outError];
    if (success) {
        [[self windowControllers]makeObjectsPerformSelector:@selector(setupWindowForDocument:) withObject:self];
        [[DMPlayRecordHandler sharedRecordHandler] removeCurrentVersion];
        [[DMPlayRecordHandler sharedRecordHandler] playSongWith:self.sid andSsid:self.ssid];
    }
    return YES;
}


+(BOOL) autosavesInPlace
{
    return YES;
}

+(BOOL)preservesVersions
{
    return YES;
}

-(BOOL) hasUnautosavedChanges
{
    return NO;
}



-(NSData*) dataOfType:(NSString *)typeName error:(NSError **)outError
{
    NSData* data = [[baseSongInfo descriptionWithLocale:nil] dataUsingEncoding:NSUTF8StringEncoding];
    return  data;
}


-(BOOL) readFromURL:(NSURL *)url ofType:(NSString *)type error:(NSError **)outError
{
    DMLog(@"read from url %@, type : %@",url.path,type);
    if ([type isEqualToString:@"shortcut"]) {
        NSDictionary* dict = [NSDictionary dictionaryWithContentsOfURL:url];
        if (dict) {
            self.sid = [dict valueForKey:@"sid"];
            self.ssid = [dict valueForKey:@"ssid"];
            self.aid = [dict valueForKey:@"aid"];
            self.baseSongInfo = dict;
            if (sid) {
                return YES;
            }
        }
    }
    else if([type isEqualToString:@"_private_record"]) {

        NSString* _sid = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];

        if (_sid) {
            DMPlayRecordHandler* sharedHandler = [DMPlayRecordHandler sharedRecordHandler];
            NSManagedObject* object = [sharedHandler songWithSid:_sid];
            if (object) {
                self.sid = [object valueForKey:@"sid"];
                self.ssid = [object valueForKey:@"ssid"];
                self.aid = [object valueForKey:@"aid"];
                
                NSArray* keyarray = [[[object entity] attributesByName] allKeys];
                NSDictionary*  infodict = [object dictionaryWithValuesForKeys:keyarray];
                self.baseSongInfo = infodict;
                return YES;
            }
        }
    }
    else if([type isEqualToString:@"Play Record"])
    {
        if (NSAlertDefaultReturn
            ==
            NSRunAlertPanel(@"导入播放记录", @"您刚刚打开的一个diumoo播放记录文件，是否导入这些记录？",
                            @"是", @"否", nil))
        {
            [DMService importRecordOperationWithFilePath:url];
        }
        
        return YES;
    }
    
    *outError = [NSError errorWithDomain:@"打开文件失败" code:-1 userInfo:nil];
    
    return NO;
}



@end
