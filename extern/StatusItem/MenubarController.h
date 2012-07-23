#define STATUS_ITEM_VIEW_WIDTH 24.0

#pragma mark -

@class StatusItemView;

@interface MenubarController : NSObject {
@private
    StatusItemView *_statusItemView;
}

@property (nonatomic) BOOL hasActiveIcon;
@property (nonatomic, assign, readonly) StatusItemView *statusItemView;

- (NSStatusItem *)statusItem;
-(void) setMixed:(BOOL) mixed;
-(void) setAction:(SEL) action withTarget:(id) target;
@end
