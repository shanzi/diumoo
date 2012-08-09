//
//  DMPlaylistFetcher.h
//  diumoo-core
//
//  Created by Shanzi on 12-6-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#define kFetchPlaylistTypeNew @"n"
#define kFetchPlaylistTypeEnd @"e"
#define kFetchPlaylistTypePlaying @"p"
#define kFetchPlaylistTypeSkip @"s"
#define kFetchPlaylistTypeRate @"r"
#define kFetchPlaylistTypeUnrate @"u"
#define kFetchPlaylistTypeBye @"b"

#import <Foundation/Foundation.h>
#import "DMPlayableCapsule.h"
#import "DMPlaylistFetcherDeleate.h"
#import "CJSONDeserializer.h"

@interface DMPlaylistFetcher : NSObject
{
    id<DMPlaylistFetcherDeleate> delegate;
}

@property(assign) id<DMPlaylistFetcherDeleate> delegate;


-(void) fetchPlaylistFromChannel:(NSString*)channel withType:(NSString*)type sid:(NSString*)sid startAttribute:(NSString*)startAttr;

-(void) fetchPlaylistWithDictionary:(NSDictionary*)dict withStartAttribute:(NSString*)startAttr andErrorCount:(NSInteger)count;
-(DMPlayableCapsule*) getOnePlayableCapsule;
-(void) clearPlaylist;

-(void) dmGetAlbumSongsWithAid:(NSString*)aid andCompletionBlock:(void(^)(NSArray* list)) block;


@end
