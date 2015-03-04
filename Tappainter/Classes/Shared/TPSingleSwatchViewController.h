//
//  TPSingleSwatchViewController.h
//  Tappainter
//
//  Created by Vadim on 11/12/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import "TPColorPickerBaseViewController.h"
#import "TPBrandData.h"
#import "TPSwatchView.h"

@class TPColor;
@class TPPageData;
@interface TPSingleSwatchViewController : TPColorPickerBaseViewController<TPSwatchViewDelegate>

@property TPPageData* pageData;
@property bool launchedFromSearch;

@property __weak id<TPSwatchViewDelegate> delegate;

@end
