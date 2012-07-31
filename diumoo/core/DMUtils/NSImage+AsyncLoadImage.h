//
//  NSImage+AsyncLoadImage.h
//  diumoo
//
//  Created by Shanzi on 12-7-30.
//
//

#import <Cocoa/Cocoa.h>

@interface NSImage (AsyncLoadImage)
+(void)AsyncLoadImageWithURLString:(NSString*) urlstring andCallBackBlock:(void(^)(NSImage*))block;
@end
