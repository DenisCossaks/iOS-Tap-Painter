//
//  KZColorPickerWheelHue.m
//
//  Created by Alex Restrepo on 5/11/11.
//  Modified by Vadim Dagman on 10/04/2013
//  Copyright 2011 KZLabs http://kzlabs.me
//  All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "KZColorPickerWheelHue.h"
#import "UtilityCategories.h"


@interface KZColorPickerWheelHue() {
    double beginTouchAngle_;
    double currectAngle_;
    CGPoint pointForColor_;
}
@end

@implementation KZColorPickerWheelHue

- (id)initWithImage:(UIImage *)image {
    NSAssert(image, @"Image has to be provided");
    self = [super initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    if (self) {
        self.image = image;
        currectAngle_ = 0;
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        currectAngle_ = 0;
        [self.markerImageView moveVerticallyTo:4];
    }
    return self;
}

@end
