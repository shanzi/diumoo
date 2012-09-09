//
//  DMDoubanAuthHelper.m
//  diumoo
//
//  Created by Shanzi on 12-6-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DMDoubanAuthHelper.h"
#import "DMErrorLog.h"

static DMDoubanAuthHelper* sharedHelper;

@implementation DMDoubanAuthHelper
@synthesize username,icon,userinfo,promotion_chls,recent_chls;
@synthesize playedSongsCount,likedSongsCount,bannedSongsCount;


#pragma class methods

+(DMDoubanAuthHelper*) sharedHelper
{
    if(sharedHelper == nil) {
        sharedHelper = [[DMDoubanAuthHelper alloc] init];
    }
    return sharedHelper;
}

+(NSString*) getNewCaptchaCode
{    
    NSError* error;
    NSString* code = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://douban.fm/j/new_captcha"] 
                                              encoding:NSASCIIStringEncoding 
                                                 error:&error];
    if(error != nil){
        [DMErrorLog logErrorWith:self method:_cmd andError:error];
        return @"";
    }
    
    return [code stringByReplacingOccurrencesOfString:@"\"" withString:@""];
}

#pragma -

#pragma dealloc


#pragma -

#pragma public methods

-(NSError*) authWithDictionary:(NSDictionary *)dict
{
    NSString* authStringBody = [self stringEncodedForAuth:dict];
    
    NSMutableURLRequest* authRequest =nil;
    if(authStringBody)
    {
        [self logoutAndCleanData];
        NSData* authRequestBody = [authStringBody dataUsingEncoding:NSUTF8StringEncoding];
        authRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:AUTH_STRING]];
        [authRequest setHTTPMethod:@"POST"];
        [authRequest setHTTPBody:authRequestBody];
    }
    else
    {
        authRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:DOUBAN_FM_INDEX]];
        [authRequest setHTTPMethod:@"GET"];
    }

    [authRequest setTimeoutInterval:20.0];
    
    
    // 发出同步请求
    NSURLResponse* response;
    NSError* error = nil;
    NSData* data = [NSURLConnection sendSynchronousRequest:authRequest
                                         returningResponse:&response
                                                     error:&error];
    
    if(error){
        [DMErrorLog logErrorWith:self method:_cmd andError:error];
        return nil;
    }
    
    return [self connectionResponseHandlerWithResponse:response andData:data];
    
}
-(void) logoutAndCleanData
{
    username = nil;
    userUrl = nil;
    userinfo = nil;
    icon = nil;
    playedSongsCount = 0;
    likedSongsCount = 0;
    bannedSongsCount = 0;
    NSArray* cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:DOUBAN_FM_INDEX]];
    
    for (NSHTTPCookie* cookie in cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AccountStateChangedNotification 
                                                        object:self];
}

-(NSImage*) getUserIcon
{
    if(userinfo && icon) {
        return icon;
    }
    return [NSImage imageNamed:NSImageNameUser];
}

#pragma -

#pragma private methods

-(void) fetchPromotionAndRecentChannel
{
    NSURL* promotion_url = [NSURL URLWithString:PROMOTION_CHLS_URL];
    NSURL* recent_url = [NSURL URLWithString:RECENT_CHLS_URL];
    NSURLRequest* promotion_request = [NSURLRequest requestWithURL:promotion_url
                                       cachePolicy:NSURLCacheStorageAllowed
                                                   timeoutInterval:10.0
                                       ];
    NSURLRequest* recent_request = [NSURLRequest requestWithURL:recent_url
                                                    cachePolicy:NSURLCacheStorageAllowed
                                                timeoutInterval:10.0
                                    ];
    NSData* promotion_data = [NSURLConnection sendSynchronousRequest:promotion_request
                                                   returningResponse:nil
                                                               error:nil];
    NSData* recent_data = [NSURLConnection sendSynchronousRequest:recent_request
                                                returningResponse:nil
                                                            error:nil];
    
    if (promotion_data) {
        NSDictionary* dict = [[CJSONDeserializer deserializer]
                              deserializeAsDictionary:promotion_data
                              error:nil];
        if (dict && dict[@"status"]) {
            promotion_chls = dict[@"data"][@"chls"];
        }
    }
    
    if (recent_data) {
        NSDictionary* dict = [[CJSONDeserializer deserializer]
                              deserializeAsDictionary:recent_data
                              error:nil];
        if (dict && dict[@"status"]) {
            recent_chls = dict[@"data"][@"chls"];
        }
    }
}

