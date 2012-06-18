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

#import <Foundation/Foundation.h>

@interface DMDoubanAuthHelper : NSObject
//{

@property(copy) NSString* username;
@property(copy) NSString* userUrl;
@property(copy) NSString* iconUrl;
@property(retain) NSImage* icon;
@property(retain) NSDictionary* userinfo;


@property NSInteger playedSongsCount;
@property NSInteger likedSongsCount;
@property NSInteger bannedSongsCount;

//}

+(DMDoubanAuthHelper*) sharedHelper;
+(NSString*) stringEncodedForAuth:(NSDictionary*) dict;
+(NSString*) getNewCaptchaCode; 
+(NSImage*) getNewCapchaImageWithCode:(NSString*) code;


-(NSError*) authWithDictionary:(NSDictionary*) dict;
-(void) logoutAndCleanData;

-(NSImage*) getUserIcon;


@end
