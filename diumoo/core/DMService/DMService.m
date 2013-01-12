//
//  DMService.m
//  diumoo
//
//  Created by Shanzi on 12-8-3.
//
//

#import "DMService.h"
#import "DMPlayRecordHandler.h"
#import "NSData+AESCrypt.h"
#import "NSDictionary+UrlEncoding.h"

#define DM_SONG_PREFIX @"diumoo://song?key="
#define DM_ALBUM_PREFIX @"diumoo://album?key="
#define DM_MUSICIAN_PREFIX @"diumoo://musician?key="
#define DM_SOUNDTRACK_PREFIX @"diumoo://soundtrack?key="
#define DM_CHANNEL_PREFIX @"diumoo://channel?key="

#define NOTIFICATION_URL @"http://channel.diumoo.net/notification"
#define GET_SHARE_LINK_URL @"http://share.diumoo.net/"

#define APP_TYPE_PRO 1
#define APP_TYPE_LITE (1<<1)
#define APP_TYPE_TEST (1<<2)
#define CURRENT_APP_TYPE APP_TYPE_PRO

static NSOperationQueue* serviceQueue;

@implementation DMService

+(NSOperationQueue*) serviceQueue
{
    if (serviceQueue == nil) {
        serviceQueue= [[NSOperationQueue alloc] init];
    }
    return serviceQueue;
}

+(void)performOnServiceQueue:(void(^)(void))block
{
    [[DMService serviceQueue] addOperationWithBlock:block];
}

+(void)performOnMainQueue:(void(^)(void))block
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:block];
}

+(NSString*) cleanStartAttribute:(NSString*)start
{
    [DMErrorLog logStateWith:self fromMethod:_cmd andString:[NSString stringWithFormat:@"clean start = %@",start]];
    
    NSArray* startComponents = [start componentsSeparatedByString:@"g"];
    if ([startComponents count]>=2) {
        if ([startComponents[1] length] == 4) {
            return [NSString stringWithFormat:@"%@g%@g",
                    startComponents[0],
                    startComponents[1]
                    ];
        }
    }
    return nil;
}

+(BOOL)openDiumooLink:(NSString *)string
{
    NSString* start;
    NSDictionary* userinfo;
    
    if ([string hasPrefix:DM_SONG_PREFIX]) {
        start = [string stringByReplacingOccurrencesOfString:DM_SONG_PREFIX
                                                  withString:@""];
        start = [DMService cleanStartAttribute:start];
        if (start != nil) {
            userinfo = @{ @"type" : @"song",@"start" : start };
        }
        
    }
    else if([string hasPrefix:DM_ALBUM_PREFIX])
    {
        start = [string stringByReplacingOccurrencesOfString:DM_ALBUM_PREFIX
                                                  withString:@""];
        
        if (start) {
            userinfo = @{ @"type" : @"album",@"aid": start};
        }
    }
    else if ([string hasPrefix:DM_MUSICIAN_PREFIX])
    {
        start = [string stringByReplacingOccurrencesOfString:DM_MUSICIAN_PREFIX
                                                  withString:@""];
        if (start) {
            userinfo = @{@"type":@"musician",@"musician_id":start};
        }
    }
    else if([string hasPrefix:DM_SOUNDTRACK_PREFIX])
    {
        start = [string stringByReplacingOccurrencesOfString:DM_SOUNDTRACK_PREFIX
                                                  withString:@""];
        if (start) {
            userinfo = @{@"type":@"soundtrack",@"soundtrack_id":start};
        }
    }
    else if([string hasPrefix:DM_CHANNEL_PREFIX])
    {
        start = [string stringByReplacingOccurrencesOfString:DM_CHANNEL_PREFIX withString:@""];
        start = [start stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSArray* componets = [start componentsSeparatedByString:@"|"];
        if ([componets count] == 2) {
            NSInteger cid = [[componets objectAtIndex:0] integerValue];
            NSString* ctitle = [componets objectAtIndex:1];
            @try {
                if (cid > 0 && [ctitle length]) {
                    userinfo = @{ @"type" : @"channel",@"cid":@(cid),@"title":ctitle};
                }
            }
            @catch (NSException *exception) {
                
            }
        }
    }
    
    if (userinfo != nil) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"playspecial"
                                                            object:nil
                                                          userInfo:userinfo
         ];
        
        return YES;
    }
    else
    {
        NSRunCriticalAlertPanel(NSLocalizedString(@"OPEN_URL_FAILED", nil), //@"打开URL失败",
                                NSLocalizedString(@"OPEN_URL_FAILED_DETAIL",
                                                  @"未能成功打开您指定的URL，可能是您试图播放的专辑、音乐家或电影原声不可用。"),
                                @"OK",
                                nil, nil);
        return NO;
    }
}

