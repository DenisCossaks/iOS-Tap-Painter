//
//  TPOriginalThumbCell.m
//  Tappainter
//
//  Created by Vadim on 10/16/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import "TPOriginalThumbCell.h"
#import "TPImageAsset.h"
#import <QuartzCore/QuartzCore.h>
#import "UtilityCategories.h"

@interface TPOriginalThumbCell() {
    __weak IBOutlet UIView *contentView_;
    __weak IBOutlet UIView *selectedBackgroundView_;
    __weak IBOutlet UIView *backGroundView_;
    __weak IBOutlet UIView *stackView;
    __weak IBOutlet UILabel *numberLabel_;
    __weak IBOutlet UIButton *deleteButton_;
}

@end

@implementation TPOriginalThumbCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
        self.selectedBackgroundView.backgroundColor = [UIColor yellowColor];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setImageAsset:(TPImageAsset *)imageAsset {
    [self removeObservers];
    self.imageView.image = [imageAsset imageWithSize:self.imageView.frame.size];
    _imageAsset = imageAsset;
    if (imageAsset ) {
        [_imageAsset addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:nil];
        [_imageAsset addObserver:self forKeyPath:@"editedAssets" options:NSKeyValueObservingOptionNew context:nil];
        [_imageAsset addObserver:self forKeyPath:@"markedImageAssets" options:NSKeyValueObservingOptionNew context:nil];
        NSLog(@"Edited images count: %lu", (unsigned long)[_imageAsset editedAssets].count);
        stackView.hidden = [_imageAsset editedAssets].count == 0;
        numberLabel_.hidden = imageAsset.markedImageAssets.count == 0;
    }
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    selectedBackgroundView_.hidden = !selected;
    deleteButton_.hidden = !selected;
}

- (void)layoutSubviews {
    backGroundView_.layer.borderColor = [UIColor grayColor].CGColor;
    backGroundView_.layer.borderWidth = 1;
    selectedBackgroundView_.layer.borderColor = [UIColor grayColor].CGColor;
    selectedBackgroundView_.layer.borderWidth = 1;
    numberLabel_.layer.cornerRadius = numberLabel_.frame.size.width/2;
}

- (void)dealloc {
    [self removeObservers];
}

- (void)removeObservers {
    if (_imageAsset) {
//        id observationInfo = _imageAsset.observationInfo;
//        NSLog(@"Observation Info: %@", observationInfo);
        [_imageAsset removeObserver:self forKeyPath:@"image"];
        [_imageAsset removeObserver:self forKeyPath:@"editedAssets"];
        [_imageAsset removeObserver:self forKeyPath:@"markedImageAssets"];
    }
}

- (IBAction)deleteAction:(id)sender {
    [_delegate deleteWanted:self];
}

#pragma mark- Observers

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    TPImageAsset* imageAsset = (TPImageAsset*)object;
    if ([keyPath isEqualToString:@"image"]) {
        self.imageView.image = [imageAsset imageWithSize:self.imageView.frame.size];
    } else if ([keyPath isEqualToString:@"editedAssets"]) {
        self.imageAsset = imageAsset;
    } else if ([keyPath isEqualToString:@"markedImageAssets"]) {
        if (_imageAsset.markedImageAssets.count) {
            numberLabel_.text = [NSString stringWithInt:(int)_imageAsset.markedImageAssets.count];
            numberLabel_.hidden = NO;
        } else {
            numberLabel_.hidden = YES;
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


@end