-(void) loginSuccessWithUserinfo:(NSDictionary*) info
{
    [self fetchPromotionAndRecentChannel];
    
    username = [info valueForKey:@"name"];
    userUrl = [info valueForKey:@"url"];
    userinfo = info;
    
    NSDictionary* play_record = [info valueForKey:@"play_record"];
    
    if (play_record) {
        playedSongsCount = [[play_record valueForKey:@"played"] integerValue];
        likedSongsCount =  [[play_record valueForKey:@"liked"] integerValue];
        bannedSongsCount = [[play_record valueForKey:@"banned"] integerValue];
    }
    
    
    
    NSString* _id = [info valueForKey:@"id"];
    if (_id) {
        NSString* iconstring = [NSString stringWithFormat: @"http://img3.douban.com/icon/u%@.jpg",_id];
        icon = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:iconstring]];
    }
    else {
        icon = [NSImage imageNamed:NSImageNameUser];
    }
    
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AccountStateChangedNotification 
                                                        object:self];
}

-(NSString*) stringEncodedForAuth:(NSDictionary *)dict
{
    // 检查参数是否正确，正确的话，返回预处理过的stringbody
    // 否则返回 nil
    
    NSString *name = [dict valueForKey:kAuthAttributeUsername];
    NSString *password = [dict valueForKey:kAuthAttributePassword];
    NSString *captcha = [dict valueForKey:kAuthAttributeCaptchaSolution];
    NSString *captchacode = [dict valueForKey:kAuthAttributeCaptchaCode];
    
    if ([name length] && [password length] && [captcha length] && [captchacode length]) {
        return [NSString stringWithFormat:@"remember=on&source=radio&%@",[dict urlEncodedString]];
    }
    
    return nil;
}


-(NSString*) user_id
{
    NSURL* url = [NSURL URLWithString:DOUBAN_FM_INDEX];
    NSArray* cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
    
    
    for (NSHTTPCookie* cookie in cookies) {
        if ([[cookie name] isEqualToString:@"dbcl2"]) {
            NSString* dbcl2 = [cookie value];
            NSArray* array = [dbcl2 componentsSeparatedByString:@":"];
            if ([array count]>1) {
                NSString* _id = array[0];
                return [_id stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            }
        }
    }
    return nil;
}

-(NSDictionary*) tryParseHtmlForAuthWithData:(NSData*) data
{
    NSError* herr=nil;
    HTMLParser* parser = [[HTMLParser alloc] initWithData:data error:&herr];
    if(herr == nil)
    {
        HTMLNode* bodynode=[parser body];
        
        HTMLNode* total=[bodynode findChildWithAttribute:@"id" matchingName:@"rec_played" allowPartial:NO];
        HTMLNode* liked=[bodynode findChildWithAttribute:@"id" matchingName:@"rec_liked" allowPartial:NO];
        HTMLNode* banned=[bodynode findChildWithAttribute:@"id" matchingName:@"rec_banned" allowPartial:NO];
        HTMLNode* user=[bodynode findChildWithAttribute:@"id" matchingName:@"user_name" allowPartial:NO];
        NSString* user_id = [self user_id];
        
        if(total && liked && banned && user && user_id){
            NSString* userlink = [@"http://www.douban.com/people/" stringByAppendingString:user_id];
            NSDictionary* play_record = @{
            @"played": [total contents],
            @"liked": [liked contents],
            @"banned": [banned contents]};
            
            NSDictionary* user_info=@{
            @"name": [user contents],
            @"play_record": play_record,
            @"url": userlink,
            @"id":user_id,
            };
            
            return user_info ;
        }
    }
    return nil;
}


-(NSError*) connectionResponseHandlerWithResponse:(NSURLResponse*) response andData:(NSData*) data
{
    NSError* jerr = nil;
    NSDictionary* obj = [[CJSONDeserializer deserializer] deserialize:data error:&jerr];
    
    if(jerr){
        // 返回的内容不能解析成json，尝试解析HTML获得用户登陆信息
        NSDictionary* info = [self tryParseHtmlForAuthWithData:data];
        if (info) {
            // 登陆成功，此时无需重新记录cookie
            [self loginSuccessWithUserinfo:info];
        }
        else {
            // 登陆失败
            NSError *error = [NSError errorWithDomain:@"DM Auth Error" code:-1 userInfo:nil];
            [DMErrorLog logErrorWith:self method:_cmd andError:error];
            return error;
        }
    }
    else {
        // json解析成功
        if([[obj valueForKey:@"r"] intValue] == 0){
            // 登陆成功
            // 将cookie记录下来
            NSArray *cookies = [NSHTTPCookie 
                                cookiesWithResponseHeaderFields:
                                [response  performSelector:@selector(allHeaderFields)]
                                forURL:[response URL]] ;
            
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:cookies
                                                               forURL:[NSURL URLWithString:DOUBAN_FM_INDEX]
                                                      mainDocumentURL:nil];
            
            
            [self loginSuccessWithUserinfo:[obj valueForKey:@"user_info"]];
        }
        else {
            // 登陆失败
            NSError *error = [NSError errorWithDomain:@"DM Auth Error" code:-2
                                             userInfo:[obj valueForKey:@"err_msg"]];
            //[DMErrorLog logErrorWith:self method:_cmd andError:error];
            return error;
        }
    }
    return nil;
}

#pragma -

@end
