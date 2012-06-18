//
//  DMDoubanAuthHelper.m
//  diumoo
//
//  Created by Shanzi on 12-6-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DMDoubanAuthHelper.h"
#import "CJSONDeserializer.h"
#import "NSDictionary+UrlEncoding.h"
#import "HTMLParser.h"

#define AUTH_STRING @"http://douban.fm/j/login"

static DMDoubanAuthHelper* sharedHelper;

@implementation DMDoubanAuthHelper
@synthesize username,userUrl,iconUrl,icon,userinfo;
@synthesize playedSongsCount,likedSongsCount,bannedSongsCount;

+(DMDoubanAuthHelper*) sharedHelper
{
    if(sharedHelper) return sharedHelper;
    else {
        sharedHelper = [[DMDoubanAuthHelper alloc] init];
        return  sharedHelper;
    }
}

+(NSString*) stringEncodedForAuth:(NSDictionary *)dict
{
    // 检查参数是否正确，正确的话，返回预处理过的stringbody
    // 否则返回 nil
    
    NSString* name = [dict valueForKey:kAuthAttributeUsername];
    NSString* password = [dict valueForKey:kAuthAttributePassword];
    NSString* captcha = [dict valueForKey:kAuthAttributeCaptchaSolution];
    NSString* captchacode = [dict valueForKey:kAuthAttributeCaptchaCode];
    
    if (name && password && captcha && captchacode) {
        if ([name length] && [password length] && [captcha length]
            && [captchacode length]) {
            
            
            NSString* encodedstring = [dict urlEncodedString];
            return [NSString stringWithFormat:@"remember=on&source=radio&%@",encodedstring];
        }
    }
    
    return nil;
}

+(NSString*) getNewCaptchaCode
{
    NSString* urlstring = @"http://douban.fm/j/new_captcha";
    NSURL* codeurl = [NSURL URLWithString:urlstring];
    
    NSError* codeerr = NULL;
    NSString* code = [NSString stringWithContentsOfURL:codeurl 
                                              encoding:NSASCIIStringEncoding 
                                                 error:&codeerr];
    
    if(codeerr == NULL)
    {
        return [code stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    }
    else {
        return nil;
    }
}

+(NSImage*) getNewCapchaImageWithCode:(NSString *)code
{
    NSString* urlstring = [@"http://douban.fm/misc/captcha?size=m&id=" 
                           stringByAppendingString:code];
    NSURL* imageurl = [NSURL URLWithString:urlstring];
    NSImage* image = [[NSImage alloc] initWithContentsOfURL:imageurl];
    
    return [image autorelease];
}



-(NSError*) authWithDictionary:(NSDictionary *)dict
{
    NSString* authStringBody = [DMDoubanAuthHelper stringEncodedForAuth:dict];
    
    
    // 全新登陆一个账号
    [self logoutAndCleanData];
    NSURL* urlForAuth =[NSURL URLWithString:AUTH_STRING];
    NSData* authRequestBody = [authStringBody dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest* authRequest = [NSMutableURLRequest requestWithURL:urlForAuth];
    [authRequest setHTTPMethod:@"POST"];
    [authRequest setHTTPBody:authRequestBody];
    
    
    // 发出同步请求
    NSURLResponse* response;
    NSError* error = NULL;
    NSData* data = [NSURLConnection sendSynchronousRequest:authRequest
                                         returningResponse:&response
                                                     error:&error];
    
    if(!error){
        return [self connectionResponseHandlerWithResponse:response andData:data];
    }
    else return [error autorelease];
    
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
                NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                     cid , @"id",
                                     name , @"real_name",
                                     nil];
                [array addObject:dic];
            }
        }
        return array;
    }

    return nil;
}

