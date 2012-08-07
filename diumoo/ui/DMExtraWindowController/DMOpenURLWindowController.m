//
//  DMOpenURLWindowController.m
//  diumoo
//
//  Created by Shanzi on 12-8-5.
//
//

#import "DMOpenURLWindowController.h"
#import "DMService.h"



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



-(void) urlOpenAction:(id)sender
{
    
    // 打开url
    NSString* string = [urlbox stringValue];
    if ([DMService openDiumooLink:string]) {
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
}


@end