+(void)importRecordOperation
{
    
    NSOpenPanel* openpanel = [NSOpenPanel openPanel];
    [openpanel setCanChooseDirectories:NO];
    [openpanel setAllowsMultipleSelection:NO];
    [openpanel setAllowedFileTypes:@[@"dmrecord"]];
    [openpanel setTitle:NSLocalizedString(@"IMPORT_PLAY_RECORD",@"导入播放记录")];
    [openpanel setPrompt:NSLocalizedString(@"IMPORT", nil)];
    if ([openpanel runModal] == NSOKButton) {
        NSURL* url = [openpanel URLs][0];
        [DMService importRecordOperationWithFilePath:url];
        
    }
}

+(void)importRecordOperationWithFilePath:(NSURL *)fp
{
    [DMService performOnServiceQueue:^{
        NSArray *array = [NSArray arrayWithContentsOfURL:fp];
        if (array) {
            NSInteger errorcount=0;
            NSInteger finished = 0;
            DMPlayRecordHandler *handler = [DMPlayRecordHandler sharedRecordHandler];
            for (NSDictionary *song in array) {
                if(![handler addRecordWithDict:song]){
                    errorcount += 1;
                }
                else finished +=1;
            }
            if (finished> 0) {
                [handler save];
                NSString* summary = [NSString stringWithFormat:
                                     NSLocalizedString(@"SUCCESS_IMPORT_DETAIL", @"成功导入了 %ld 个歌曲记录，失败 %ld 个。"),
                                     finished,errorcount];
                [DMService performOnMainQueue:^{
                    NSRunInformationalAlertPanel(NSLocalizedString(@"SUCCESS_IMPORT",nil), summary, @"OK", nil, nil);
                }];
                
                return;
            }
        }
        
        [DMService performOnMainQueue:^{
            NSRunCriticalAlertPanel(NSLocalizedString(@"IMPORT_FAILED",@"导入失败"),
                                    NSLocalizedString(@"IMPORT_FAILED_DETAIL", 
                                                      @"导入播放记录失败，您试图导入的文件类型不正确或者文件已损坏。"),
                                    @"OK", nil, nil);
        }];
        
    }];
}

+(void) exportRecordOperation
{
    NSSavePanel* savepanel = [NSSavePanel savePanel];
    [savepanel setAllowedFileTypes:@[@"dmrecord"]];
    [savepanel setTitle:NSLocalizedString(@"EXPORT_PLAY_RECORD", nil)];
    [savepanel setPrompt:NSLocalizedString(@"EXPORT", nil)];
    if ([savepanel runModal] == NSOKButton) {
        NSURL* url = [savepanel URL];
        [DMService performOnMainQueue:^{
            NSArray* songs = [[DMPlayRecordHandler sharedRecordHandler] allSongs];
            if (songs) {
                NSInteger count = [songs count] + 10;
                NSInteger finished = 0;
                NSMutableArray* outarray = [[NSMutableArray alloc] initWithCapacity:count];
                for (NSManagedObject* song in songs) {
                    [outarray addObject:
                     @{
                     @"sid":[song valueForKey:@"sid"],
                     @"ssid":[song valueForKey:@"ssid"],
                     @"aid":[song valueForKey:@"aid"],
                     @"albumtitle":[song valueForKey:@"albumtitle"],
                     @"title":[song valueForKey:@"title"],
                     @"url":[song valueForKey:@"url"],
                     @"picture":[song valueForKey:@"picture"],
                     @"artist":[song valueForKey:@"artist"],
                     @"date":[song valueForKey:@"date"],
                     @"rating_avg":[song valueForKey:@"rating_avg"]
                     }
                     ];
                    finished += 1;
                }
                [outarray writeToURL:url atomically:YES];
                
                NSString* summary = [NSString stringWithFormat:
                                     NSLocalizedString(@"SUCCESS_EXPORT_DETAIL",@"成功导出 %ld 首歌曲的播放记录。")
                                     ,finished];
                [DMService performOnMainQueue:^{
                    NSRunInformationalAlertPanel(NSLocalizedString(@"SUCCESS_EXPORT", nil),
                                                 summary, @"OK", nil, nil);
                }];
                
                
            }
        }];
    }
}



