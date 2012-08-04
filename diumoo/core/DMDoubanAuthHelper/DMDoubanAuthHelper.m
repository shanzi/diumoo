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
-(void) loginSuccessWithUserinfo:(NSDictionary*) info;
-(NSError*) connectionResponseHandlerWithResponse:(NSURLResponse*) response andData:(NSData*) data;

@end

@implementation DMDoubanAuthHelper
@synthesize username,userUrl,iconUrl,icon,userinfo;
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
    NSError* codeerr = nil;
    NSString* code = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://douban.fm/j/new_captcha"] 
                                              encoding:NSASCIIStringEncoding 
                                                 error:&codeerr];
    if(codeerr == nil)
    {
        return [code stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    }
    
    return nil;
}

+(NSImage*) getNewCapchaImageWithCode:(NSString *)code
{
    NSImage* image = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:
                                                             [@"http://douban.fm/misc/captcha?size=m&id=" stringByAppendingString:code]]];
    return [image autorelease];
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
    self.username = nil;
    self.userUrl = nil;
    self.iconUrl = nil;
    self.userinfo = nil;
    self.icon = nil;
    self.playedSongsCount = 0;
    self.likedSongsCount = 0;
    self.bannedSongsCount = 0;
    
    NSArray* cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:AUTH_STRING]];
    
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
            self.icon = [[[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:self.userUrl]] autorelease];
        }
        return icon;
    }
    return nil;
}

#pragma -

#pragma private methods

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
    
    self.icon = [[[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:self.iconUrl]] autorelease];
    
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
        
        HTMLNode* total=[[bodynode findChildOfClass:@"stat-total"] findChildTag:@"i"];
        HTMLNode* liked=[[bodynode findChildOfClass:@"stat-liked"] findChildTag:@"i"];
        HTMLNode* banned=[[bodynode findChildOfClass:@"stat-banned"] findChildTag:@"i"];
        HTMLNode* user=[[bodynode findChildOfClass:@"login-usr"] findChildTag:@"a"];
        
        if(total && liked && banned && user){
            NSString* userlink=[user getAttributeNamed:@"href"];
            HTMLParser* imgParser=[[HTMLParser alloc] 
                                   initWithContentsOfURL:[NSURL URLWithString:userlink]
                                   error:&herr];
            if(herr==nil){
                
                HTMLNode* userfacenode=[[imgParser body] findChildOfClass:@"userface"];
                if(userfacenode){
                    
                    NSDictionary* play_record = @{@"played": [total contents],
                                                 @"liked": [liked contents],
                                                 @"banned": [banned contents]};
                    
                    NSDictionary* user_info=@{@"name": [user contents],
                                             @"play_record": play_record,
                                             @"url": userlink,
                                             @"icon_url": [userfacenode getAttributeNamed:@"src"],
                                             @"collected_chls": [self djCollectionFromBodyNode:bodynode]};
                    [imgParser release];
                    [parser release];
                    return user_info ;
                }
            }
            [imgParser release];
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

-(NSString*) description
{
    NSDictionary* descriptDict = @{@"username": self.username,
                                  @"userUrl": self.userUrl,
                                  @"iconUrl": self.iconUrl};
    return [NSString stringWithFormat:@"<DMDoubanAuthHelper:\n%@ >",descriptDict];
}


@end
