//
//  DMBitrateControlLayer.m
//  DMBitrateSelectLayer
//
//  Created by Shanzi on 13-1-18.
//  Copyright (c) 2013年 Shanzi. All rights reserved.
//

#import "DMBitrateControlLayer.h"

@implementation DMBitrateControlLayer
-(id)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, 250, 40);
        self.anchorPoint = CGPointMake(0, 0);
        
        LayerArray = @[[CALayer new],[CALayer new],[CALayer new]];
        
        int count=0;
        NSArray* imagenames=@[@"64kbps",@"128kbps",@"192kbps"];
        black = CGColorCreateGenericGray(0, 0.6);
        focus = CGColorCreateGenericRGB(0.2, 0.5, 1.0, 1.0);
        CGRect frame = CGRectMake(0, 0, 70, 40);
        
        for (CALayer* layer in LayerArray) {
            layer.frame = frame;
            layer.anchorPoint = CGPointMake(0, 0);
            layer.backgroundColor = black;
            layer.position = CGPointMake(72*count +17 , 10);
            layer.contents = [NSImage imageNamed:imagenames[count]];
            [self addSublayer:layer];
            count ++;
        }
        
        [[NSUserDefaults standardUserDefaults] addObserver:self
                                                forKeyPath:@"musicQuality"
                                                   options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)
                                                   context:nil];
        
    }
    return self;
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{

    NSInteger bitrate = [[NSUserDefaults standardUserDefaults] integerForKey:@"musicQuality"];
    [self selectLayer:LayerArray[bitrate/64-1]];
}

-(void) selectLayer:(CALayer*) layer
{
    [CATransaction begin];
    if (floor(NSAppKitVersionNumber)<=NSAppKitVersionNumber10_7_2) {
        for (CALayer* l in LayerArray) {
            if (l==layer) {
                l.backgroundColor = focus;
                l.position = CGPointMake(l.position.x, 0);
            }
            else{
                l.backgroundColor=black;
                l.position = CGPointMake(l.position.x, 10);
            }
        }
    }
    else{
        for (CALayer* l in LayerArray) {
            if (l==layer) {
                l.backgroundColor = focus;
                l.position = CGPointMake(l.position.x, 10);
            }
            else{
                l.backgroundColor=black;
                l.position = CGPointMake(l.position.x, 0);
            }
        }
    }
    [CATransaction commit];
}

-(BOOL) hitPostion:(NSPoint)point
{
    if (point.y>40)
        return NO;
    int bitrate = 0;
    if (point.x>17)
    {
        if (point.x<17+72)
            bitrate = 64;
        else if(point.x < 17+72*2)
            bitrate = 128;
        else if(point.x < 17+72*3)
            bitrate = 192;
    }
    if(bitrate) {
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults boolForKey:@"isPro"]) {
            if ([defaults integerForKey:@"musicQuality"]!=bitrate) {
                [defaults setInteger:bitrate
                              forKey:@"musicQuality"];
            }
        }
        else{
            NSInteger re = NSRunInformationalAlertPanel(NSLocalizedString(@"PRO_NEED_BUY_TITLE", nil),
                            NSLocalizedString(@"PRO_NEED_BUY", nil),
                            NSLocalizedString(@"YES", nil),
                            NSLocalizedString(@"NO", nil),
                            nil);
            if (re==NSAlertDefaultReturn) {
                [[NSWorkspace sharedWorkspace] openURL:
                 [NSURL URLWithString:@"http://douban.fm/upgrade"]];
            }
        }

        return YES;
    }
    return NO;
}

@end
