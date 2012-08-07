//
//  DMOpenURLWindowController.m
//  diumoo
//
//  Created by Shanzi on 12-8-5.
//
//

#import "DMOpenURLWindowController.h"

#define DM_SONG_PREFIX @"dm://song?key="
#define DOUBAN_SHARE_PREFIX @"http://douban.fm/?start="

@interface DMOpenURLWindowController ()

@end

@implementation DMOpenURLWindowController

- (id)init
{
    self = [super initWithWindowNibName:@"DMOpenURLWindow"];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];

    id array = [[NSUserDefaults standardUserDefaults] valueForKey:@"recentlyURLs"];
    [urlbox addItemsWithObjectValues:array];
}

-(NSString*) cleanStartAttribute:(NSString*)start
{
    DMLog(@"clean start %@",start);
    NSArray* startComponents = [start componentsSeparatedByString:@"g"];
    if ([startComponents count]>2) {
        if ([[startComponents objectAtIndex:1] length] == 4) {
            return [NSString stringWithFormat:@"%@g%@g",
                    [startComponents objectAtIndex:0],
                    [startComponents objectAtIndex:1]
                    ];
        }
    }
    return nil;
}

-(void) urlOpenAction:(id)sender
{
    
    // 打开url
    NSString* string = [urlbox stringValue];
    DMLog(@"%@",string);
    
    NSString* start = nil;
    NSString* type = nil;
    
    if ([string hasPrefix:DM_SONG_PREFIX]) {
        start = [string stringByReplacingOccurrencesOfString:DM_SONG_PREFIX
                                                  withString:@""];
        start = [self cleanStartAttribute:start];
        if (start != nil) {
            type = @"song";
        }
        
    }
    else if([string hasPrefix:DOUBAN_SHARE_PREFIX])
    {
        start = [string stringByReplacingOccurrencesOfString:DOUBAN_SHARE_PREFIX
                                                  withString:@""];
        NSArray* components = [start componentsSeparatedByString:@"&"];
        if ([components count]) {
            start =[self cleanStartAttribute:start];
            if (start) {
                type = @"song";
            }
        }
    }
    
    if (type != nil) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"playspecial"
                                                            object:nil
                                                          userInfo:@{
         @"type" : @"song",
         @"start" : start
         }
         ];
        
        id array = [[NSUserDefaults standardUserDefaults] valueForKey:@"recentlyURLs"];
        if (array) {
            [array addObject:string];
        }
        else{
            [[NSUserDefaults standardUserDefaults] setObject:@[string] forKey:@"recentlyURLs"];
        }
        [urlbox addItemWithObjectValue:string];
        [self close];
    }
    else
    {
        NSRunCriticalAlertPanel(@"打开URL失败",
                                @"打开URL失败，您输入了非法的URL地址。目前仅支持 diumoo Link 和豆瓣分享连接(暂不支持短网址)。",
                                @"知道了", nil, nil);
    }
    
}


@end
