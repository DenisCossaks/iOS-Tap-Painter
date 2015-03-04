//
//  TPOriginalThumbCell.h
//  Tappainter
//
//  Created by Vadim on 10/16/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPImageCellDelegate.h"

@class TPImageAsset;
@interface TPOriginalThumbCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic) TPImageAsset* imageAsset;
@property __weak id<TPImageCellDelegate> delegate;
@end
