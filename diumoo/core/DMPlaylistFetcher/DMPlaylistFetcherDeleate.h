//
//  DMPlaylistFetcherDeleate.h
//  diumoo-core
//
//  Created by Shanzi on 12-6-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DMPlaylistFetcherDeleate <NSObject>

-(void) fetchPlaylistError:(NSError*) err withComment:(NSString*) comment;
-(void) fetchPlaylistSuccessWithStartSong:(id) startsong;

@end
