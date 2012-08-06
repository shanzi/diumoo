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
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlstring]
                                             cachePolicy:NSURLCacheStorageAllowed
                                         timeoutInterval:3.0];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               DMLog(@"Load image with error = %@",error);
                               
                               if (block) {
                                   //initWithData returns nil when data is empty.
                                    block([[[NSImage alloc] initWithData:data] autorelease]);
                               }
                           }];
}
@end
