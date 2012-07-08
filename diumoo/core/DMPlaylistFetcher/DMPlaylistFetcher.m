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

@interface DMPlaylistFetcher()
{
    NSMutableArray *playlist;
    NSMutableDictionary *playedSongs;
}

@property(assign) NSMutableArray *playlist;
@property(assign) NSMutableDictionary *playedSongs;

- (NSString*)randomString;
- (void)fetchPlaylistWithDictionary:(NSDictionary*)dict withStartAttribute:(NSString*)startAttr;

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
        playedSongs = [[NSMutableDictionary alloc] init];        
    }
    return self;
}

- (void)dealloc
{
    self.delegate = nil;
    [playlist release];
    [playedSongs release];
    [super dealloc];
}

#pragma -

#pragma stringProcess(Private)

- (NSString*)randomString
{
    int rand1 = rand();
    int rand2 = rand();
    return [NSString stringWithFormat:@"%5x%5x",((rand1 & 0xfffff) | 0x10000),rand2] ;
}

#pragma -

- (void)fetchPlaylistWithDictionary:(NSDictionary *)dict withStartAttribute:(NSString *)startAttr
{
    NSString* urlString =  [PLAYLIST_FETCH_URL_BASE stringByAppendingFormat:@"?%@", 
                            [dict urlEncodedString]];
    
    DMLog(@"startattr,%@",startAttr);
    
    NSURLRequest* urlrequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString] 
                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                            timeoutInterval:5.0];
    
    //----------------------------处理start属性-------------------------
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:[NSHTTPCookie cookieWithProperties:
                                                              [NSDictionary dictionaryWithObjectsAndKeys:
                                                                @"douban.fm",NSHTTPCookieDomain,
                                                                    @"start",NSHTTPCookieName,
                                                   (startAttr?startAttr:@""),NSHTTPCookieValue,
                                                                     @"TRUE",NSHTTPCookieDiscard,
                                                                        @"/",NSHTTPCookiePath, nil]]];

    //----------------------------------------------------------------
    
    [NSURLConnection sendAsynchronousRequest:urlrequest 
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData * data, NSError *err){

         if (err) {
             // do something when connection err
             [delegate fetchPlaylistError:err withComment:nil];
         }
         else {
             NSError* jerr = nil;
             id jresponse = [[CJSONDeserializer deserializer] deserialize:data error:&jerr];
             
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
                         if (startAttr){
                             
                             playlist = [NSMutableArray arrayWithArray:[jresponse valueForKey:@"song"]];
                             [delegate fetchPlaylistSuccessWithStartSong:
                             [DMPlayableCapsule playableCapsuleWithDictionary:[playlist objectAtIndex:0]]];
                             [playlist removeObjectAtIndex:0];
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

- (void)fetchPlaylistFromChannel:(NSString*)channel withType:(NSString*)type sid:(NSString*)sid startAttribute:(NSString*)startAttr
{
    if (type == kFetchPlaylistTypeEnd && [self.playlist count]==0) {
        type = kFetchPlaylistTypeNew;
    }
    if(sid && ![type isEqualToString:kFetchPlaylistTypeNew])
    {
        [playedSongs setValue:type forKey:sid];
    }
    
    NSDictionary* fetchDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                     type,@"type",
                                     channel,@"channel",
                                     (sid?sid:@""),@"sid",
                                     [self.playedSongs hString],@"h",
                                     [self randomString],@"r",
                                     @"mainsite",@"from",
                                      nil];
    
    [self fetchPlaylistWithDictionary:fetchDictionary withStartAttribute:startAttr];
}

- (DMPlayableCapsule*)getOnePlayableCapsule
{
    if([playlist count]>0){
        NSDictionary *songDict = [[[playlist objectAtIndex:0] retain] autorelease];
        [playlist removeObjectAtIndex:0];
        return [DMPlayableCapsule playableCapsuleWithDictionary:songDict];
    }
    else 
        return nil;
}

-(void) clearPlaylist
{
    [self.playlist removeAllObjects];
}

@end
