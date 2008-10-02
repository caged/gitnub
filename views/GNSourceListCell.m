// Modified for GitNub
// Original License:
//
// Green Dome Software
//
// Copyright (c) 2006 Timothy K. McIntosh
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or
// without modification, are permitted provided that the following
// conditions are met:
// 
// 1. Redistributions of source code must retain the above copyright
// notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above
// copyright notice, this list of conditions and the following
// disclaimer in the documentation and/or other materials provided
// with the distribution.
// 3. Neither the name of the copyright holder nor the names of his
// contributors may be used to endorse or promote products derived
// from this software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
// FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE
// COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
// BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
// LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
// ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

//
//  GNSourceListCell.m
//
//      Implements a "source list" cell containing an icon and centered text.

#import "GNSourceListCell.h"


@interface GNSourceListCell (PrivateMethods)
- (NSImage *)iconForCellFrame:(NSRect)cellFrame inView:(NSView *)controlView;
- (NSRect)frameOfIcon:(NSImage*)icon byDividingFrame:(NSRect *)pCellFrame inView:(NSView *)controlView;
- (NSRect)frameOfTextFromFrame:(NSRect)cellFrame inView:(NSView *)controlView;
@end


@implementation GNSourceListCell (PrivateMethods)

- (NSRect)centeredTextFrameForBounds:(NSRect)cellFrame
{
    // Calculate minimum text size, constrained within cell & resized as needed:
    NSSize  textSize  = [self cellSizeForBounds: cellFrame];
    
    return NSInsetRect(cellFrame, 0, (NSHeight(cellFrame) - textSize.height) / 2);
}

- (NSImage *)iconForCellFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    NSTableView* v = (NSTableView *)controlView;
    
    return [v iconForRow: [v rowAtPoint: NSMakePoint(NSMidX(cellFrame), NSMidY(cellFrame))]];
}

- (NSRect)frameOfIcon:(NSImage*)icon byDividingFrame:(NSRect *)pCellFrame inView:(NSView *)controlView
{
    NSRect  iconFrame, textFrame;
    
    if (icon == nil)
    {
        iconFrame = NSZeroRect;
        textFrame = *pCellFrame;
    }
    else
    {
        NSSize  iconSize        = [icon size];
        
        // Calculate scale of icon if its height were set equal to the cell height:
        float   iconScale       = NSHeight(*pCellFrame) / iconSize.height;
        
        // Clamp the icon scale to the maximum allowed value (default 1.0):
        float   maxIconScale    = [(NSTableView *)controlView maxIconScale];
        
        if (iconScale > maxIconScale)
        {
            iconScale = maxIconScale;
        }
        
        // Divide cell frame into two left and right pieces (for icon and text):
        NSDivideRect(*pCellFrame, &iconFrame, &textFrame,
                     ceil([self iconOffset] + iconScale * iconSize.width + [self textOffset]),
                     NSMinXEdge);
        iconFrame.origin.x     += [self iconOffset];
        iconFrame.size.width   -= [self iconOffset] + [self textOffset];

        // Center the icon frame vertically:
        iconFrame = NSInsetRect(iconFrame, 0, ceil((NSHeight(iconFrame) - iconScale * iconSize.height) / 2));
    }
    
    // Center the returned text frame vertically:
    *pCellFrame = [self centeredTextFrameForBounds: textFrame];
    
    return iconFrame;
}

- (NSRect)frameOfTextFromFrame:(NSRect)cellFrame inView:(NSView*)controlView
{
    [self frameOfIcon: [self iconForCellFrame: cellFrame inView: controlView]
      byDividingFrame: &cellFrame
               inView: controlView];
    
    return cellFrame;
}

@end


@implementation GNSourceListCell

- (id)initTextCell:(NSString *)aString
{
    if (self = [super initTextCell: aString])
    {
        [self setIconOffset: 4.0];
        [self setTextOffset: 4.0];
    }

    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super initWithCoder: decoder])
    {
        [self setIconOffset: 4.0];
        [self setTextOffset: 4.0];
    }

    return self;
}

- (float)iconOffset;
{
    return m_iconOffset;
}

- (void)setIconOffset:(float)offset
{
    offset = floor(offset);

    if (offset != m_iconOffset)
    {
        m_iconOffset    = offset;
        [[self controlView] setNeedsDisplay: YES];
    }
}

- (float)textOffset
{
    return m_textOffset;
}

- (void)setTextOffset:(float)offset
{
    offset = floor(offset);

    if (offset != m_textOffset)
    {
        m_textOffset = offset;
        [[self controlView] setNeedsDisplay: YES];
    }
}

- (void)setLineBreakMode:(NSLineBreakMode)mode
{
    if (mode < NSLineBreakByClipping)
    {
        NSLog(@"%s: Warning: Wrapping modes not supported.", __func__);
        return;
    }

    [super setLineBreakMode: mode];
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    NSImage*    icon    = [self iconForCellFrame: cellFrame inView: controlView];

    // Carve frame for icon out of cellFrame;
    //      returns NSZeroRect if it won't fit in the cell:
    NSRect  iconFrame = [self frameOfIcon: icon byDividingFrame: &cellFrame inView: controlView];

    BOOL    drawFlipped = [controlView isFlipped];

    if (drawFlipped)
    {
        [NSGraphicsContext saveGraphicsState];

        NSAffineTransform* transform    = [NSAffineTransform transform];

        [transform translateXBy: NSMinX(iconFrame)
                            yBy: NSMaxY(iconFrame)];

        [transform scaleXBy:1.0 yBy:-1.0];

        [transform concat];
    }

    // Draw icon:
    [icon drawInRect: (NSRect) { .origin = NSZeroPoint, .size = iconFrame.size }
            fromRect: (NSRect) { .origin = NSZeroPoint, .size = [icon size] }
           operation: NSCompositeSourceOver
            fraction: 1.0];

    if (drawFlipped)
    {
        [NSGraphicsContext restoreGraphicsState];
    }

    // Set selected control text color if cell is highlighted & not being edited:
    if ([self isHighlighted])
    {
        [self setTextColor: [NSColor alternateSelectedControlTextColor]];
    }
    else
    {
        [self setTextColor: [NSColor textColor]];
    }

    // Now draw text:
    [super drawInteriorWithFrame: cellFrame inView: controlView];
}

- (void)editWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject event:(NSEvent *)theEvent
{
    aRect = [self frameOfTextFromFrame: aRect inView: controlView];

    [self setTextColor: [NSColor textColor]];
    [super editWithFrame: aRect inView: controlView editor: textObj delegate: anObject event: theEvent];
}

- (void)selectWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject start:(int)selStart length:(int)selLength
{
    aRect = [self frameOfTextFromFrame: aRect inView: controlView];
    
    [self setTextColor: [NSColor textColor]];
    [super selectWithFrame: aRect inView: controlView editor: textObj delegate: anObject start: selStart length: selLength];
}

@end

