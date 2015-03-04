//
//  TPColorPickerGradientWheel.m
//  Tappainter
//
//  Created by Vadim on 10/11/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import "TPColorPickerGradientWheel.h"
#import "UIColor-Expanded.h"
#import "UtilityCategories.h"

@interface TPColorPickerGradientWheel() {
    UIColor* drawnColor_;
}

@end

@implementation TPColorPickerGradientWheel

- (id)initWithFrame:(CGRect)frame andThickness:(int)thickness
{
    self = [super initWithFrame:frame];
    if (self) {
        _thickness = thickness;
        self.layer.borderWidth = 1.0;
        self.layer.borderColor = [UIColor grayColor].CGColor;
        [self.markerImageView moveVerticallyTo:self.layer.borderWidth];
    }
    return self;
}

- (void)setKeyColor:(UIColor *)c {
    _keyColor = c;
    if (_keyColor != drawnColor_) {
        self.imageView.hidden = YES;
        [self setNeedsDisplay];
    }
}

- (BOOL) pointInside:(CGPoint)point {
    bool inside = [super  pointInside:point];
    if (!inside) {
        float xDisanceFromCenter = point.x - self.imageView.bounds.size.width/2;
        float yDistanceFromCenter = point.y - self.imageView.bounds.size.height/2;
        float distanceFromCenter = sqrt(xDisanceFromCenter*xDisanceFromCenter + yDistanceFromCenter*yDistanceFromCenter);
        if (distanceFromCenter > self.imageView.bounds.size.width/2 || distanceFromCenter < self.imageView.bounds.size.width/2 - _thickness) {
            inside = NO;
        } else {
            inside = YES;
        }
    }
    
    return inside;
}

- (void)setValue:(float)value {
    [super setValue:value];
}

#define NUMBER_OF_SEGMENTS 64
#define OVERLAP_MARGIN  0.5
static CGFloat const kLineWidth = 0;


