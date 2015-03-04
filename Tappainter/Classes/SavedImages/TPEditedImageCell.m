//
//  TPEditedImageCell.m
//  Tappainter
//
//  Created by Vadim on 10/17/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import "TPEditedImageCell.h"
#import "TPImageAsset.h"
#import "UtilityCategories.h"

@interface TPEditedImageCell() {
    
    __weak IBOutlet UIView *backGroundView_;
    __weak IBOutlet UIView *selectedBackroundView_;
    __weak IBOutlet UIImageView *imageView_;
    __weak IBOutlet UIImageView *cameraIcon_;
    __weak IBOutlet UIImageView *checkMark_;
    __weak IBOutlet UIButton *deleteButton_;
}

@end

@implementation TPEditedImageCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (_deletable) {
        deleteButton_.hidden = !selected;
    }
}

- (void)layoutSubviews {
    self.backgroundView = backGroundView_;
    self.selectedBackgroundView = selectedBackroundView_;
    self.contentView.clipsToBounds = NO;
    self.clipsToBounds = NO;
}

- (void)setImageAsset:(TPImageAsset *)imageAsset {
    [NSObject performBlockInBackground:^{
        UIImage* image = [imageAsset imageWithSize:imageView_.frame.size];
        [imageView_ performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
    } afterDelay:0];
//    imageView_.image = [imageAsset imageWithSize:imageView_.frame.size];
}

- (void)setIsOriginalImage:(bool)originalImage {
    cameraIcon_.hidden = !originalImage;
}

- (void)setChosen:(bool)chosen {
    _chosen = chosen;
    checkMark_.hidden = !chosen;
}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    CGPoint pointInDeleteButton = [deleteButton_ convertPoint:point fromView:self];
    if ([deleteButton_ hitTest:pointInDeleteButton withEvent:event]) {
        return deleteButton_;
    }
    return [super hitTest:point withEvent:event];
}

- (IBAction)deleteAction:(id)sender {
    [_delegate deleteWanted:self];
}
@end
