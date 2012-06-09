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

@implementation DMDoubanAuthHelper
@synthesize username,userId,userUrl,iconUrl,icon;
@synthesize playedSongsCount,likedSongsCount,bannedSongsCount;

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

-(void) authWithDictionary:(NSDictionary *)dict asynchronousRequest:(BOOL)asyn
{
    NSString* authStringBody = [DMDoubanAuthHelper stringEncodedForAuth:dict];
    if(authStringBody)
    {
        // 全新登陆一个账号
        [self logoutAndCleanData];
        NSURL* urlForAuth =[NSURL URLWithString:AUTH_STRING];
        NSData* authRequestBody = [authStringBody dataUsingEncoding:NSUTF8StringEncoding];
        
        NSMutableURLRequest* authRequest = [NSMutableURLRequest requestWithURL:urlForAuth];
        [authRequest setHTTPMethod:@"POST"];
        [authRequest setHTTPBody:authRequestBody];
        
        if (asyn) 
        {
            // 发出异步请求
            [NSURLConnection sendAsynchronousRequest:authRequest
                                               queue:[NSOperationQueue currentQueue]
                                   completionHandler:
             ^(NSURLResponse *r, NSData *d, NSError *e) {
                 if (!e) {
                     // 连接成功
                     [self connectionResponseHandlerWithResponse:r andData:d];
                 }
             }];
        }
        else {
            // 发出同步请求
            NSURLResponse* response;
            NSError* error;
            NSData* data = [NSURLConnection sendSynchronousRequest:authRequest
                                  returningResponse:&response
                                              error:&error];
            
            if(!error){
                [self connectionResponseHandlerWithResponse:response andData:data];
            }
            
        }
    }
    else {
    }
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
                               [userfacenode getAttributeNamed:@"src"],@"userface",
                               nil];
                    
                    return [user_info autorelease];
                }
            }
        }
    }
    
    return nil;
}

-(void) connectionResponseHandlerWithResponse:(NSURLResponse*) response andData:(NSData*) data
{
    NSError* jerr;
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
        }
    }
}

-(void) loginSuccessWithUserinfo:(NSDictionary*) userinfo
{
    
}

-(void) logoutAndCleanData
{
    
}

@end
