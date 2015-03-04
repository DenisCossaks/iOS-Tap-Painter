//
//  TPBrandSelectionViewController.h
//  Tappainter
//
//  Created by Vadim on 11/10/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UpgradeProductEngine.h"

@class TPPin;
@class TPColor;
@interface TPBrandSelectionViewController : UITableViewController<UIAlertViewDelegate, UpgradeProductEngineDelegate>

@property TPPin* colorMarker;
@property (nonatomic) TPColor* tpColor;

@end
