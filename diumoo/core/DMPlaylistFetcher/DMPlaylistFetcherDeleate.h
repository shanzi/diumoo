//
//  DMPlaylistFetcherDeleate.h
//  diumoo-core
//
//  Created by Shanzi on 12-6-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DMPlaylistFetcherDeleate <NSObject>

- (void)fetchPlaylistError:(NSError *)err
            withDictionary:(NSDictionary*) dict
            startAttribute:(NSString*)attr andErrorCount:(NSInteger) count;
- (void)fetchPlaylistSuccessWithStartSong:(id)startSong;

@end
