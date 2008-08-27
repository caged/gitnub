//
//  CommitSummaryCell.h
//  GitNub
//
//  Created by local22 on 3/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CommitSummaryCell : NSTextFieldCell {
    NSTextFieldCell *titleCell;
    NSTextFieldCell *subtitleCell;
    NSImageCell *gravatarCell;
}

- (void)setGravatarImage:(NSImage *)image;
- (void)setSubtitle:(NSString *)string;

@end
