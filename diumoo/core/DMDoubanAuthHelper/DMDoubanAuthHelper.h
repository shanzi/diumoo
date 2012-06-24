//
//  DMDoubanAuthHelper.h
//  diumoo
//
//  Created by Shanzi on 12-6-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#define kAuthAttributeUsername @"alias"
#define kAuthAttributePassword @"form_password"
#define kAuthAttributeCaptchaSolution @"captcha_solution"
#define kAuthAttributeCaptchaCode @"captcha_id"

#define AccountStateChangedNotification @"accountstatechanged"
#define AUTH_STRING @"http://douban.fm/j/login"


#import <Foundation/Foundation.h>
#import "CJSONDeserializer.h"
#import "NSDictionary+UrlEncoding.h"
#import "HTMLParser.h"

@interface DMDoubanAuthHelper : NSObject
{   
    NSString *username;
    NSString *userUrl;
    NSString *iconUrl;
    NSImage  *icon;
    NSDictionary *userinfo;
    
    NSInteger playedSongsCount;
    NSInteger likedSongsCount;
    NSInteger bannedSongsCount;
}

@property(copy) NSString *username;
@property(copy) NSString *userUrl;
@property(copy) NSString *iconUrl;
@property(retain) NSImage *icon;
@property(retain) NSDictionary *userinfo;
@property NSInteger playedSongsCount;
@property NSInteger likedSongsCount;
@property NSInteger bannedSongsCount;

+(DMDoubanAuthHelper*) sharedHelper;
+(NSString*) getNewCaptchaCode; 
+(NSImage*) getNewCapchaImageWithCode:(NSString*) code;

-(NSError*) authWithDictionary:(NSDictionary*) dict;
-(void) logoutAndCleanData;
-(NSImage*) getUserIcon;

@end
