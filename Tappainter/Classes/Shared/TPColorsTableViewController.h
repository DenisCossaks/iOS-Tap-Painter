//
//  TPColorsTableViewController.h
//  Tappainter
//
//  Created by Vadim on 11/30/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TPPin;
@protocol TPColorCellDelegate;
@interface TPColorsTableViewController : UITableViewController

@property (nonatomic) NSArray* tpColors;
@property TPPin* colorMarker;
@property __weak id<TPColorCellDelegate> colorCellDelegate;
@end