+(void) showDMNotification
{
    NSInteger current_id = [[[NSUserDefaults standardUserDefaults]
                             valueForKey:@"notificationID"]integerValue];
    
    NSDictionary* bundleinfo = [[NSBundle mainBundle] infoDictionary];
    NSString* version=bundleinfo[@"CFBundleVersion"];
    
    NSString* urlstring = [NSString stringWithFormat:@"%@?f=%d&v=%@&d=%ld",
                           NOTIFICATION_URL,CURRENT_APP_TYPE,version,current_id];
    NSURL* url = [NSURL URLWithString:urlstring];
    NSURLRequest* request = nil;
    request = [NSURLRequest requestWithURL:url
                               cachePolicy:NSURLCacheStorageAllowed
                           timeoutInterval:10.0];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[DMService serviceQueue]
                           completionHandler:^(NSURLResponse *r, NSData *d, NSError *e)
     {
         if (e==NULL) {
             NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:d options:NSJSONReadingMutableContainers error:&e];
             if (e==NULL) {
                 if([dict[@"nomsg"] boolValue]) return;
                 
                 NSString* title = dict[@"title"];
                 NSString* content = dict[@"content"];
                 NSString* referenceURL = dict[@"url"];
                 NSInteger _id = [dict[@"id"] integerValue];
                 BOOL force_open = [dict[@"can_cancel"] boolValue];
                 
                 [[NSUserDefaults standardUserDefaults]
                  setValue:@(_id) forKey:@"notificationID"
                  ];
                 
                 [DMService performOnMainQueue:
                  ^{
                      NSInteger rvalue;
                      
                      if (force_open && referenceURL) {
                          rvalue = NSRunInformationalAlertPanel(title, content,
                                                                NSLocalizedString(@"SHOW_DETAIL", @"查看详细"), nil,
                                                                nil);
                      }
                      else
                      {
                          rvalue = NSRunInformationalAlertPanel(title, content,
                                                                NSLocalizedString(@"SHOW_DETAIL", @"查看详细"), @"OK", nil);
                      }
                      
                      if(rvalue == NSAlertDefaultReturn){
                          NSURL* url = [NSURL URLWithString:referenceURL];
                          [[NSWorkspace sharedWorkspace] openURL:url];
                      }
                  }];
                 
             }
             
         }
     }];
}

+(void)shareLinkWithDictionary:(NSDictionary *)dict callback:(void (^)(NSString *))block
{
    
    NSString* urlencoded = [dict urlEncodedString];
    NSData* urldata = [urlencoded dataUsingEncoding:NSUTF8StringEncoding];
    NSData* crypted = [urldata AES256EncryptWithKey:SERVICE_KEY];
    NSString* base64 = [crypted base64EncodedString];
    

    NSDictionary* keydict = @{ @"key" : base64 ,@"sid":dict[@"s"]};
    NSString* urlstring = [NSString stringWithFormat:@"%@?%@",
                           GET_SHARE_LINK_URL,[keydict urlEncodedString]];
    NSURL* url = [NSURL URLWithString:urlstring];
        
    NSURLRequest* request = [NSURLRequest requestWithURL:url
                               cachePolicy:NSURLCacheStorageAllowed
                           timeoutInterval:2.0];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[DMService serviceQueue]
                           completionHandler:^(NSURLResponse *r, NSData *d, NSError *e) {
                               DMLog(@"status code: %ld",[(NSHTTPURLResponse*)r statusCode]);
                               if ([(NSHTTPURLResponse*)r statusCode] == 200) {
                                   NSString* string = [NSString stringWithCString:[d bytes]
                                                                         encoding:NSASCIIStringEncoding];
                                   if([string length]){
                                       block(string);
                                       return;
                                   }
                               }

                               block(nil);
                               
                           }];
}

+(NSString*) pathToDataFileFolder
{
    NSArray* dirs = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory,
                                                        NSUserDomainMask, YES);
    
    NSString* pathToUserApplicationSupportFolder = dirs[0];
    NSString* pathToDiumooDataFolder = [pathToUserApplicationSupportFolder
                                        stringByAppendingPathComponent:@"diumoo"];
    
    NSFileManager* manager = [NSFileManager defaultManager];
    if(![manager fileExistsAtPath:pathToDiumooDataFolder]){
        NSError* err = nil;
        [manager createDirectoryAtPath:pathToDiumooDataFolder
           withIntermediateDirectories:YES attributes:nil error:&err];
        if (err) {
            return nil;
        }
    }
    return pathToDiumooDataFolder;
}

@end
