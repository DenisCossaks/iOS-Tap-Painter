//
//  TPEditedImagesController.h
//  Tappainter
//
//  Created by Vadim on 10/17/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPImageCellDelegate.h"

@protocol TPEditedImagesControllerDelegate <NSObject>

- (void)lastImageDeleted;

@end

@class TPImageAsset;

@interface TPEditedImagesController : UICollectionViewController<TPImageCellDelegate, UIAlertViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic) TPImageAsset* originalImageAsset;
// Allows multiple selection dentifying currently selected images by checkmark
@property bool showCheckMark;
@property __weak id<TPEditedImagesControllerDelegate>delegate;

@end
