//
//  NSDictionary+UrlEncoding.h
//  diumoo-core
//
//  代码来自: http://stackoverflow.com/questions/718429/creating-url-query-parameters-from-nsdictionary-objects-in-objectivec
//
//  Created by Shanzi on 12-6-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (UrlEncoding)
- (NSString*)urlEncodedString;
- (NSString*)hString;
@end
