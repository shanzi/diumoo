//
//  DMControlCenter.h
//  diumoo-core
//
//  Created by Shanzi on 12-6-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMPlayableCapsule.h"
#import "DMPlaylistFetcher.h"

@interface DMControlCenter : NSObject<DMPlayableCapsuleDelegate,DMPlaylistFetcherDeleate>
// {
@property(retain) DMPlayableCapsule* capsule;
@property(assign) DMPlaylistFetcher* fetcher; 
// }


//-------------------临时使用的UI delegate 函数---------------------
-(IBAction)playAction:(id) sender;
-(IBAction)pauseAction:(id) sneder;
-(IBAction)volumeChange:(id)sender;
//---------------------------------------------------------------

@end
