//
//  DMDocument.m
//  documentTest
//
//  Created by Shanzi on 12-6-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DMDocument.h"
#import "DMDocumentWindowController.h"

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
    NSLog(@"revert:%@",url);
    BOOL success = [super revertToContentsOfURL:url ofType:typeName error:outError];
    if (success) {
        [[self windowControllers]makeObjectsPerformSelector:@selector(setupWindowForDocument)];
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

    NSDictionary* dict = [NSDictionary dictionaryWithContentsOfURL:url];
    if (dict) {
        self.sid = [dict valueForKey:@"sid"];
        self.ssid = [dict valueForKey:@"ssid"];
        self.aid = [dict valueForKey:@"aid"];
        self.baseSongInfo = dict;
        return YES;
    }
    else {
        NSError * error = [NSError errorWithDomain:@"打开文件失败" code:-1 userInfo:nil];
        *outError = error;
        return NO;
    }
}



@end
