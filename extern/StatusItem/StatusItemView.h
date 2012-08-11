@interface StatusItemView : NSView {
@private
    NSImage *_image;
    NSImage *_mixedImage;
    NSImage *_alternateImage;
    NSStatusItem *_statusItem;
    BOOL _isHighlighted;
    BOOL _isMixed;
    SEL _action;
    __unsafe_unretained id _target;
}

- (id)initWithStatusItem:(NSStatusItem *)statusItem;

@property (nonatomic, strong, readonly) NSStatusItem *statusItem;
@property (nonatomic, strong) NSImage *image;
@property (nonatomic, strong) NSImage *mixedImage;
@property (nonatomic, strong) NSImage *alternateImage;
@property (nonatomic, setter = setHighlighted:) BOOL isHighlighted;
@property (nonatomic, setter = setMixed:) BOOL isMixed;
@property (nonatomic, readonly) NSRect globalRect;
@property (nonatomic) SEL action;
@property (nonatomic, unsafe_unretained) id target;

@end
