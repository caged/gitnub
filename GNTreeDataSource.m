#import "GNTreeDataSource.h"
#import "GNFileSystemItem.h"

@implementation GNTreeDataSource

// Data Source methods

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    return (item == nil) ? 1 : [item numberOfChildren];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return (item == nil) ? YES : ([item numberOfChildren] != -1);
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    return (item == nil) ? [GNFileSystemItem rootItem] : [(GNFileSystemItem *)item childAtIndex:index];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    return (item == nil) ? @"/" : (id)[item relativePath];
}

- (NSImage *)outlineView: (NSOutlineView *)outlineView iconOfItem: (id)item
{
    // Note:  -observedObject is needed here due to use of Bindings and the
    //        mess surrounding NSTreeController (described at the URL above).
    //        If you avoid Bindings and use a normal dataSource, you can simply
    //        return [item icon] here, as the actual item will be passed in.

    return [item icon];
}

// Delegate methods
- (BOOL)outlineView:(NSOutlineView *)sender isGroupItem:(id)item {
    return [item isHeading];
}

- (void)outlineView:(NSOutlineView *)sender willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    if ([item isHeading]) {
    NSMutableAttributedString *newTitle = [[cell attributedStringValue] mutableCopy];
    [newTitle replaceCharactersInRange:NSMakeRange(0,[newTitle length]) withString:[[newTitle string] uppercaseString]];
    [cell setAttributedStringValue:newTitle];
    [newTitle release];
 }
}

- (NSCell *)outlineView:(NSOutlineView *)sender dataCellForTableColumn:(id)cell item:(id)item
{
    if([item isHeading])
        return [[[NSTextFieldCell alloc] init] autorelease];
        
   return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
    BOOL isDir;
    [[NSFileManager defaultManager] fileExistsAtPath:[item fullPath] isDirectory:&isDir];
    
    if([item isHeading] || isDir)
        return NO;
        
    return YES;
}

@end

