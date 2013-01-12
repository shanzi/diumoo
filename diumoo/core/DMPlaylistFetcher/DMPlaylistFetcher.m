//
//  DMPlaylistFetcher.m
//  diumoo-core
//
//  Created by Shanzi on 12-6-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#define PLAYLIST_FETCH_URL_BASE @"http://douban.fm/j/mine/playlist"
#define DOUBAN_FM_ORIGIN_URL @".douban.fm"
#define DOUBAN_ALBUM_GET_URL @"http://douban.fm/j/app/radio/people"


#import "DMPlaylistFetcher.h"
#import "NSDictionary+UrlEncoding.h"

@interface DMPlaylistFetcher()
{
    NSMutableArray *playlist;
    NSMutableDictionary *playedSongs;
    NSOrderedSet* searchResults;
}

- (NSString*)randomString;

@end


@implementation DMPlaylistFetcher
@synthesize delegate;

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

- (void)fetchPlaylistWithDictionary:(NSDictionary *)dict withStartAttribute:(NSString *)startAttr andErrorCount:(NSInteger)errcount
{
    NSString* urlString =  [PLAYLIST_FETCH_URL_BASE stringByAppendingFormat:@"?%@", 
                            [dict urlEncodedString]];
    
    DMLog(@"fetch url : %@",urlString);
        
    NSURLRequest* urlrequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString] 
                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                            timeoutInterval:20.0];

    
    //----------------------------处理start属性-------------------------
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:[NSHTTPCookie cookieWithProperties:
                                                              @{NSHTTPCookieDomain: @"douban.fm",
                                                                    NSHTTPCookieName: @"start",
                                                   NSHTTPCookieValue: (startAttr?startAttr:@""),
                                                                     NSHTTPCookieDiscard: @"TRUE",
                                                                        NSHTTPCookiePath: @"/"}]];

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
             id jresponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jerr];
             
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
                             
                             playlist = [NSMutableArray arrayWithArray:[jresponse valueForKey:@"song"]];
                             [delegate fetchPlaylistSuccessWithStartSong:
                             [DMPlayableCapsule playableCapsuleWithDictionary:playlist[0]]];
                             [playlist removeObjectAtIndex:0];
                         }
                         else {
                             [playlist addObjectsFromArray:jresponse[@"song"]];
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
    if ([type isEqual: kFetchPlaylistTypeEnd] && [playlist count]==0) {
        type = kFetchPlaylistTypeNew;
    }
    else if(sid==nil) {
        type = kFetchPlaylistTypeNew;
    }
    else
    {
        [playedSongs setValue:type forKey:sid];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *quality = [defaults valueForKey:@"musicQuality"];
    
    NSDictionary* fetchDictionary = @{@"type": type,
                                     @"channel": channel,
                                     @"sid": ((sid!=nil)?sid:@""),
                                     @"h": [playedSongs hString],
                                     @"r": [self randomString],
                                     @"from": @"mainsite",
                                     @"kbps": quality
    };
    
    [self fetchPlaylistWithDictionary:fetchDictionary
                   withStartAttribute:startAttr
                        andErrorCount:0];
}

-(void) sendRequestForURL:(NSString*) urlstring callback:(void(^)(NSArray* list))block
{
    NSURL* url = [NSURL URLWithString:urlstring];
    NSURLRequest* request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLCacheStorageAllowed
                                         timeoutInterval:10.0
                             ];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *r, NSData *d, NSError *e) {
                               
                               if (d) {
                                  
                                   NSDictionary *dictalbum = [NSJSONSerialization JSONObjectWithData:d options:NSJSONReadingMutableContainers error:nil];
                                   
                                   NSArray* songarray = dictalbum[@"song"];
                                   if (block) {
                                       block(songarray);
                                   }
                               }
                           }];
}

-(void)fetchMusicianMusicsWithMusicianId:(NSString *)musician_id callback:(void(^)(BOOL success))callback
{
    NSDictionary* dict = @{
    @"type":kFetchPlaylistTypeNew,
    @"channel":@(0),
    @"r":[self randomString],
    @"from":@"mainsite",
    @"context":[@"context=channel:0|musician_id:" stringByAppendingString:musician_id]
    };
    
    
    
    NSString* urlstring = [NSString stringWithFormat:@"%@?%@",
                           PLAYLIST_FETCH_URL_BASE,[dict urlEncodedString]
                           ];
    [self sendRequestForURL:urlstring callback:^(NSArray *list) {
        if (list) {
            [playlist removeAllObjects];
            [playlist addObjectsFromArray:list];
            callback(YES);
        }
        else
        {
            callback(NO);
        }
    }];
}

-(void) fetchSoundtrackWithSoundtrackId:(NSString *)soundtrack_id callback:(void (^)(BOOL))callback
{
    NSDictionary* dict = @{
    @"type":kFetchPlaylistTypeNew,
    @"channel":@(10),
    @"r":[self randomString],
    @"from":@"mainsite",
    @"context":[@"context=channel:10|subject_id:" stringByAppendingString:soundtrack_id]
    };
    NSString* urlstring = [NSString stringWithFormat:@"%@?%@",
                           PLAYLIST_FETCH_URL_BASE,
                           [dict urlEncodedString]
                           ];
    [self sendRequestForURL:urlstring callback:^(NSArray *list) {
        if (list) {
            [playlist removeAllObjects];
            [playlist addObjectsFromArray:list];
            callback(YES);
        }
        else{
            callback(NO);
        }
    }];
}

- (DMPlayableCapsule*)getOnePlayableCapsule
{
    if([playlist count]>0){
        
        NSDictionary *songDict = playlist[0];
        
        if([playlist[0][@"subtype"] isEqual:@"T"]
           && ([[[NSUserDefaults standardUserDefaults] valueForKey:@"filterAds"] integerValue] == NSOnState)){
            [playlist removeObjectAtIndex:0];
            return [self getOnePlayableCapsule];
        }
        [playlist removeObjectAtIndex:0];
        
        return [DMPlayableCapsule playableCapsuleWithDictionary:songDict];
    }
    else return nil;
}

-(void) clearPlaylist
{
    [playlist removeAllObjects];
}

-(void)fetchPlaylistForAlbum:(NSString *)album callback:(void (^)(BOOL))callback
{
    NSInteger expire = (NSInteger) time(0) +1000 *60 * 5 * 30;

    NSDictionary* fetchdict = @{
    @"type" : @"n",
    @"context": [NSString stringWithFormat:@"channel:0|subject_id:%@",album],
    @"channel":@"0",
    @"app_name":@"radio_ipad",
    @"version": @"1",
    @"expire" : @(expire)

    };
    
    NSString* urlstring = [NSString stringWithFormat:@"%@?%@",
                           DOUBAN_ALBUM_GET_URL,
                           [fetchdict urlEncodedString]];
    
    
    [self sendRequestForURL:urlstring callback:^(NSArray *songarray) {
        if ([songarray count]) {
            NSMutableArray* albumsongs = [NSMutableArray arrayWithCapacity:[songarray count]];
            for (NSDictionary* song in songarray) {
                if ([song[@"aid"] isEqualToString:album]) {
                    [albumsongs addObject:song];
                }
            }
            
            if ([albumsongs count]) {
                playlist = albumsongs;
                callback(YES);
            }
            else callback(NO);
        }
    }];
}

@end
