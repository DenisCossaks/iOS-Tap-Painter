//
//  TPSavedImagesViewController.h
//  Tappainter
//
//  Created by Vadim on 11/18/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPOriginalThumbsViewController.h"
#import "TPEditedImagesController.h"

@class TPImageAsset;
@interface TPSavedImagesViewController : UIViewController<TPOriginalImagescontrollerDelegate, TPEditedImagesControllerDelegate>

@property TPImageAsset* selectedAsset;

@end
