//
//  DMChannelListUpdater.m
//  diumoo
//
//  Created by Shanzi on 12-6-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#define UPDATE_URL @"http://diumoo.xiuxiu.de/j/channels/"
#define DJ_EXPLORER_URL @"http://douban.fm/explore/"
#define kDMCollectChannel @"collect_channel"
#define kDMUncollectChannel @"uncollect_channel"

#import "DMChannelListHandler.h"
#import "CJSONDeserializer.h"
#import "NSDictionary+UrlEncoding.h"

@implementation DMChannelListHandler
@synthesize public_list,dj_list,dj_collected_list;


-(id) initWithCollectedChannels:(NSArray*) array
{
    self = [super init];
    if (self) {
        self.dj_collected_list = [NSMutableSet setWithCapacity:[array count]];
        [self setDjCollectListWithArray:array];
        [self updateChannelList];
    }
    return self;
}

-(void) setDjCollectListWithArray:(NSArray*)array
{
    if (array == nil) {
        [self.dj_collected_list removeAllObjects];
    }
    for (NSDictionary* dic in array) {
        NSString* cid = [NSString stringWithFormat:@"%@",[dic valueForKey:@"id"]];
        [self.dj_collected_list addObject:cid];
    }
}

-(void) updateChannelList
{
    NSString* filepath = [[NSBundle mainBundle] pathForResource:@"channels" ofType:@"plist"];
    NSDictionary* channelDict = nil;
    NSURL* updateUrl = [NSURL URLWithString:UPDATE_URL];
    NSURLRequest* urlrequest = [NSURLRequest requestWithURL:updateUrl
                                                cachePolicy:NSURLCacheStorageAllowed
                                            timeoutInterval:2.0];
    
    NSURLResponse* response = NULL;
    NSError* error = NULL;
    NSData* data = [NSURLConnection sendSynchronousRequest:urlrequest
                                         returningResponse:&response
                                                     error:&error];
    
    
    if(error==NULL){
        channelDict = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
        if(error == NULL){
            self.public_list = [channelDict valueForKey:@"public"];
            self.dj_list = [channelDict valueForKey:@"dj"];
            
            
            [channelDict writeToFile:filepath atomically:YES];
            return;
        }
    }
    channelDict = [NSDictionary dictionaryWithContentsOfFile:filepath];
    self.public_list = [channelDict valueForKey:@"public"];
    self.dj_list = [channelDict valueForKey:@"dj"];
}

-(BOOL) djChannelCollectRequestWithType:(NSString*) type andCid:(NSString*) cid
{
    
    NSURL* requestURL = [NSURL URLWithString:[DJ_EXPLORER_URL stringByAppendingString:type]];
    NSArray* cookies= [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:requestURL];
    NSString* ck = nil;
    
    for (NSHTTPCookie* cookie in cookies) {
        if([cookie.name isEqualToString:@"ck"]){
            ck = [cookie value];
        }
    }
    
    NSDictionary* formdic=[NSDictionary dictionaryWithObjectsAndKeys:
                           cid,@"channel_id",
                           ck,@"ck",nil];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:requestURL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[[formdic urlEncodedString]dataUsingEncoding:NSUTF8StringEncoding]];

    NSURLResponse* r;
    NSError* e = NULL;
    NSData* d = [NSURLConnection sendSynchronousRequest:request returningResponse:&r error:&e];
    
    if(e==NULL){
        NSDictionary* dic = [[CJSONDeserializer deserializer] deserializeAsDictionary:d error:&e];
        if(e==NULL && [[dic valueForKey:@"status"] boolValue])
        {
            return YES;
        }
    }
    return NO;
}

-(void) collectDjChannelWithChannelID:(NSString *)cid
{
    if([self.dj_collected_list containsObject:cid]) return;
    
    if([self djChannelCollectRequestWithType:kDMCollectChannel andCid:cid]){
        [self.dj_collected_list addObject:cid];
    }
}

-(void) uncollectDjChannelWithChannelId:(NSString*) cid
{
    if([self.dj_collected_list containsObject:cid])
    {
        if([self djChannelCollectRequestWithType:kDMUncollectChannel andCid:cid])
        {
            [self.dj_collected_list removeObject:cid];
        }
    }
}

@end
