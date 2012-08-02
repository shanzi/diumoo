//
//  NSDictionary+UrlEncoding.m
//  diumoo-core
//
//  Created by Shanzi on 12-6-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSDictionary+UrlEncoding.h"


static NSString *toString(id object) 
{
    return [NSString stringWithFormat: @"%@", object];
}

static NSString *urlEncode(id object) 
{
    NSString *string = toString(object);
    NSString *encodedString = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)string,NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8 );
    return encodedString;
}


@implementation NSDictionary (UrlEncoding)

- (NSString*)urlEncodedString 
{
    NSMutableArray *parts = [NSMutableArray array];
    for (id key in self) {
        id value = [self objectForKey: key];
        NSString *part = [NSString stringWithFormat: @"%@=%@", urlEncode(key), urlEncode(value)];
        [parts addObject: part];
    }
    return [parts componentsJoinedByString: @"&"];
}

- (NSString*)hString
{
    NSMutableArray* parts = [NSMutableArray array];
    for (id key in self) {
        id value = [self objectForKey:key];
        NSString* part = [NSString stringWithFormat:@"%@:%@",key,value];
        [parts addObject:part];
    }
    return [parts componentsJoinedByString:@"|"];
}

@end
