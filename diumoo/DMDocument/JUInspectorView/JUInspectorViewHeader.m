//
//  JUInspectorView.m
//  JUInspectorView
//
//  Copyright (c) 2011 by Sidney Just
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated 
//  documentation files (the "Software"), to deal in the Software without restriction, including without limitation 
//  the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, 
//  and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
//  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
//  PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE 
//  FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, 
//  ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "JUInspectorViewHeader.h"

@interface JUInspectorViewHeader(Private)

-(void)setupView;
-(void)disclosureClicked:(id)sender;

@end

@implementation JUInspectorViewHeader

@synthesize dashColor, gradientStartColor, gradientEndColor, disclosureTriangle, state, title, delegate;

#pragma mark - Init/Dealloc

- (id)initWithCoder:(NSCoder *)decoder
{
    return [self initWithFrame:NSZeroRect];
}

- (id)initWithFrame:(NSRect)frame
{
    if((self = [super initWithFrame:NSMakeRect(0.0, 0.0, 222.0, 20.0)]))
    {
    }
    
    return self;
}


- (void)setupView
{
    dashColor = [[NSColor colorWithCalibratedRed:0.502 green:0.502 blue:0.502 alpha:1.0] retain];
    gradientStartColor = [[NSColor colorWithCalibratedRed:0.922 green:0.925 blue:0.976 alpha:1.0] retain];
    gradientEndColor = [[NSColor colorWithCalibratedRed:0.741 green:0.749 blue:0.831 alpha:1.0] retain];
    
    disclosureTriangle = [[NSButton alloc] initWithFrame:NSMakeRect(5.0, 4.0, 13.0, 13.0)];
    [disclosureTriangle setBezelStyle:NSDisclosureBezelStyle];
    [disclosureTriangle setButtonType: NSPushOnPushOffButton];
    [disclosureTriangle setTitle:nil];
    [disclosureTriangle highlight:NO];
    [disclosureTriangle setTarget:self];
    [disclosureTriangle setAction:@selector(disclosureClicked:)];
    
    nameField = [[NSTextField alloc] initWithFrame:NSMakeRect(20.0, 4.0, [self bounds].size.width - 8.0, 15.0)];
    [nameField setEditable:NO];
    [nameField setBackgroundColor:[NSColor clearColor]];
    [nameField setBezeled:NO];
    [nameField setFont:[NSFont boldSystemFontOfSize:12.0]];
    [nameField setTextColor:[NSColor colorWithCalibratedRed:0.220 green:0.224 blue:0.231 alpha:1.0]];
    
    
    [self addSubview:disclosureTriangle];
    [self addSubview:nameField];
}

- (void)dealloc
{
    [dashColor release];
    [gradientEndColor release];
    [gradientStartColor release];
    [disclosureTriangle release];
    [nameField release];
    
    [super dealloc];
}

#pragma mark - Properties

-(NSInteger)state
{
    return [disclosureTriangle state];
}

- (void)setState:(NSInteger)value
{
    [disclosureTriangle setState:value];
}

-(NSString *)title
{
    return [nameField stringValue];
}

- (void)setTitle:(NSString *)value
{
    [nameField setStringValue:value];
}

#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect
{
    NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:gradientStartColor endingColor:gradientEndColor];
    [gradient drawInRect:[self bounds] angle:-90.0];
    [gradient autorelease];
    
    [dashColor set];
    
    NSRect dashRect = [self bounds];
    dashRect.origin.x -= 1.0;
    dashRect.size.width += 2.0;
    
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:dashRect];
    [path setLineWidth:1.0];
    [path stroke];
}

#pragma mark - Event handling

- (void)mouseUp:(NSEvent *)theEvent
{
    [delegate headerClicked:self];
}


-(void)disclosureClicked:(id)sender
{
    [delegate headerClicked:self];
}

@end
