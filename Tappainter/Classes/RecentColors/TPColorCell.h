//
//  TPColorCell.h
//  Tappainter
//
//  Created by Vadim on 11/10/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TPColor;
@protocol TPColorCellDelegate <NSObject>
- (void)convertColor:(TPColor*)tpColor;
- (void)useColor:(TPColor*)tpColor;
@end

@class TPColor;
@class TPPin;
@interface TPColorCell : UITableViewCell<UIAlertViewDelegate>

@property (nonatomic) TPColor* tpColor;
@property TPPin* colorMarker;
@property __weak id<TPColorCellDelegate> delegate;
@property bool selectable;

@end