- (void) drawGradientCircleInFrame:(CGRect)frame startColor:(UIColor*)startColor endColor:(UIColor*)endColor {
    CGContextRef gc = UIGraphicsGetCurrentContext();
    
    for (int i = 0; i < NUMBER_OF_SEGMENTS; i++) {
        float startAngle = 2*M_PI/NUMBER_OF_SEGMENTS*i + M_PI_2;
        startAngle -= 2*M_PI/NUMBER_OF_SEGMENTS*OVERLAP_MARGIN;
        float endAngle = startAngle + 2*M_PI/NUMBER_OF_SEGMENTS;
        endAngle += 2*M_PI/NUMBER_OF_SEGMENTS*OVERLAP_MARGIN;
        float radius = (frame.size.width - _thickness - kLineWidth) / 2;
        //            NSLog(@"i = %d Start Angle: %f End Angle :%f radius: %f", i, startAngle, endAngle, radius);
        CGContextAddArc(gc, frame.size.width / 2, frame.size.height / 2,
                        radius,
                        startAngle, endAngle, NO);
        CGContextSetLineWidth(gc, _thickness);
        CGContextSetLineCap(gc, kCGLineCapButt);
        CGContextReplacePathWithStrokedPath(gc);
        CGContextSaveGState(gc); {
            float overLapValue = 1.0/NUMBER_OF_SEGMENTS*OVERLAP_MARGIN;
            float componentValue = i < NUMBER_OF_SEGMENTS/2 ?
            (1.0/NUMBER_OF_SEGMENTS*2)*i - overLapValue :
            (1.0/NUMBER_OF_SEGMENTS*2)*(NUMBER_OF_SEGMENTS-i) + overLapValue;
            //                    NSLog(@"i=%d startComponentValue = %f", i, componentValue);
            UIColor* firstColor = [UIColor colorWithRed:startColor.red+(endColor.red-startColor.red)*componentValue green:startColor.green+(endColor.green-startColor.green)*componentValue blue:startColor.blue+(endColor.blue-startColor.blue)*componentValue alpha:1];
            
            componentValue = i < NUMBER_OF_SEGMENTS/2 ?
            (1.0/NUMBER_OF_SEGMENTS*2)*(i+1) + overLapValue :
            (1.0/NUMBER_OF_SEGMENTS*2)*(NUMBER_OF_SEGMENTS-i-1) - overLapValue;
            //                    NSLog(@"i=%d endComponentValue = %f", i, componentValue);
            
            UIColor* secondColor = [UIColor colorWithRed:startColor.red+(endColor.red-startColor.red)*componentValue green:startColor.green+(endColor.green-startColor.green)*componentValue blue:startColor.blue+(endColor.blue-startColor.blue)*componentValue alpha:1];
            CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
            CGGradientRef gradient = CGGradientCreateWithColors(rgb, (__bridge CFArrayRef)@[
                                                                                            (__bridge id)firstColor.CGColor,
                                                                                            (__bridge id)secondColor.CGColor
                                                                                            ], (CGFloat[]){ 0.0f, 1.0f });
            CGColorSpaceRelease(rgb);
            
            CGPoint start = CGPointMake(frame.size.width/2*cos(startAngle)+frame.size.width/2,frame.size.width/2*sin(startAngle)+frame.size.width/2);
            CGPoint end = CGPointMake(frame.size.width/2*cos(endAngle)+frame.size.width/2,frame.size.width/2*sin(endAngle)+frame.size.width/2);
            //                    NSLog(@"Start: %@ End: %@", POINT_TO_STRING(start), POINT_TO_STRING(end));
            
            CGContextClip(gc);
            CGContextDrawLinearGradient(gc, gradient, start, end, 0);
            CGGradientRelease(gradient);
        } CGContextRestoreGState(gc);
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    if (drawnColor_ != _keyColor) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSaveGState(context); {
            CGAffineTransform flipVertical = CGAffineTransformMake(
                                                                   1, 0, 0, -1, 0, self.frame.size.height
                                                                   );
            CGContextConcatCTM(context, flipVertical);
            CGContextTranslateCTM(context, self.frame.size.width/2, self.frame.size.height/2);
            CGContextRotateCTM(context, -self.currentAngle);
            CGContextTranslateCTM(context, -self.frame.size.width/2, -self.frame.size.height/2);
            [self drawGradientCircleInFrame:rect startColor:[self startColorForKeyColor:_keyColor] endColor:[self endColorForKeyColor:_keyColor]];
        } CGContextRestoreGState(context);
        drawnColor_ = _keyColor;
    }
}

#pragma mark -
#pragma mark Touches
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if ([super beginTrackingWithTouch:touch withEvent:event]) {
        // Grab image of the gradient circle and put it into image view for rotation
        self.imageView.image = [self imageFromContext];
        self.imageView.hidden = NO;
        return YES;
    } else {
        return NO;
    }
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super endTrackingWithTouch:touch withEvent:event];
    self.imageView.hidden = YES;
    drawnColor_ = nil;
    [self setNeedsDisplay];
}

- (UIImage*) imageFromContext {
    UIImage* image;
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context); {
        CGContextTranslateCTM(context, self.frame.size.width/2, self.frame.size.height/2);
        CGContextRotateCTM(context, -self.currentAngle);
        CGContextTranslateCTM(context, -self.frame.size.width/2, -self.frame.size.height/2);
        [self.layer renderInContext:context];
        image = UIGraphicsGetImageFromCurrentImageContext();
    } CGContextRestoreGState(context);
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIColor*)startColorForKeyColor:(UIColor *)keyColor {
    NSLog(@"startColorForKeyColor has to be overridden in derived class");
    return nil;
}

- (UIColor*)endColorForKeyColor:(UIColor *)keyColor {
    NSLog(@"endColorForKeyColor has to be overridden in derived class");
    return nil;
}


@end
