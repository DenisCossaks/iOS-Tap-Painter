//
//  TPImageScrollView.m
//  Tappainter
//
//  Created by Vadim on 10/26/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import "TPImageScrollView.h"
#import "TPImageAsset.h"
#import "UtilityCategories.h"
#import "Defs.h"
#import "TPPhotoDefs.h"
#import "TPSavedImagesManager.h"
#import "TPColorsTableViewController.h"
#import "TPDraggableView.h"
#import "TPPin.h"
#import "UtilityCategories.h"
#import "TPImageView.h"

#define SWATCH_RECT CGRectMake(0,0,404,100)
#define NUM_OF_NEIGHBOR_IMAGES_TO_KEEP 4

@interface TPImageScrollView() {
    TPImageView* originalImageView_;
    void(^scrollCompletionBlock_)(void);
}

@end

@implementation TPImageScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.delegate = self;
#ifdef TAPPAINTER_TRIAL
        self.canCancelContentTouches = YES;
#endif
    }
    return self;
}

- (void)setImageAsset:(TPImageAsset *)imageAsset {
    _imageAsset = imageAsset;
    for (UIImageView* imageView in self.subviews) {
        [self unloadImageView:imageView];
//        imageView.image = nil;
//        [imageView removeFromSuperview];
//        TPColorsTableViewController* controller = [imageView associativeObjectForKey:@"swatchController"];
//        if (controller) {
//            [controller willMoveToParentViewController:nil];
//            [controller removeFromParentViewController];
//            [controller.view removeFromSuperview];
//            [imageView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
//        }
    }
    originalImageView_.image = nil;
    [originalImageView_ removeFromSuperview];
    
    if (imageAsset) {
        self.contentSize = CGSizeMake(self.frame.size.width*(imageAsset.editedAssets.count+1), self.frame.size.height);
        originalImageView_ = [[TPImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        originalImageView_.image = imageAsset.originalAsset.image;
        originalImageView_.userInteractionEnabled = YES; // We need that for the marker to be draggable when it's placed on top
        [self addSubview:originalImageView_];
        
//        int contentOffsetX = 0;
//        
//        for (TPImageAsset* asset in imageAsset.editedAssets) {
//            TPImageView* imageView = [[TPImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
//            imageView.image = asset.image;
//            imageView.userInteractionEnabled = YES; // We need that for the marker to be draggable when it's placed on top
//            NSInteger index = [imageAsset.editedAssets indexOfObject:asset];
//            int offset = imageView.bounds.size.width*(index+1);
//            [imageView moveToOrigin:CGPointMake(offset, 0)];
//            if (asset == imageAsset.selectedImageAsset) {
//                contentOffsetX = offset;
//            }
//            [self addSubview:imageView];
//            
//            if (asset.tpColor) {
//                // Add draggable color swatch view at the bottom
//                TPDraggableView* swatchView = [[TPDraggableView alloc] initWithFrame:SWATCH_RECT];
//                swatchView.clipsToBounds = YES;
//                swatchView.backgroundColor = [UIColor whiteColor];
//                TPColorsTableViewController* controller = [[TPColorsTableViewController alloc] init];
//                controller.colorMarker = asset.colorMarker;
//                controller.view.frame = CGRectInset(SWATCH_RECT, 2, 2);
//                [swatchView moveToOrigin:CGPointMake(0, imageView.bounds.size.height - swatchView.bounds.size.height)];
//                [imageView addSubview:swatchView];
//                [_parentController addChildViewController:controller];
//                [swatchView addSubview:controller.view];
//                [controller didMoveToParentViewController:_parentController];
//                controller.tableView.scrollEnabled = NO;
//                controller.tableView.allowsSelection = NO;
//                controller.tpColors = [NSArray arrayWithObject:asset.tpColor];
//                [imageView setAssociativeObject:controller forKey:@"swatchController"];
//            }
//        }
//        
        if (imageAsset.selectedImageAsset != _imageAsset.originalAsset) {
            NSInteger index = [imageAsset.editedAssets indexOfObject:imageAsset.selectedImageAsset];
            
            [self loadEditedAssetForIndex:index];
            [self loadNeghborsForIndex:index];
            
            int offset = self.bounds.size.width*(index+1);
            [self setContentOffset:CGPointMake(offset, 0) animated:NO];
        } else {
            [self loadNeghborsForIndex:-1];
        }
        
        self.delegate = self;
    }
}

- (void)loadEditedAssetForIndex:(NSInteger)index {
    if (index < 0 || index >= _imageAsset.editedAssets.count) return;

    UIView* view = [self viewWithTag:index+100];
    if (view) return; // already loaded

    TPImageAsset* asset = _imageAsset.editedAssets[index];
    
    TPImageView* imageView = [[TPImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    imageView.userInteractionEnabled = YES; // We need that for the marker to be draggable when it's placed on top
    
    imageView.image = [asset image];
//    CGImageRelease(imageView.image.CGImage);
    imageView.tag = 100+index;
    int offset = imageView.bounds.size.width*(index+1);
    [imageView moveToOrigin:CGPointMake(offset, 0)];
    [self addSubview:imageView];
    
    if (asset.tpColor) {
        // Add draggable color swatch view at the bottom
        TPDraggableView* swatchView = [[TPDraggableView alloc] initWithFrame:SWATCH_RECT];
        swatchView.clipsToBounds = YES;
        swatchView.backgroundColor = [UIColor whiteColor];
        TPColorsTableViewController* controller = [[TPColorsTableViewController alloc] init];
        controller.colorMarker = asset.colorMarker;
        controller.view.frame = CGRectInset(SWATCH_RECT, 2, 2);
        [swatchView moveToOrigin:CGPointMake(0, imageView.bounds.size.height - swatchView.bounds.size.height)];
        [imageView addSubview:swatchView];
        [_parentController addChildViewController:controller];
        [swatchView addSubview:controller.view];
        [controller didMoveToParentViewController:_parentController];
        controller.tableView.scrollEnabled = NO;
        controller.tableView.allowsSelection = NO;
        controller.tpColors = [NSArray arrayWithObject:asset.tpColor];
        [imageView setAssociativeObject:controller forKey:@"swatchController"];
    }
}

- (void)unloadImageView:(UIImageView*)imageView {
    imageView.image = nil;
    [imageView removeFromSuperview];
    TPColorsTableViewController* controller = [imageView associativeObjectForKey:@"swatchController"];
    if (controller) {
        [controller willMoveToParentViewController:nil];
        [controller removeFromParentViewController];
        [controller.view removeFromSuperview];
        [imageView removeAssociativeObjectForKey:@"swatchController"];
        [imageView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
}

- (UIImageView*)imageViewAtLocation:(CGPoint)location {
    for (UIImageView* view in self.subviews) {
        int adjustedXPosition = view.frame.origin.x - self.contentOffset.x;
        if (location.x >= adjustedXPosition && location.x <= adjustedXPosition+view.frame.size.width) {
            return view;
        }
    }
    
    return nil;
}

- (UIImageView*)imageViewAtOffset:(float)offsetX {
    int index = offsetX/self.bounds.size.width;
    if (index == 0) return originalImageView_;
    
//    if (index < self.subviews.count) {
        return (UIImageView*)[self viewWithTag:(100+index-1)];
//    }
    return nil;
}

- (void)unloadAllButNehgborsOf:(int)index {
    for (UIImageView* imageView in self.subviews) {
        if (imageView != originalImageView_) {
            if (imageView.tag - 100 < index - NUM_OF_NEIGHBOR_IMAGES_TO_KEEP || imageView.tag - 100 > index + NUM_OF_NEIGHBOR_IMAGES_TO_KEEP) {
                [self unloadImageView:imageView];
            }
        }
    }
}

- (void)loadNeghborsForIndex:(NSInteger)index {
    for (int i = 1; i <= NUM_OF_NEIGHBOR_IMAGES_TO_KEEP; i++ ) {
        [self loadEditedAssetForIndex:index-i];
        [self loadEditedAssetForIndex:index+i];
    }
}

- (UIImageView*)originalImageView {
    return originalImageView_;
}

- (void)scrollToOriginal {
    [self setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)scrollToAsset:(TPImageAsset *)asset {
    if (asset == _imageAsset.originalAsset) {
        [self scrollToOriginal];
    } else {
        if ([_imageAsset.editedAssets containsObject:asset]) {
            NSInteger index = [_imageAsset.editedAssets indexOfObject:asset];
            [self setContentOffset:CGPointMake(self.bounds.size.width*(index+1), 0) animated:YES];
       }
    }
}

- (void)scrollToAsset:(TPImageAsset *)asset withCompletionBlock:(void (^)(void))block {
    scrollCompletionBlock_ = block;
    [self scrollToAsset:asset];
}

- (void)scrollToPreviousAsset {
    if ([TPSavedImagesManager selectedImageAsset] != _imageAsset.originalAsset) {
            NSInteger index = [_imageAsset.editedAssets indexOfObject:[TPSavedImagesManager selectedImageAsset]] - 1;
            [self setContentOffset:CGPointMake(self.bounds.size.width*(index+1), 0) animated:YES];
    }
}


- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (!self.scrollEnabled) {
        return nil;
    } else {
        return [super hitTest:point withEvent:event];
    }
}

- (void)loadImageAtCurrentOffset {
    int pageNumber = self.contentOffset.x/self.frame.size.width;
    [self unloadAllButNehgborsOf:pageNumber-1];
    [self loadEditedAssetForIndex:pageNumber-1];
    [self loadNeghborsForIndex:pageNumber-1];
}

//- (void)setScrollEnabled:(BOOL)scrollEnabled {
//#ifdef TAPPAINTER_TRIAL
////    scrollEnabled = NO;
//#endif
//    [super setScrollEnabled:scrollEnabled];
//}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
#ifdef TAPPAINTER_TRIAL
    return NO; // Disable image scrolling for Lite
#else
    return YES;
#endif
}

#pragma mark- UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    int pageNumber = self.contentOffset.x/self.frame.size.width;
    TPImageAsset* selectedAsset;
    if (pageNumber == 0) {
        selectedAsset = _imageAsset.originalAsset;
    } else {
        selectedAsset = _imageAsset.editedAssets[pageNumber-1];
    }
    [TPSavedImagesManager setSelectedImageAsset:selectedAsset];
    [_tpDelegate selectedAssetChanged:selectedAsset];
    
    [self loadImageAtCurrentOffset];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (scrollCompletionBlock_) {
        scrollCompletionBlock_();
        scrollCompletionBlock_ = nil;
    }
    
    [self loadImageAtCurrentOffset];
}

@end
