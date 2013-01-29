//
//  DMPlayableItem.m
//  diumoo-core
//
//  Created by Shanzi on 12-5-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <math.h>
#import "DMPlayableItem.h"
#import "DMService.h"

@implementation DMPlayableItem

@synthesize musicInfo,playState,delegate,duration,cover,like;

+ (id)playableItemWithDictionary:(NSDictionary *)aDict
{
    if (aDict) {
        return [[DMPlayableItem alloc] initWithDictionary:aDict];
    }
    return nil;
}

- (id)initWithDictionary:(NSDictionary *)aDict
{
    if (self = [super initWithURL:[NSURL URLWithString:aDict[@"url"]]]) {
        
        musicInfo = @{ @"aid":aDict[@"aid"],
                     @"sid":aDict[@"sid"],
                    @"ssid":aDict[@"ssid"],
                 @"subtype":aDict[@"subtype"],
                   @"title":aDict[@"title"],
                  @"artist":aDict[@"artist"],
              @"albumtitle":aDict[@"albumtitle"],
           @"albumLocation":[NSString stringWithFormat:@"%@%@",DOUBAN_URL_PRIFIX,aDict[@"album"]],
           @"musicLocation":aDict[@"url"],
         @"pictureLocation":aDict[@"picture"],
    @"largePictureLocation":[aDict[@"picture"]stringByReplacingOccurrencesOfString:@"mpic" withString:@"lpic"],
                  @"length":@([aDict[@"length"] floatValue]*1000),
              @"rating_avg":@([aDict[@"rating_avg"] floatValue])
                      };
        like = [aDict[@"like"] boolValue];
        playState = WAIT_TO_PLAY;
        cover = [NSImage imageNamed:@"albumfail"];
        
        [self addObserver:self forKeyPath:@"status" options:0 context:nil];
    }
    return self;
}

- (void)dealloc
{
    self.delegate = nil;
    [self invalidateItem];
}

-(void) invalidateItem
{
    playState = WAIT_TO_PLAY;
    [self removeObserver:self forKeyPath:@"status"];
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"]) {
        DMLog(@"%@ status changed to %ld",musicInfo[@"title"],self.status);
        [self.delegate playableItem:self loadStateChanged:self.status];
    }
}

-(NSString*) shareAttributeWithChannel:(NSString *)channel
{
    if(musicInfo[@"ssid"] == nil)
        return nil;
    else
        return [NSString stringWithFormat:@"%@g%@g%@",musicInfo[@"sid"],musicInfo[@"ssid"],channel];
}

-(void) prepareCoverWithCallbackBlock:(void (^)(NSImage*))block
{
    if (block) {
        NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:musicInfo[@"largePictureLocation"]]
                                                 cachePolicy:NSURLCacheStorageAllowed
                                             timeoutInterval:5.0];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[DMService serviceQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   if (error || data==nil)
                                       cover = [NSImage imageNamed:@"albumfail"];
                                   else
                                       cover = [[NSImage alloc] initWithData:data];
                                   block(cover);
                                }];
    }
}

- (float)duration
{
    return CMTimeGetSeconds(self.asset.duration);
}


@end
