//
//  TPEditedImageCell.h
//  Tappainter
//
//  Created by Vadim on 10/17/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPImageCellDelegate.h"

@class TPImageAsset;
@interface TPEditedImageCell : UICollectionViewCell

@property (nonatomic) TPImageAsset* imageAsset;
@property (nonatomic) bool isOriginalImage;
@property (nonatomic) bool chosen;
@property __weak id<TPImageCellDelegate> delegate;
@property bool deletable;

@end
