//
//  DMDoubanAuthHelper.m
//  diumoo
//
//  Created by Shanzi on 12-6-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DMDoubanAuthHelper.h"

static DMDoubanAuthHelper* sharedHelper;

@interface DMDoubanAuthHelper()

-(void) loginSuccessWithUserinfo:(NSDictionary*) info;
-(NSString*) stringEncodedForAuth:(NSDictionary*) dict;
-(NSArray*) djCollectionFromBodyNode:(HTMLNode*) body;
-(NSDictionary*) tryParseHtmlForAuthWithData:(NSData*) data;
-(NSError*) connectionResponseHandlerWithResponse:(NSURLResponse*) response andData:(NSData*) data;

@end

@implementation DMDoubanAuthHelper
@synthesize username,userUrl,icon,userinfo;
@synthesize playedSongsCount,likedSongsCount,bannedSongsCount;


#pragma class methods

+(DMDoubanAuthHelper*) sharedHelper
{
    if(sharedHelper == nil) 
    {
        sharedHelper = [[DMDoubanAuthHelper alloc] init];
    }
    return sharedHelper;
}

+(NSString*) getNewCaptchaCode
{    
    NSError* error = nil;
    NSString* code = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://douban.fm/j/new_captcha"] 
                                              encoding:NSASCIIStringEncoding 
                                                 error:&error];
    if(error == nil)
    {
        return [code stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    }
    
    return nil;
}

#pragma -

#pragma dealloc

-(void) dealloc
{
    [username release];
    [userUrl release];
    [iconUrl release];
    [icon release];
    [userinfo release];
    [super dealloc];
}

#pragma -

#pragma public methods

-(NSError*) authWithDictionary:(NSDictionary *)dict
{
    NSString* authStringBody = [self stringEncodedForAuth:dict];
    
    if(authStringBody)
        [self logoutAndCleanData];
    
    NSData* authRequestBody = [authStringBody dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest* authRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:AUTH_STRING]];
    [authRequest setHTTPMethod:@"POST"];
    [authRequest setHTTPBody:authRequestBody];
    [authRequest setTimeoutInterval:5.0];
    
    
    // 发出同步请求
    NSURLResponse* response;
    NSError* error = nil;
    NSData* data = [NSURLConnection sendSynchronousRequest:authRequest
                                         returningResponse:&response
                                                     error:&error];
    
    if(!error){
        return [self connectionResponseHandlerWithResponse:response andData:data];
    }
    
    return error;
    
}
-(void) logoutAndCleanData
{
    username = nil;
    userUrl = nil;
    iconUrl = nil;
    userinfo = nil;
    icon = nil;
    playedSongsCount = 0;
    likedSongsCount = 0;
    bannedSongsCount = 0;
    
    NSArray* cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:AUTH_STRING]];
    
    for (NSHTTPCookie* cookie in cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:AccountStateChangedNotification 
                                                        object:self];
}

-(NSImage*) getUserIcon
{
    if(username && userUrl)
    {
        return icon;
    }
    return nil;
}

#pragma -

#pragma private methods

-(void) loginSuccessWithUserinfo:(NSDictionary*) info
{
    username = [info valueForKey:@"name"];
    userUrl = [info valueForKey:@"url"];
    userinfo = info;
    
    DMLog(@"userURL = %@",userUrl);
    
    NSDictionary *play_record = [info valueForKey:@"play_record"];
    
    if (play_record) {
        playedSongsCount = [[play_record valueForKey:@"played"] integerValue];
        likedSongsCount =  [[play_record valueForKey:@"liked"] integerValue];
        bannedSongsCount = [[play_record valueForKey:@"banned"] integerValue];
    }
    
    NSString *_id = [info valueForKey:@"id"];
    if (_id) {
        iconUrl = [NSString stringWithFormat: @"http://img3.douban.com/icon/u%@.jpg",_id];
    }
    
    icon = [[[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:iconUrl]] autorelease];
    
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

-(NSArray*) djCollectionFromBodyNode:(HTMLNode*) body
{
    HTMLNode* ulnode = [[body findChildWithAttribute:@"id" 
                                        matchingName:@"collection"
                                        allowPartial:NO] findChildTag:@"ul"];
    if (ulnode) {
        NSArray* children = [ulnode children];
        NSMutableArray* array = [NSMutableArray arrayWithCapacity:[children count]];
        for (HTMLNode* node in children) {
            
            HTMLNode* anode = [node findChildOfClass:@"chl_name"];
            
            NSString* cid = [node getAttributeNamed:@"data-cid"];
            NSString* name = [anode getAttributeNamed:@"data-name"];
            
            if (cid && name) {
                NSDictionary* dict = @{@"id": cid,
                                      @"real_name": name};
                [array addObject:dict];
            }
        }
        return array;
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
        HTMLNode *spans = nil;
        HTMLNode *total = nil;
        HTMLNode *liked = nil;
        HTMLNode *banned = nil;
        HTMLNode *user = nil;
        
        NSArray *spanNode = [bodynode findChildTags:@"span"];

        for (spans in spanNode){
            if ([[spans getAttributeNamed:@"id"] isEqualToString:@"rec_played"]) {
                total=spans;
            }
            if ([[spans getAttributeNamed:@"id"] isEqualToString:@"rec_liked"]) {
                liked=spans;
            }
            if ([[spans getAttributeNamed:@"id"] isEqualToString:@"rec_banned"]) {
                banned=spans;
            }
            if ([[spans getAttributeNamed:@"id"] isEqualToString:@"user_name"]) {
                user=spans;
            }
        }
        
        DMLog(@"total = %@, liked = %@, banned = %@, user = %@",[total contents],[liked contents],[banned contents],[user contents]);
        
        if(total && liked && banned && user){
            // prase cookie to get user id
            NSString *userid = nil;
            for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
                if ([[cookie name] isEqualToString:@"dbcl2"]) {
                    userid = [[[[cookie value]componentsSeparatedByString:@":"] objectAtIndex:0] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                }
            }
            NSDictionary* play_record = @{@"played": [total contents],
                                           @"liked": [liked contents],
                                          @"banned": [banned contents]};
                    
            NSDictionary* user_info=@{@"name": [user contents],
                               @"play_record": play_record,
                                        @"id": userid,
                                       @"url": [@"http://www.douban.com/people/" stringByAppendingString:userid]};
            [parser release];
            return user_info ;
            }
    }
    [parser release];
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
            return [NSError errorWithDomain:@"DM Auth Error" code:-1 userInfo:nil];
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
            DMLog(@"cookie = %@",cookies);
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:cookies
                                                               forURL:[response URL]
                                                      mainDocumentURL:nil];
            
            
            [self loginSuccessWithUserinfo:[obj valueForKey:@"user_info"]];
        }
        else {
            // 登陆失败
            return [NSError errorWithDomain:@"DM Auth Error" code:-2 
                                   userInfo:[obj valueForKey:@"err_msg"]];
        }
    }
    return nil;
}

#pragma -
@end
