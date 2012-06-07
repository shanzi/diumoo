//
//  DMPlaylistFetcher.m
//  diumoo-core
//
//  Created by Shanzi on 12-6-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#define PLAYLIST_FETCH_URL_BASE @"http://douban.fm/j/mine/playlist"
#define DOUBAN_FM_ORIGIN_URL @".douban.fm"


#import "DMPlaylistFetcher.h"

@implementation DMPlaylistFetcher
@synthesize playlist,playedSongs,delegate;

-(id)init
{
    self = [super init];
    if (self) {
        srand((int)time(0));
        playlist = [NSMutableArray new];
        playedSongs = [NSMutableArray new];
    }
    return self;
}

-(NSString*) randomString
{
    long rnd = ((rand() & 0xffffffffff) | 0x1000000000);
    return [NSString stringWithFormat:@"%lx",rnd] ;
}

-(NSString*) hstring
{
    return [[playedSongs componentsJoinedByString:@"|"] autorelease];
}

-(void) fetchPlaylistWithDictionary:(NSDictionary *)dic withStartAttribute:(NSString *)start
{
    NSString* urlString =  [PLAYLIST_FETCH_URL_BASE stringByAppendingFormat:@"?%@", 
                            [dic urlEncodedString]];
    
#ifdef DEBUG
    NSLog(@"%@",urlString);
#endif
    
    NSURLRequest* urlrequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString] 
                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                            timeoutInterval:5.0];
    
    //----------------------------处理start属性-------------------------
    NSDictionary* startAttributeCookieDict =
    [NSDictionary dictionaryWithObjectsAndKeys:
     @"douban.fm",NSHTTPCookieDomain,
     @"start",NSHTTPCookieName,
     (start?start:@""),NSHTTPCookieValue,
     @"TRUE",NSHTTPCookieDiscard,
     @"/",NSHTTPCookiePath,
     nil];
    
    
    NSHTTPCookie* startAttributeCookie = [NSHTTPCookie cookieWithProperties:startAttributeCookieDict];
    
#ifdef DEBUG
    NSLog(@"%@\n%@\n%@",startAttributeCookieDict,
          startAttributeCookie,
          [[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies] objectAtIndex:0]);
#endif
    
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:startAttributeCookie];
    

    //----------------------------------------------------------------
    
    
    [NSURLConnection sendAsynchronousRequest:urlrequest 
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:
     ^(NSURLResponse *response, NSData * data, NSError *err){

         if (err) {
             // do something when connection err
             [delegate fetchPlaylistError:err withComment:nil];
         }
         else {
             NSString* string = [NSString stringWithCString:[data bytes] encoding:NSUTF8StringEncoding];
             if ([string isEqualToString:@"OK"]) {
                 return;
             }
             
             NSError* jerr = NULL;
             NSDictionary* response_dic = [[CJSONDeserializer deserializer] 
                                           deserialize:data 
                                           error:&jerr];
             if(jerr){
                 [delegate fetchPlaylistError:jerr withComment:nil];
             }
             else {
                 if ([[response_dic valueForKey:@"r"] intValue] != 0) {
                     // do something when an error code is responsed
                     [delegate fetchPlaylistError:nil withComment:[response_dic valueForKey:@"err"]];
                 }
                 else {
                     // do something to update playlist
                     @try {
                         if (start){
                             NSMutableArray* songs = [NSMutableArray arrayWithArray:
                                                      [response_dic valueForKey:@"song"]];
                             
                             NSDictionary* startSong = [songs objectAtIndex:0];
                             [songs removeObjectAtIndex:0];
                             [playlist addObjectsFromArray:songs];
                             
                             [delegate fetchPlaylistSuccessWithStartSong:
                              [DMPlayableCapsule playableCapsuleWithDictionary:startSong]];
                             
                         }
                         else {
                             [playlist addObjectsFromArray:[response_dic valueForKey:@"song"]];
                             [delegate fetchPlaylistSuccessWithStartSong:nil];
                         }
                     }
                     @catch (NSException *exception) {
                         // throw exception
                         [delegate fetchPlaylistError:nil withComment:@"update playlist error"];
                     }
                 }
             }
         }
         
    }];
}

-(void) fetchPlaylistFromChannel:(NSString* )channel
                        withType:(NSString *)type
                             sid:(NSString *)sid
                  startAttribute:(NSString *)startstr
{
    if(sid && ![type isEqualToString:kFetchPlaylistTypeNew])
    {
        [playedSongs addObject:[NSString stringWithFormat:@"%@:%@",sid,type]];
        while([playedSongs count] > 40) [playedSongs removeObjectAtIndex:0];
    }
    
    
    NSDictionary* fetchDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                     type,@"type",
                                     channel,@"channel",
                                     (sid?sid:@""),@"sid",
                                     [self hstring],@"h",
                                     [self randomString],@"r",
                                     @"mainsite",@"from",
                                      nil];
    
#ifdef DEBUG
    NSLog(@"here");
    NSLog(@"%@",fetchDictionary);
#endif
    
    [self fetchPlaylistWithDictionary:fetchDictionary withStartAttribute:startstr];
}


@end
