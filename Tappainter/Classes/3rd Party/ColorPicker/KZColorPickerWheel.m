//
//  KZColorPickerWheel.m
//  Tappainter
//
//  Created by Vadim on 10/7/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import "KZColorPickerWheel.h"
#import "UtilityCategories.h"

#define MARKER_ALPHA 0.6

@interface KZColorPickerWheel() {
    double previousTouchAngle_;;
    double currectAngle_;
}

@end

@implementation KZColorPickerWheel

@synthesize currentAngle=currectAngle_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _wheelImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _wheelImageView.userInteractionEnabled = YES;
        [self addSubview:_wheelImageView];
        self.layer.cornerRadius = self.bounds.size.width/2;
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor grayColor];
        _markerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"colorwheel-marker"]];
        _markerImageView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        [_markerImageView moveVerticallyTo:0];
        _markerImageView.alpha = MARKER_ALPHA;
        [self addSubview:_markerImageView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.layer.cornerRadius = self.bounds.size.width/2;
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor grayColor];
        _markerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"colorwheel-marker"]];
        _markerImageView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        [_markerImageView moveVerticallyTo:0];
        _markerImageView.alpha = MARKER_ALPHA;
        [self addSubview:_markerImageView];
    }
    return  self;
}

- (void)setValue:(float)value {
    float newAngle = [self angleFromValue:value];
    [self rotateToAngle:newAngle];
//    NSLog(@"SetValue: %f newAngle: %f", value, newAngle);
    _value = value;
}

- (void)setImage:(UIImage *)image {
    _wheelImageView.image = image;
}

- (UIImage*)image {
    return _wheelImageView.image;
}


- (void)rotateBy:(float)angle{
//    NSLog(@"Rotate by %f", angle);
    [self rotateToAngle:(currectAngle_+ angle)];
}

- (void)rotateToAngle:(float)angle {
//    NSLog(@"Rotate to: %f", angle);
    CGAffineTransform transform = CGAffineTransformMakeRotation(angle);
    self.imageView.transform = transform;
    currectAngle_ = angle;
    _value = [self valueFromAngle:currectAngle_];
//    NSLog(@"New value: %f", _value);
}


- (BOOL) pointInside:(CGPoint)point {
    float xDisanceFromCenter = point.x - self.imageView.bounds.size.width/2;
    float yDistanceFromCenter = point.y - self.imageView.bounds.size.height/2;
    float distanceFromCenter = sqrt(xDisanceFromCenter*xDisanceFromCenter + yDistanceFromCenter*yDistanceFromCenter);
    if (distanceFromCenter > self.imageView.bounds.size.width/2 ) {
        return NO;
    }
    
    return YES;
}

- (double)angleFromPoint:(CGPoint)point {
//    NSLog(@"Point: %@", POINT_TO_STRING(point));
	CGPoint center = CGPointMake(self.bounds.size.width * 0.5,
								 self.bounds.size.height * 0.5);
//    double radius = self.bounds.size.width * 0.5;
    double dx = ABS(point.x - center.x);
    double dy = ABS(point.y - center.y);
    double angle = atan(dy / dx);
	if (isnan(angle))
		angle = 0.0;
	
//    double dist = sqrt(pow(dx, 2) + pow(dy, 2));
//    double saturation = MIN(dist/radius, 1.0);
//	
//	if (dist < 10)
//        saturation = 0; // snap to center
	
    if (point.x < center.x)
        angle = M_PI - angle;
	
    if (point.y > center.y)
        angle = 2.0 * M_PI - angle;
    
    return angle;
}


- (UIView*) hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if ([self pointInside:point]) {
        return self;
    }
    
    return nil;
}

- (float)valueFromAngle:(float)angle {
    double intpart;
    float value = modf(angle/(2*M_PI),&intpart);
    if (angle > 0)
        value = 1-value;
    else
        value = fabs(value);
//    NSLog(@"value: %f from angle: %f", value, angle);
    return value;
}

- (float)angleFromValue:(float)value {
    float angle = -2*M_PI*value;
//    NSLog(@"angle: %f from value: %f", angle, value);
    return angle;
}

#pragma mark -
#pragma mark Touches
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint mousepoint = [touch locationInView:self.imageView];
    if (![self pointInside:mousepoint]) {
        return NO;
    }
	previousTouchAngle_ = [self angleFromPoint:[touch locationInView:self]];
    
//    NSLog(@"previousTouchAngle_: %f", previousTouchAngle_);
    _markerImageView.alpha = 0;
    [self performBlock:^(id arg) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            _markerImageView.alpha = MARKER_ALPHA;
        } completion:nil];
    } withObject:0 afterDelay:0.1];
	return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    double newAngle = [self angleFromPoint:[touch locationInView:self]];
//    NSLog(@"NewAngle: %f", newAngle);
    [self rotateBy:-(newAngle-previousTouchAngle_)];
    previousTouchAngle_ = newAngle;
	[self sendActionsForControlEvents:UIControlEventValueChanged];
	return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
//    NSLog(@"End tracking");
	[self continueTrackingWithTouch:touch withEvent:event];
//    _markerImageView.alpha = 0;
}




@end
