//
//  TPImageTumbnailView.h
//  Tappainter
//
//  Created by Vadim on 10/13/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TPImageTumbnailView;
@protocol TPImageTumbnailViewDelegate <NSObject>

- (void)thumbnailViewClicked:(TPImageTumbnailView*)thumbnailView;

@end

@interface TPImageTumbnailView : UIView

@property (nonatomic, retain) UIImage* image;
@property __weak id<TPImageTumbnailViewDelegate> delegate;
@property (nonatomic) bool selected;

@end
