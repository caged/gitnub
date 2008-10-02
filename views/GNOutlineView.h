//
// GNOutlineView.h
//

#import <Cocoa/Cocoa.h>


@interface GNOutlineView : NSOutlineView
{
    float       m_rowHeightToFontHeightRatio;
    float       m_maxIconScale;
}
                         // default: system color

// GDSourceListTableViewMethods:
- (NSImage *)iconForRow: (int)rowIndex;
- (float)maxIconScale;
- (void)setMaxIconScale:(float)scale;                   // default: 1.0

- (float)rowHeightToFontHeightRatio;
- (void)setRowHeightToFontHeightRatio:(float)ratio;     // default: 2 2/3
@end

@interface NSObject (GDSourceListCell)
// The data source MUST implement this method to return an icon for the row:
- (NSImage *)outlineView: (NSOutlineView *)outlineView iconOfItem: (id)item;
@end
