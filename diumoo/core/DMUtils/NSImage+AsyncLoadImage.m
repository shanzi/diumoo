//
//  NSImage+AsyncLoadImage.m
//  diumoo
//
//  Created by Shanzi on 12-7-30.
//
//

#import "NSImage+AsyncLoadImage.h"

@implementation NSImage (AsyncLoadImage)
+(void)AsyncLoadImageWithURLString:(NSString*) urlstring andCallBackBlock:(void(^)(NSImage*))block
{
    NSURL* url = [NSURL URLWithString:urlstring];
    NSURLRequest* request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLCacheStorageAllowed
                                         timeoutInterval:3.0];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *r, NSData *d, NSError *e) {
                               
                               if (block) {
                                   if (e==NULL) {
                                       NSImage* image = [[NSImage alloc] initWithData:d];
                                       block(image);
                                   }
                                   else{
                                       block(nil);
                                   }
                               }
                           }];
}
@end
