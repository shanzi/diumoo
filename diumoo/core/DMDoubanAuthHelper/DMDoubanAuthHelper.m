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
            
            NSMutableDictionary* authdict = [NSMutableDictionary dictionaryWithCapacity:6];
            [authdict addEntriesFromDictionary:dict];
            [authdict setValue:@"radio" forKey:@"source"];
            [authdict setValue:@"on" forKey:@"remember"];
            
            return [authdict urlEncodedString];
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
            // 登陆成功
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
