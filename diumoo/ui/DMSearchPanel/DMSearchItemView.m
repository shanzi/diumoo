//
//  DMSearchItemView.m
//  diumoo
//
//  Created by Shanzi on 12-10-21.
//
//

#import "DMSearchItemView.h"


@implementation DMSearchCollectionView
@synthesize target;

-(void) mouseDown:(NSEvent *)theEvent
{
    [super mouseDown:theEvent];
    
    if (theEvent.clickCount == 2) {
        NSManagedObject* songObject = [self selectedItem];
        if (songObject) {
            
            
            NSString *sid = [songObject valueForKey:@"sid"];
            NSString *ssid = [songObject valueForKey:@"ssid"];
            NSString *start = [NSString stringWithFormat:@"%@g%@g0",sid,ssid];
            
            NSDictionary* info =@{
            @"type":@"song",
            @"start": start
            };
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"playspecial"
             object:self
             userInfo:info];
        }
    }
    
}

-(NSManagedObject*) selectedItem
{
    if ([[self selectionIndexes] count]) {
        NSCollectionViewItem* selectedItem = [self itemAtIndex:
                                          [[self selectionIndexes] firstIndex]];
        return selectedItem.representedObject;
    }
    else return nil;
}

@end

@implementation DMSearchCollectionViewItem
-(void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [(DMSearchItemView*)self.view setSelected:selected];
    [self.view setNeedsDisplay:YES];
}
@end


@implementation DMSearchItemView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    if (self.selected) {
        [[NSColor colorWithCalibratedRed:0.75 green:1.0 blue:0.75 alpha:1.0] setFill];
        NSRectFill([self bounds]);
    }
}

@end
