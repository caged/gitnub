//
//  GNSourceListCell.h
//

#import <Cocoa/Cocoa.h>


@interface GNSourceListCell : NSTextFieldCell
{
    float   m_iconOffset;
    float   m_textOffset;
}
- (float)iconOffset;
- (void)setIconOffset:(float)offset;                // default: 12
- (float)textOffset;                                // Spacing from icon
- (void)setTextOffset:(float)offset;                // default: 5.0
@end

// Informal protocol to be implemented by controlling table view:
@interface NSTableView (GDSourceListTableViewMethods)
- (NSImage *)iconForRow: (int)rowIndex;
- (float)maxIconScale;
@end
