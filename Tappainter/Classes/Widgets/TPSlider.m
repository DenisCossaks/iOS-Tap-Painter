//
//  TPSlider.m
//  Tappainter
//
//  Created by Vadim on 11/5/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import "TPSlider.h"

#define TAP_MIN_DISTANCE 0.05

@implementation TPSlider

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch* touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    float value = location.x/self.frame.size.height; // The slider was turned to vertical using affine transform, so the width and height are swapped in the frame
    if (fabs(value-self.value) >  TAP_MIN_DISTANCE) {
        [self setValue:value animated:YES];
        [self sendActionsForControlEvents:UIControlEventTouchDown];
    } else {
        [super touchesBegan:touches withEvent:event];
    }
}


@end
