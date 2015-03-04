//
//  TPDraggablePinIcon.m
//  Tappainter
//
//  Created by Vadim on 10/15/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import "TPDraggablePinIcon.h"
#import "TPPin.h"

@interface TPDraggablePinIcon() {
    TPPin* pin_;
}

@end

@implementation TPDraggablePinIcon

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"TPDraggablePinIcon touches begin");
    [super touchesBegan:touches withEvent:event];
    
    self.imageView.alpha = 1;
    [_delegate startedDragging];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"TPDraggablePinIcon touches moved");
    [super touchesMoved:touches withEvent:event];
    
    if (!pin_) {
        UITouch* touch = [touches anyObject];
        CGPoint locationForPin = [touch locationInView:self.imageViewForPin];
        if (CGRectContainsPoint(CGRectInset(self.imageViewForPin.bounds, 60.0, 60.0), locationForPin)) {
            pin_ = [_delegate placePinAtLocation:locationForPin];
            pin_.center = [self.imageViewForPin convertPoint:self.center fromView:self.superview];
            self.imageView.alpha = 0;
        }
    }
    if (pin_) {
        pin_.center = [self.imageViewForPin convertPoint:self.center fromView:self.superview];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    UITouch* touch = [touches anyObject];
    CGPoint locationForPin = [touch locationInView:self.imageViewForPin];
    if (CGRectContainsPoint(CGRectInset(self.imageViewForPin.bounds, 60.0, 60.0), locationForPin)) {
        [self touchesMoved:touches withEvent:event];
    } else {
        if (pin_) {
            [pin_ removeFromSuperview];
            pin_ = nil;
        }
    }
    self.center = self.centerBeforeDrag;
    self.imageView.alpha = 0;
    if (pin_) {
        [_delegate pinAdded:pin_];
    }
    pin_ = nil;
}



@end
