//
//  DMPlaylistFetcher.m
//  diumoo-core
//
//  Created by Shanzi on 12-6-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#define PLAYLIST_FETCH_URL_BASE @"http://douban.fm/j/mine/playlist"
#define DOUBAN_FM_ORIGIN_URL @".douban.fm"
#define DM_ALBUM_GET_URL @"http://127.0.0.1:8000/album/"


#import "DMPlaylistFetcher.h"
#import "NSDictionary+UrlEncoding.h"

@interface DMPlaylistFetcher()
{
    NSMutableArray *playlist;
    NSMutableDictionary *playedSongs;
}

@property(retain) NSMutableArray *playlist;
@property(retain) NSMutableDictionary *playedSongs;

- (NSString*)randomString;

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

- (void)fetchPlaylistWithDictionary:(NSDictionary *)dict withStartAttribute:(NSString *)startAttr  andErrorCount:(NSInteger)errcount
{
    NSString* urlString =  [PLAYLIST_FETCH_URL_BASE stringByAppendingFormat:@"?%@", 
                            [dict urlEncodedString]];
    
    
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
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData * data, NSError *err){

         if (err) {
             // do something when connection err
             [delegate fetchPlaylistError:err withDictionary:dict
                           startAttribute:startAttr
                            andErrorCount:(errcount)];
         }
         else {
             NSError* jerr = nil;
             id jresponse = [[CJSONDeserializer deserializer] deserialize:data error:&jerr];
             
             if(jerr){
                 [delegate fetchPlaylistError:jerr withDictionary:dict
                               startAttribute:startAttr
                                andErrorCount:errcount ];
             }
             else {
                 if([jresponse respondsToSelector:@selector(isEqualToString:)] && [jresponse isEqualToString:@"ok"])
                     [delegate fetchPlaylistSuccessWithStartSong:nil];
                 else 
                 if ([[jresponse valueForKey:@"r"] intValue] != 0) {
                     // do something when an error code is responsed
                     [delegate fetchPlaylistError:nil withDictionary:dict startAttribute:startAttr andErrorCount:errcount];
                 }
                 else {
                     // do something to update playlist
                     @try {
                         if (startAttr){
                             
                             self.playlist = [NSMutableArray arrayWithArray:[jresponse valueForKey:@"song"]];
                             [delegate fetchPlaylistSuccessWithStartSong:
                             [DMPlayableCapsule playableCapsuleWithDictionary:[playlist objectAtIndex:0]]];
                             [playlist removeObjectAtIndex:0];
                         }
                         else {
                             [playlist addObjectsFromArray:[jresponse objectForKey:@"song"]];
                             [delegate fetchPlaylistSuccessWithStartSong:nil];
                         }
                     }
                     @catch (NSException *exception) {
                         // throw exception
                         [delegate fetchPlaylistError:nil withDictionary:dict
                                       startAttribute:startAttr
                                        andErrorCount:errcount];
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
    
    [self fetchPlaylistWithDictionary:fetchDictionary
                   withStartAttribute:startAttr
                        andErrorCount:0];
}

- (DMPlayableCapsule*)getOnePlayableCapsule
{
    if([playlist count]>0){
        NSDictionary *songDict = [[[playlist objectAtIndex:0] retain] autorelease];
        if([songDict objectForKey:@"ssid"] == nil){
            if([[[NSUserDefaults standardUserDefaults]
                 valueForKey:@"filterAds"] integerValue] == NSOnState){
                [playlist removeObjectAtIndex:0];
                return [self getOnePlayableCapsule];
            }
        }
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

-(void) dmGetAlbumSongsWithAid:(NSString *)aid andCompletionBlock:(void (^)(NSArray *))block
{
    if (block==nil) {
        return;
    }
    
    NSString* urlstring = [DM_ALBUM_GET_URL stringByAppendingFormat:@"?aid=%@",aid];
    NSURL* url = [NSURL URLWithString:urlstring];
    NSURLRequest* request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                         timeoutInterval:5.0];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *r, NSData *d, NSError *e) {

                               NSArray* list = [[CJSONDeserializer deserializer] deserializeAsArray:d error:&e];
                               if (e) {
                                   block(nil);
                               }
                               else {
                                   block(list);
                               }
                               
                           }];
}

@end
