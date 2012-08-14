#import "MenubarController.h"
#import "StatusItemView.h"

@implementation MenubarController

@synthesize statusItemView = _statusItemView;

#pragma mark -

- (id)init
{
    if (self = [super init])
    {
        // Install status item into the menu bar
        NSStatusItem *statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:STATUS_ITEM_VIEW_WIDTH];
        _statusItemView = [[StatusItemView alloc] initWithStatusItem:statusItem] ;
        _statusItemView.image = [NSImage imageNamed:@"status-icon"];
        _statusItemView.mixedImage = [NSImage imageNamed:@"status-icon-mixed"];
        _statusItemView.alternateImage = [NSImage imageNamed:@"status-icon-alt"];
    }
    return self;
}

- (void)dealloc
{
    [[NSStatusBar systemStatusBar] removeStatusItem:self.statusItem];
}

#pragma mark -
#pragma mark Public accessors

- (NSStatusItem *)statusItem
{
    return self.statusItemView.statusItem;
}

-(void) setMixed:(BOOL)mixed
{
    [_statusItemView setMixed:mixed];
}

-(void) setAction:(SEL)action withTarget:(id)target
{
    _statusItemView.action = action;
    _statusItemView.target = target;
}

#pragma mark -

- (BOOL)hasActiveIcon
{
    return self.statusItemView.isHighlighted;
}

- (void)setHasActiveIcon:(BOOL)flag
{
    self.statusItemView.isHighlighted = flag;
}

@end
