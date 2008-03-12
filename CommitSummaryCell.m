//
//  CommitSummaryCell.m
//  GitNub
//
//  Created by local22 on 3/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "CommitSummaryCell.h"

#define PADDING (2.0)
#define GRAVATAR_WIDTH (36.0)

@implementation CommitSummaryCell
- (void)dealloc {
    [titleCell release];
    [subtitleCell release];
    [gravatarCell release];
    
    [super dealloc];
}

- (id)init {
    self = [super init];
    if(self) {
        titleCell = [[NSTextFieldCell alloc] init];
        [titleCell setFont:[NSFont systemFontOfSize:[NSFont systemFontSize]]];
        [titleCell setLineBreakMode:NSLineBreakByTruncatingTail];
        
        subtitleCell = [[NSTextFieldCell alloc] init];
        [subtitleCell setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
        [subtitleCell setLineBreakMode:NSLineBreakByTruncatingTail];
        
        gravatarCell = [[NSImageCell alloc] init];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    CommitSummaryCell *copy = [super copyWithZone:zone];
    if(copy) {
        copy->titleCell = [titleCell copyWithZone:zone];
        copy->subtitleCell = [subtitleCell copyWithZone:zone];
        copy->gravatarCell = [gravatarCell copyWithZone:zone];
    }
    return copy;
}

- (void)setGravatarImage:(NSImage *)image {
    [gravatarCell setImage:image];
}

- (void)setSubtitle:(NSString *)string {
    [subtitleCell setStringValue:string];
}

- (void)setObjectValue:(id)object {
    [titleCell setObjectValue:object];
}

- (void)setBackgroundStyle:(NSBackgroundStyle)style {
    [super setBackgroundStyle:style];
    
    [titleCell setBackgroundStyle:style];
    
    [subtitleCell setBackgroundStyle:style];
    [subtitleCell setTextColor:(style == NSBackgroundStyleLight) ? [NSColor disabledControlTextColor] : [NSColor controlTextColor]];
}

- (NSRect)expansionFrameWithFrame:(NSRect)cellFrame inView:(NSView *)view {
    NSSize fullSize = [[titleCell attributedStringValue] size];
    fullSize.width += PADDING + GRAVATAR_WIDTH;
    
    if(fullSize.width > NSWidth(cellFrame)) {
        cellFrame.size.width = fullSize.width;
    } else {
        cellFrame = NSZeroRect;
    }
    
    return cellFrame;
}

- (NSRect)titleRectForBounds:(NSRect)theRect {
    NSRect imageRect, titleRect;
    theRect = NSInsetRect(theRect, PADDING, PADDING);
    NSDivideRect(theRect, &imageRect, &titleRect, GRAVATAR_WIDTH + 4, NSMinXEdge);
    NSSize stringSize = [[titleCell attributedStringValue] size];
    //titleRect.origin.y += (NSHeight(titleRect) - stringSize.height)/2.0;
    titleRect.origin.x += PADDING;
    titleRect.size.height = stringSize.height;
    
    return titleRect;
}

- (NSRect)subtitleRectForBounds:(NSRect)theRect {
    theRect = [self titleRectForBounds:theRect];
    theRect.origin.y += NSHeight(theRect) + PADDING;
    return theRect;
}

- (NSRect)gravatarRectForBounds:(NSRect)theRect {
    NSRect imageRect, titleRect;
    theRect = NSInsetRect(theRect, PADDING, PADDING);
    NSDivideRect(theRect, &imageRect, &titleRect, GRAVATAR_WIDTH + 4, NSMinXEdge);
    return imageRect;
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)view {
    [titleCell drawInteriorWithFrame:[self titleRectForBounds:cellFrame] inView:view];
    [subtitleCell drawInteriorWithFrame:[self subtitleRectForBounds:cellFrame] inView:view];
    [gravatarCell drawInteriorWithFrame:[self gravatarRectForBounds:cellFrame] inView:view];
}
@end
