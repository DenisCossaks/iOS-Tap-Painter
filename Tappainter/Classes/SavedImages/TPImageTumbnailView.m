//
//  TPImageTumbnailView.m
//  Tappainter
//
//  Created by Vadim on 10/13/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import "TPImageTumbnailView.h"

@interface TPImageTumbnailView() {
    __weak IBOutlet UIImageView *imageView_;
}

@end

@implementation TPImageTumbnailView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setImage:(UIImage *)image {
    imageView_.image = image;
}

- (UIImage*)image {
    return imageView_.image;
}

- (void)setSelected:(bool)selected {
    if (selected)
        self.backgroundColor = [UIColor yellowColor];
    else
        self.backgroundColor = [UIColor whiteColor];
    _selected = selected;
}

- (UIView*) hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if ([self pointInside:point withEvent:event]) {
        [_delegate thumbnailViewClicked:self];
        return self;
    }
    return nil;
}
@end
