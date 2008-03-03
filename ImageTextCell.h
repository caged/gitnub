//
//  ImageTextCell.h
//  SofaControl
//
//  Created by Martin Kahr on 10.10.06.
//  Copyright 2006 CASE Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ImageTextCell : NSTextFieldCell {
	NSObject* delegate;
	NSString* iconKeyPath;
	NSString* primaryTextKeyPath;
	NSString* secondaryTextKeyPath;
}

- (void) setDataDelegate: (NSObject*) aDelegate;

- (void) setIconKeyPath: (NSString*) path;
- (void) setPrimaryTextKeyPath: (NSString*) path;
- (void) setSecondaryTextKeyPath: (NSString*) path;

@end

@interface NSObject(ImageTextCellDelegate)

- (NSImage*) iconForCell: (ImageTextCell*) cell data: (NSObject*) data;
- (NSString*) primaryTextForCell: (ImageTextCell*) cell data: (NSObject*) data;
- (NSString*) secondaryTextForCell: (ImageTextCell*) cell data: (NSObject*) data;

// optional: give the delegate a chance to set a different data object
// This is especially useful for those cases where you do not want that NSCell creates copies of your data objects (e.g. Core Data objects).
// In this case you bind a value to the NSTableColumn that enables you to retrieve the correct data object. You retrieve the objects
// in the method dataElementForCell
- (NSObject*) dataElementForCell: (ImageTextCell*) cell;

// optional
- (BOOL) disabledForCell: (ImageTextCell*) cell data: (NSObject*) data;

@end