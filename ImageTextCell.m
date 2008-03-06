//
//  ImageTextCell.m
//  SofaControl
//
//  Created by Martin Kahr on 10.10.06.
//  Copyright 2006 CASE Apps. All rights reserved.
//

#import "ImageTextCell.h"

@implementation ImageTextCell

- (void)dealloc {
	[self setDataDelegate: nil];
	[self setIconKeyPath: nil];
	[self setPrimaryTextKeyPath: nil];
	[self setSecondaryTextKeyPath: nil];
    [super dealloc];
}

- copyWithZone:(NSZone *)zone {
	ImageTextCell *cell = (ImageTextCell *)[super copyWithZone:zone];
	cell->delegate = nil;
	[cell setDataDelegate: delegate];
    return cell;
}

- (void) setIconKeyPath: (NSString*) path {
	[iconKeyPath autorelease];
	iconKeyPath = [path retain];
}
- (void) setPrimaryTextKeyPath: (NSString*) path {
	[primaryTextKeyPath autorelease];
	primaryTextKeyPath = [path retain];	
}
- (void) setSecondaryTextKeyPath: (NSString*) path {
	[secondaryTextKeyPath autorelease];
	secondaryTextKeyPath = [path retain];	
}

- (void) setDataDelegate: (NSObject*) aDelegate {
	[aDelegate retain];	
	[delegate autorelease];
	delegate = aDelegate;	
}

- (id) dataDelegate {
	if (delegate) return delegate;
	return self; // in case there is no delegate we try to resolve values by using key paths
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	[self setTextColor:[NSColor blackColor]];
	
	NSObject* data = [self objectValue];
	
	// give the delegate a chance to set a different data object
	if ([[self dataDelegate] respondsToSelector: @selector(dataElementForCell:)]) {
		data = [[self dataDelegate] dataElementForCell:self];
	}
		
	//TODO: Selection with gradient and selection color in white with shadow
	// check out http://www.cocoadev.com/index.pl?NSTableView
	
	BOOL elementDisabled    = NO;	
	if ([[self dataDelegate] respondsToSelector: @selector(disabledForCell:data:)]) {
		elementDisabled = [[self dataDelegate] disabledForCell: self data: data];
	}
	
	NSColor* primaryColor   = [self isHighlighted] ? [NSColor alternateSelectedControlTextColor] : (elementDisabled? [NSColor disabledControlTextColor] : [NSColor textColor]);
	NSString* primaryText   = [[self dataDelegate] primaryTextForCell:self data: data];
    NSMutableParagraphStyle* style = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
    [style setLineBreakMode:NSLineBreakByTruncatingTail];

	NSDictionary* primaryTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys: 
	    primaryColor, NSForegroundColorAttributeName,
		[NSFont systemFontOfSize:12], NSFontAttributeName, 
		style, NSParagraphStyleAttributeName, 
		nil];	
	[primaryText drawAtPoint:NSMakePoint(cellFrame.origin.x+cellFrame.size.height+9, cellFrame.origin.y) withAttributes:primaryTextAttributes];
	
	NSColor* secondaryColor = [self isHighlighted] ? [NSColor alternateSelectedControlTextColor] : [NSColor disabledControlTextColor];
	NSString* secondaryText = [[self dataDelegate] secondaryTextForCell:self data: data];
	NSDictionary* secondaryTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys: secondaryColor, NSForegroundColorAttributeName,
		[NSFont systemFontOfSize:10], NSFontAttributeName, nil];	
	[secondaryText drawAtPoint:NSMakePoint(cellFrame.origin.x+cellFrame.size.height+9, cellFrame.origin.y+cellFrame.size.height/2.2) 
				withAttributes:secondaryTextAttributes];
	
	
	[[NSGraphicsContext currentContext] saveGraphicsState];
	float yOffset = cellFrame.origin.y;
	if ([controlView isFlipped]) {
		NSAffineTransform* xform = [NSAffineTransform transform];
		[xform translateXBy:0.0 yBy: cellFrame.size.height];
		[xform scaleXBy:1.0 yBy:-1.0];
		[xform concat];		
		yOffset = 0-cellFrame.origin.y;
	}	
	NSImage* icon = [[self dataDelegate] iconForCell:self data: data];	
	
	NSImageInterpolation interpolation = [[NSGraphicsContext currentContext] imageInterpolation];
	[[NSGraphicsContext currentContext] setImageInterpolation: NSImageInterpolationHigh];	
	
	[icon drawInRect:NSMakeRect(cellFrame.origin.x+3,yOffset+3,cellFrame.size.height-6, cellFrame.size.height-6)
			fromRect:NSMakeRect(0,0,[icon size].width, [icon size].height)
		   operation:NSCompositeSourceOver
			fraction:1.0];
	
	[[NSGraphicsContext currentContext] setImageInterpolation: interpolation];
	
	[[NSGraphicsContext currentContext] restoreGraphicsState];	
}

#pragma mark - 
#pragma mark Delegate methods

- (NSImage*) iconForCell: (ImageTextCell*) cell data: (NSObject*) data {
	if (iconKeyPath) {
		return [data valueForKeyPath: iconKeyPath];
	}
	return nil;
}
- (NSString*) primaryTextForCell: (ImageTextCell*) cell data: (NSObject*) data {
	if (primaryTextKeyPath) {
		return [data valueForKeyPath: primaryTextKeyPath];
	}
	return nil;	
}
- (NSString*) secondaryTextForCell: (ImageTextCell*) cell data: (NSObject*) data {
	if (primaryTextKeyPath) {
		return [data valueForKeyPath: secondaryTextKeyPath];
	}
	return nil;		
}

@end
