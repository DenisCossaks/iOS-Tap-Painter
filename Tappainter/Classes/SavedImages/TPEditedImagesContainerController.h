//
//  TPEditedImagesContainerController.h
//  Tappainter
//
//  Created by Vadim on 10/17/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TPImageAsset;
@protocol TPEditedImagesContainerControllerDelegate <NSObject>

- (void)willDismiss;

@end

@interface TPEditedImagesContainerController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *originalImagesContainerView;
@property (nonatomic) TPImageAsset* originalImageAsset;
@property id<TPEditedImagesContainerControllerDelegate> delegate;
@end
