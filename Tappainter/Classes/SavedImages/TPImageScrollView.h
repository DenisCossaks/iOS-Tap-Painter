//
//  TPImageScrollView.h
//  Tappainter
//
//  Created by Vadim on 10/26/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TPImageAsset;
@class TPImageView;
@protocol TPImageScrollViewDelegate <NSObject>

- (void)selectedAssetChanged:(TPImageAsset*)imageAsset;

@end

@interface TPImageScrollView : UIScrollView<UIScrollViewDelegate>

@property (nonatomic) TPImageAsset* imageAsset;
@property __weak IBOutlet id<TPImageScrollViewDelegate> tpDelegate;
@property __weak IBOutlet UIViewController* parentController;

- (TPImageView*) imageViewAtLocation:(CGPoint)location;
- (TPImageView*)imageViewAtOffset:(float)offsetX;
- (TPImageView*) originalImageView;
- (void)scrollToOriginal;
- (void)scrollToAsset:(TPImageAsset*)asset;
- (void)scrollToAsset:(TPImageAsset*)asset withCompletionBlock:(void (^)(void))block;
- (void)scrollToPreviousAsset;
@end
