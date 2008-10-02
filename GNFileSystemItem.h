//
//  GNFileSystemItem.h
//
//  Based on code examples in NSOutlineView documentation.

#import <Cocoa/Cocoa.h>


@interface GNFileSystemItem : NSObject
{
    NSString *relativePath;
    GNFileSystemItem *parent;
    NSMutableArray *children;
    NSImage *image;
}

+ (GNFileSystemItem *)rootItem;
+ (NSString *)repoRoot;
- (int)numberOfChildren;// Returns -1 for leaf nodes
- (GNFileSystemItem *)childAtIndex:(int)n;// Invalid to call on leaf nodes
- (NSString *)fullPath;
- (NSString *)relativePath;
- (void)setRelativePath:(NSString *)aString;
- (NSImage*)icon;
- (BOOL)isLeafNode;
- (NSDictionary*)attributes;
- (BOOL)isHeading;
@end
