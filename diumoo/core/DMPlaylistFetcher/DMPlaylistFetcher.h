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

@property(retain) id<DMPlaylistFetcherDeleate> delegate;


- (void)fetchPlaylistWithDictionary:(NSDictionary*)dic withStartAttribute:(NSString*)startAttr;
- (void)fetchPlaylistFromChannel:(NSString*)channel withType:(NSString*)type sid:(NSString*)sid startAttribute:(NSString*)startAttr;
- (DMPlayableCapsule*)getOnePlayableCapsule;


@end
