//
//  TPOriginalThumbsViewController.h
//  Tappainter
//
//  Created by Vadim on 10/16/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPImageCellDelegate.h"

@class TPImageAsset;
@protocol TPOriginalImagescontrollerDelegate <NSObject>

- (void)selectionChanged:(TPImageAsset*)asset;
- (void)originalAssetDeleted;
@end

@interface TPOriginalThumbsViewController : UICollectionViewController<TPImageCellDelegate, UIAlertViewDelegate>

@property __weak id<TPOriginalImagescontrollerDelegate> delegate;
@property (nonatomic) NSString* notificaitonToWatchFor;

@end
