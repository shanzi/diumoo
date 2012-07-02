//
//  JUInspectoView.m
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

#import "JUInspectorView.h"

@implementation JUInspectorView

@synthesize name, index, body, expanded, container;

#pragma mark - Init/Dealloc

- (void)setupView
{   
    header = [[JUInspectorViewHeader alloc] initWithFrame:NSZeroRect];
    [header setAutoresizingMask:NSViewWidthSizable];
    header.delegate=self;
    
    [self addSubview:header];
    [self setExpanded:YES];
}

- (void)dealloc
{
    [header release];
    [body release];
    
    [super dealloc];
}

#pragma mark - Properties

- (void)setExpanded:(BOOL)value
{
    if (expanded==value)
        return;
    
    expanded=value;
 
    NSRect frame;
    
    if (expanded)
    {
        frame = [body bounds];
        frame.origin = [self frame].origin;
        frame.size.height += [header bounds].size.height;
        
        [body setHidden:NO];
        [header setState:NSOnState];
        [container arrangeViews];
    }
    else
    {
        frame.origin = [self frame].origin;
        frame.size = [header frame].size;
        
        [body setHidden:YES];
        [header setState:NSOffState];
    }
    
    [self setFrame:frame];
    [container arrangeViews];
}

-(NSString *)name
{
    return [header title];
}

- (void)setName:(NSString *)value
{
    [header setTitle:value];
}

- (void)setBody:(NSView *)pbody
{
    [body removeFromSuperview];
    [body release];
    
    body = [pbody retain];
    
    if([body isFlipped])
    {
        NSRect bodyFrame = [body bounds];
        bodyFrame.origin.y = [header bounds].size.height + 1.0;
        
        [body setFrame:bodyFrame];
    }
    else
    {
        NSRect bodyFrame = [body bounds];
        bodyFrame.origin.y = -bodyFrame.size.height + [header bounds].size.height;
        
        [body setFrame:bodyFrame];
    }
    
    [self addSubview:body];
    
    self.expanded = !expanded;
}

#pragma mark - NSView Overrides

- (void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    
    NSRect bodyRect = [body frame];
    bodyRect.size.width = frameRect.size.width;
    [body setFrame:bodyRect];
}

- (BOOL)isFlipped
{
    return YES;
}

- (void)drawRect:(NSRect)dirtyRect
{
    if(expanded)
    {
        [[header dashColor] set];
        
        NSRect dashRect = [self bounds];
        dashRect.origin.x -= 1.0;
        dashRect.size.width += 2.0;
        
        NSBezierPath *path = [NSBezierPath bezierPathWithRect:dashRect];
        [path setLineWidth:1.0];
        [path stroke];
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"JUCollectionView \"%@\", expanded: %@", self.name, expanded ? @"YES" : @"NO"];
}

- (NSComparisonResult)compare:(JUInspectorView *)otherView
{
    if(otherView.index > index)
        return NSGreaterThanComparison;
    
    if(otherView.index < index)
        return NSLessThanComparison;
    
    return NSEqualToComparison;
}

#pragma mark - JUInspectorViewHeaderDelegate

-(void)headerClicked:(JUInspectorViewHeader *)headerView
{
    self.expanded=!expanded;
}


@end
