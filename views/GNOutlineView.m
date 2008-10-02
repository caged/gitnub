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
// GNOutlineView.m
//
//
//      Implements a "source list" outline view using GDSourceListCell.
//
//      The rows in the outline view are scaled according to the font size
//      used by the data cell of the outline column and the property
//      rowHeightToFontHeightRatio (default: 1.25).
//
//      GDSourceListCell scales the icons to the height of the rows, up to
//      the limit specified by the maxIconScale property (default: 1.0).

#import "GNOutlineView.h"


static NSString* const kOutlineCellFontKeyPath  = @"outlineTableColumn.dataCell.font";

@interface GNOutlineView (PrivateMethods)
- (void)adjustRowHeight;
- (void)windowKeyStatusDidChange:(NSNotification *)note;
@end


@implementation GNOutlineView (PrivateMethods)

// Adjusts row height according to font of outline column & selected ratio:
- (void)adjustRowHeight
{
    float fontSize = [[[[self outlineTableColumn] dataCell] font] pointSize];

    [self setRowHeight: floor([self rowHeightToFontHeightRatio] * fontSize)];
}

- (void)windowKeyStatusDidChange:(NSNotification *)note
{
    [self setNeedsDisplay];
}

@end


@implementation GNOutlineView


- (NSImage *)iconForRow:(int)rowIndex
{
    NSImage*    icon        = nil;
    id          delegate    = [self delegate];

    // Check delegate first:
    if ([delegate respondsToSelector: @selector(outlineView:iconOfItem:)])
    {
        icon = [[self delegate] outlineView: self iconOfItem: [self itemAtRow: rowIndex]];
    }

    // Then check dataSource:
    if (icon == nil)
    {
        icon = [[self dataSource] outlineView: self iconOfItem: [self itemAtRow: rowIndex]];
    }

    return icon;
}

- (float)maxIconScale
{
    return m_maxIconScale;
}

- (void)setMaxIconScale:(float)scale
{
    m_maxIconScale = scale;
    [self setNeedsDisplay];
}

- (float)rowHeightToFontHeightRatio
{
    return m_rowHeightToFontHeightRatio;
}

- (void)setRowHeightToFontHeightRatio:(float)ratio
{
    if (ratio < 1.375)
    {
        ratio = 1.375;
    }
    m_rowHeightToFontHeightRatio = ratio;
    [self adjustRowHeight];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // Watch for font updates:
    if (context == (void *)kOutlineCellFontKeyPath)
    {
        [self adjustRowHeight];
    }
}

// ----------------------------------------------------------------------------
#pragma mark Superclass Methods:
// ----------------------------------------------------------------------------

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super initWithCoder: decoder])
    {

        [self setRowHeightToFontHeightRatio: 1.7]; // Finder small icons
        //[self setRowHeightToFontHeightRatio: 2.0 + 2.0/3.0]; // Finder large icons
        [self setMaxIconScale: 0.5];

        // Monitor outline column font size for changes:
        [self addObserver: self
               forKeyPath: kOutlineCellFontKeyPath
                  options: NSKeyValueObservingOptionNew
                  context: kOutlineCellFontKeyPath];

        // Replace the NSTextFieldCell of the outline column with a
        // GDSourceListCell that is initialized with the same attributes:
        NSData*         archiverData    = [NSArchiver archivedDataWithRootObject: [[self outlineTableColumn] dataCell]];
        NSUnarchiver*   unarchiver      = [[[NSUnarchiver alloc] initForReadingWithData: archiverData] autorelease];

        [unarchiver decodeClassName: @"NSTextFieldCell" asClassName: @"GNSourceListCell"];

        [[self outlineTableColumn] setDataCell: [unarchiver decodeObject]];
    }

    return self;
}

- (void)dealloc
{
    [self removeObserver: self forKeyPath: kOutlineCellFontKeyPath];
    [super dealloc];
}

// Column selection is not implemented:
- (BOOL)allowsColumnSelection
{
    return NO;
}


@end
