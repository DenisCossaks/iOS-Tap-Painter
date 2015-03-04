//
//  TPPolygonView.m
//  Tappainter
//
//  Created by Vadim on 1/31/14.
//  Copyright (c) 2014 MDi Touch. All rights reserved.
//

#import "TPPolygonView.h"
#import "TPCornerMarker.h"

@implementation TPPolygonView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    if (_corners) {
        // Drawing code
        CGContextRef context= UIGraphicsGetCurrentContext();
        CGContextSetRGBStrokeColor(context, 0.3, 0.3, 0.3, 1);
        
        // Draw outline leaving out the last leg
        CGContextSetLineWidth(context, 2.0);
        for (TPCornerMarker* marker in _corners) {
            if (marker == [_corners firstObject]) {
                CGContextMoveToPoint(context, marker.position.x, marker.position.y);
            } else {
                CGContextAddLineToPoint(context, marker.position.x, marker.position.y);
            }
        }
        CGContextStrokePath(context);
        
        
        for (TPCornerMarker* marker in _corners) {
            if (marker == [_corners firstObject]) {
                CGContextMoveToPoint(context, marker.position.x, marker.position.y);
            } else {
                CGContextAddLineToPoint(context, marker.position.x, marker.position.y);
            }
        }
        TPCornerMarker* marker = [_corners firstObject];
        CGContextAddLineToPoint(context, marker.position.x, marker.position.y);

        CGContextSetRGBFillColor(context, 1, 1, 1, 0.5);
        CGContextFillPath(context);
    }
}

@end