-(NSDictionary*) tryParseHtmlForAuthWithData:(NSData*) data
{
    NSError* herr=NULL;
    HTMLParser* parser = [[HTMLParser alloc] initWithData:data error:&herr];
    if(herr == NULL)
    {
        HTMLNode* bodynode=[parser body];
        
        HTMLNode* total=[[bodynode findChildOfClass:@"stat-total"] findChildTag:@"i"];
        HTMLNode* liked=[[bodynode findChildOfClass:@"stat-liked"] findChildTag:@"i"];
        HTMLNode* banned=[[bodynode findChildOfClass:@"stat-banned"] findChildTag:@"i"];
        HTMLNode* user=[[bodynode findChildOfClass:@"login-usr"] findChildTag:@"a"];
        
        if(total && liked && banned && user){
            NSString* userlink=[user getAttributeNamed:@"href"];
            HTMLParser* imgParser=[[HTMLParser alloc] 
                                   initWithContentsOfURL:[NSURL URLWithString:userlink]
                                   error:&herr];
            
            if(herr==NULL){
                
                HTMLNode* userfacenode=[[imgParser body] findChildOfClass:@"userface"];
                if(userfacenode){
                    
                    NSDictionary* play_record = [NSDictionary dictionaryWithObjectsAndKeys:
                                                 [total contents],@"played",
                                                 [liked contents],@"liked",
                                                 [banned contents],@"banned",nil];
                    
                    NSDictionary* user_info=[NSDictionary dictionaryWithObjectsAndKeys:
                                             [user contents],@"name",
                                             play_record,@"play_record",
                                             userlink,@"url",
                                             [userfacenode getAttributeNamed:@"src"],@"icon_url",
                                             [self djCollectionFromBodyNode:bodynode],@"collected_chls",
                                             nil];
                    
                    return [user_info autorelease];
                }
            }
        }
    }
    
    return nil;
}

-(NSError*) connectionResponseHandlerWithResponse:(NSURLResponse*) response andData:(NSData*) data
{

    NSError* jerr = NULL;
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

-(void) loginSuccessWithUserinfo:(NSDictionary*) info
{
    self.username = [info valueForKey:@"name"];
    self.userUrl = [info valueForKey:@"url"];
    self.userinfo = info;
    
    
    NSDictionary* play_record = [info valueForKey:@"play_record"];
    
    if (play_record) {
        
        self.playedSongsCount = [[play_record valueForKey:@"played"] integerValue];
        self.likedSongsCount =  [[play_record valueForKey:@"liked"] integerValue];
        self.bannedSongsCount = [[play_record valueForKey:@"banned"] integerValue];
        
    }
    
    
    NSString* _id = [info valueForKey:@"id"];
    if (_id) 
    {
        NSString* iconstring = [NSString stringWithFormat: @"http://img3.douban.com/icon/u%@.jpg",_id];
        self.iconUrl = iconstring;
    }
    else 
    {
        self.iconUrl = [info valueForKey:@"icon_url"];
    }
    
    NSURL* iconImageURL = [NSURL URLWithString:self.iconUrl];
    self.icon = [[NSImage alloc] initWithContentsOfURL:iconImageURL];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AccountStateChangedNotification 
                                                        object:self];
}

-(void) logoutAndCleanData
{
    self.username = nil;
    self.userUrl = nil;
    self.iconUrl = nil;
    self.userinfo = nil;
    self.icon = nil;
    self.playedSongsCount = 0;
    self.likedSongsCount = 0;
    self.bannedSongsCount = 0;
    
    NSURL* url = [NSURL URLWithString:AUTH_STRING];
    NSArray* cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
    
    for (NSHTTPCookie* cookie in cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AccountStateChangedNotification 
                                                        object:self];
}

-(NSImage*) getUserIcon
{
    if(self.username && self.userUrl)
    {
        if (icon==nil) {
            NSURL* url = [NSURL URLWithString:self.userUrl];
            self.icon = [[NSImage alloc] initWithContentsOfURL:url];
        }
        return icon;
    }
    return nil;
}

-(NSString*) description
{
   NSDictionary* descriptDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                self.username,@"username",
                                self.userUrl,@"userUrl",
                                self.iconUrl, @"iconUrl"
                                , nil];
    return [NSString stringWithFormat:@"<DMDoubanAuthHelper:\n%@ >",descriptDic];
}

@end
