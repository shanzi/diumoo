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
#import "NSDictionary+UrlEncoding.h"
#import "NSOrderedSet+componentsJoinedByString.h"

@interface DMPlaylistFetcher()
- (NSString *)randomString;
- (NSString *)hstring;
@end


@implementation DMPlaylistFetcher
@synthesize playlist,playedSongs,delegate;

#pragma init & dealloc

- (id)init
{
    self = [super init];
    if (self) {
        srand((int)time(0));
        playlist = [[NSMutableArray alloc] init];
        playedSongs = [[NSMutableOrderedSet alloc] init];
        
        //new 不是一个很好的 Method，个人认为，参考http://www.cnblogs.com/ulihj/archive/2011/01/15/1936342.html
    }
    return self;
}

- (void)dealloc
{
    [playlist release];
    [playedSongs release];
    [super dealloc];
}

#pragma -

#pragma stringProcess(Private)

-(NSString *) randomString
{
    return [NSString stringWithFormat:@"%lx",((rand() & 0xffffffffff) | 0x1000000000)] ;
}

-(NSString *) hstring
{
    return [playedSongs componentsJoinedByString:@"|"];
}

#pragma -

-(void) fetchPlaylistWithDictionary:(NSDictionary *)dic withStartAttribute:(NSString *)start
{
    NSString* urlString =  [PLAYLIST_FETCH_URL_BASE stringByAppendingFormat:@"?%@", 
                            [dic urlEncodedString]];
    
    #ifdef DEBUG
         NSLog(@"urlstring ----> %@",urlString);
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
             
             NSError* jerr = NULL;
             id jresponse = [[CJSONDeserializer deserializer] 
                                           deserialize:data 
                                           error:&jerr];
             if(jerr){
                 [delegate fetchPlaylistError:jerr withComment:nil];
             }
             else {
                 if([jresponse respondsToSelector:@selector(isEqualToString:)] && [jresponse isEqualToString:@"ok"])
                     [delegate fetchPlaylistSuccessWithStartSong:nil];
                 else 
                 if ([[jresponse valueForKey:@"r"] intValue] != 0) {
                     // do something when an error code is responsed
                     [delegate fetchPlaylistError:nil withComment:[jresponse valueForKey:@"err"]];
                 }
                 else {
                     // do something to update playlist
                     @try {
                         if (start){
                             NSMutableArray* songs = [NSMutableArray arrayWithArray:
                                                      [jresponse valueForKey:@"song"]];
                             
                             NSDictionary* startSong = [songs objectAtIndex:0];
                             [songs removeObjectAtIndex:0];
                             [playlist addObjectsFromArray:songs];
                             
                             [delegate fetchPlaylistSuccessWithStartSong:
                              [DMPlayableCapsule playableCapsuleWithDictionary:startSong]];
                             
                         }
                         else {
                             [playlist addObjectsFromArray:[jresponse valueForKey:@"song"]];
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
    if (type == kFetchPlaylistTypeEnd && [self.playlist count]==0) {
        type = kFetchPlaylistTypeNew;
    }
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
    
    
    [self fetchPlaylistWithDictionary:fetchDictionary withStartAttribute:startstr];
}

-(DMPlayableCapsule*) getOnePlayableCapsule
{
    if([playlist count]>0){
        id songdic = [[playlist objectAtIndex:0] retain];
        [playlist removeObject:songdic];
        return [DMPlayableCapsule playableCapsuleWithDictionary:songdic];
        [songdic release];
    }
    else return nil;
}


@end
