//
//  NSImage+AsyncLoadImage.m
//  diumoo
//
//  Created by Shanzi on 12-7-30.
//
//

#import "NSImage+AsyncLoadImage.h"
#import "DMErrorLog.h"

@implementation NSImage (AsyncLoadImage)
+(void)AsyncLoadImageWithURLString:(NSString*) urlstring andCallBackBlock:(void(^)(NSImage*))block
{
    dispatch_queue_t imageLoadQueue = dispatch_queue_create("DMImageLoad", NULL);
    dispatch_queue_t high = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0);
    dispatch_set_target_queue(imageLoadQueue, high);
    
    dispatch_async(imageLoadQueue, ^{
        
        NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlstring]
                                                 cachePolicy: NSURLRequestUseProtocolCachePolicy
                                             timeoutInterval:3.0];
        NSURLResponse *response;
        NSError *error;
        NSData *imageData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        if (error) {
            [DMErrorLog logErrorWith:self method:_cmd andError:error];
        }
        
        if (block) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                block([[NSImage alloc] initWithData:imageData]);
            });
        }
    });
}
@end
