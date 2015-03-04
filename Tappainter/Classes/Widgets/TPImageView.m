//
//  TPImageView.m
//  Tappainter
//
//  Created by Vadim on 2/15/14.
//  Copyright (c) 2014 MDi Touch. All rights reserved.
//

#import "TPImageView.h"
#import "UtilityCategories.h"

@implementation TPImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)setImage:(UIImage *)image {
    if (image.size.width > image.size.height) {
        // Landscape image. Just scale it to fill up the whole view
        self.contentMode = UIViewContentModeScaleToFill;
        _contentFrame = self.bounds;
    } else {
        // Portrie image, scale it oaintaining the aspect fit
        self.contentMode = UIViewContentModeScaleAspectFit;
        float contentWidth = self.frame.size.height/image.size.height*image.size.width;
        _contentFrame = self.bounds;
        _contentFrame.origin.x += (self.bounds.size.width - contentWidth)/2;
        _contentFrame.size.width = contentWidth;
    }
    [super setImage:[UIImage imageNamed:@"InnerCanvas"]]; // Clear first
    [super setImage:image];
}


- (UIColor*) getPixelColorAtLocation:(CGPoint)point
{
    point.x -= _contentFrame.origin.x;
    point.x *= _contentFrame.size.width/self.image.size.width;
    point.y *= _contentFrame.size.height/self.image.size.height;
    return [self.image getPixelColorAtLocation:point];
}

- (CGPoint)positionInImage:(CGPoint)viewPosition {
    NSLog(@"Position in View: %@", POINT_TO_STRING(viewPosition));
    NSLog(@"Image size: %@", SIZE_TO_STRING(self.image.size));
    viewPosition.x -= _contentFrame.origin.x;
    viewPosition.x /= _contentFrame.size.width/self.image.size.width;
    viewPosition.y /= _contentFrame.size.height/self.image.size.height;
    NSLog(@"Position in Image: %@", POINT_TO_STRING(viewPosition));
    return viewPosition;
}

@end
