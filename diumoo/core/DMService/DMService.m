//
//  DMService.m
//  diumoo
//
//  Created by Shanzi on 12-8-3.
//
//

#import "DMService.h"
#import "NSData+AESCrypt.h"

static NSOperationQueue* serviceQueue;

@implementation DMService

+(NSOperationQueue*) serviceQuere;
{
    if (serviceQueue) {
        return serviceQueue;
    }
    else{
        serviceQueue= [[[NSOperationQueue alloc] init] retain];
        return serviceQueue;
    }
}


+(void)registerSongWith:(NSString *)sid :(NSString *)ssid :(NSString *)aid
{
    if (sid && ssid && aid) {
        NSString* registerString = [NSString stringWithFormat:@"sid=%@&ssid=%@&aid=%@",sid,ssid,aid];
        NSData* stringData = [registerString dataUsingEncoding:NSUTF8StringEncoding];
        NSData* crypted = [stringData AES256EncryptWithKey:SERVICE_KEY];
        NSString* base64String = [crypted base64EncodedString];
        NSString* serviceUrlString = [REGISTER_SONG_SERVICE_URL stringByAppendingFormat:@"?key=%@",base64String];
        NSURL* url = [NSURL URLWithString:serviceUrlString];
        NSURLRequest* request = [NSURLRequest requestWithURL:url cachePolicy:NSURLCacheStorageNotAllowed
                     timeoutInterval:5.0];
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[DMService serviceQuere]
                               completionHandler:^(NSURLResponse *r, NSData *d, NSError *e) {
                                   if (e == NULL) {
                                       DMLog(@"register success");
                                   }
                                   else
                                   {
                                       DMLog(@"register failed, error = %@",e);
                                   }
                               }];
    }
}

@end
