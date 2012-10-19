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
@synthesize baseSongInfo;

- (id)init
{
    if (self = [super init]) {
        // Add your subclass-specific initialization here.
    }
    return self;
}


-(void)makeWindowControllers
{
    if(sid == nil)
        return;
    if ([self.windowControllers count]==0) {
        DMDocumentWindowController* windowController = [[DMDocumentWindowController allocWithZone:nil] init];
        [self addWindowController:windowController];
    }
}

-(void)revertDocumentToSaved:(id)sender
{
    if ([self respondsToSelector:@selector(browseDocumentVersions:)]) {
        [super browseDocumentVersions:self];
    } else {
        [super revertDocumentToSaved:self];
    }
}

-(BOOL)revertToContentsOfURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError **)outError
{
    BOOL success = [super revertToContentsOfURL:url ofType:typeName error:outError];
    if (success) {
        [[self windowControllers]makeObjectsPerformSelector:@selector(setupWindowForDocument:) withObject:self];
        DMLog(@"before remove version");
        [[DMPlayRecordHandler sharedRecordHandler] removeCurrentVersion];
        DMLog(@"after remove version");
        [[DMPlayRecordHandler sharedRecordHandler] playSongWith:sid andSsid:ssid];
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
    
    if([type isEqualToString:@"_private_record"]) {
        NSString* _sid = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        if (_sid) {
            DMPlayRecordHandler* sharedHandler = [DMPlayRecordHandler sharedRecordHandler];
            NSManagedObject* object = [sharedHandler songWithSid:_sid];
            if (object) {
                sid = [object valueForKey:@"sid"];
                ssid = [object valueForKey:@"ssid"];
                aid = [object valueForKey:@"aid"];
                
                NSArray* keyarray = [[[object entity] attributesByName] allKeys];
                NSDictionary*  infodict = [object dictionaryWithValuesForKeys:keyarray];
                baseSongInfo = infodict;
                return YES;
            }
        }
    }
    else if ([type isEqualToString:@"shortcut"]) {
        NSDictionary* dict = [NSDictionary dictionaryWithContentsOfURL:url];
        if (dict) {
            sid = [dict valueForKey:@"sid"];
            ssid = [dict valueForKey:@"ssid"];
            aid = [dict valueForKey:@"aid"];
            baseSongInfo = dict;
            if (sid) {
                return YES;
            }
        }
    }
    else if([type isEqualToString:@"Play Record"])
    {
        if (NSAlertDefaultReturn
            ==
            NSRunAlertPanel(NSLocalizedString(@"IMPORT_PLAY_RECORD", nil),
                            NSLocalizedString(@"IMPORT_PLAY_RECORD_DETAIL", nil),
                            //@"您刚刚打开的一个diumoo播放记录文件，是否导入这些记录？",
                            NSLocalizedString(@"YES", nil), NSLocalizedString(@"NO", nil), nil))
        {
            [DMService importRecordOperationWithFilePath:url];
        }
        
        return YES;
    }
    
    if (outError != nil) {
        *outError = [NSError errorWithDomain:NSLocalizedString(@"OPEN_FILE_FAILED", nil) code:-1 userInfo:nil];
    }
    
    return NO;
}



@end
