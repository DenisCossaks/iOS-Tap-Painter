//
//  TPDraggableView.m
//  Tappainter
//
//  Created by Vadim on 11/30/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import "TPDraggableView.h"

@interface TPDraggableView() {
    CGPoint touchBeginLocation_;
    CGPoint originalLocation_;
}

@end

@implementation TPDraggableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    touchBeginLocation_ = [touch locationInView:self.superview];
    originalLocation_ = self.center;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    //    NSLog(@"TPDraggablePinIcon touches moved");
    UITouch* touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.superview];
    CGPoint center = self.center;
    center.x += location.x - touchBeginLocation_.x;
    center.y += location.y - touchBeginLocation_.y;
    self.center = center;
    touchBeginLocation_ = location;
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (CGPoint)centerBeforeDrag {
    return originalLocation_;
}

@end
