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
    NSString *inputString = toString(object);
    CFStringRef string = CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)inputString,NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8 );
    NSString *encodedString = [(__bridge NSString *)string copy];
    CFRelease(string);
    return encodedString;
}


@implementation NSDictionary (UrlEncoding)

- (NSString*)urlEncodedString 
{
    NSMutableArray *parts = [NSMutableArray array];
    for (id key in self) {
        id value = self[key];
        NSString* encodedkey = urlEncode(key);
        NSString* encodedValue = urlEncode(value);
        NSString *part = [NSString stringWithFormat: @"%@=%@", encodedkey, encodedValue];
        [parts addObject: part];
    }
    return [parts componentsJoinedByString: @"&"];
}

- (NSString*)hString
{
    NSMutableArray* parts = [NSMutableArray array];
    for (id key in self) {
        id value = self[key];
        NSString* part = [NSString stringWithFormat:@"%@:%@",key,value];
        [parts addObject:part];
    }
    return [parts componentsJoinedByString:@"|"];
}

@end
