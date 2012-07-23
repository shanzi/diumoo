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
    
    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
    // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
    
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
            NSManagedObject* object = [[DMPlayRecordHandler sharedRecordHandler] songWithSid:_sid];
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
    
    *outError = [NSError errorWithDomain:@"打开文件失败" code:-1 userInfo:nil];
    
    return NO;
}



@end
