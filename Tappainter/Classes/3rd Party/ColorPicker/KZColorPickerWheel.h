//
//  KZColorPickerWheel.h
//  Tappainter
//
//  Created by Vadim on 10/7/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KZColorPickerWheel;

@interface KZColorPickerWheel : UIControl {
//	UIImageView *wheelImageView;
}

@property (nonatomic) UIImage* image;
@property (getter = imageView, readwrite) IBOutlet UIImageView *wheelImageView;
@property (nonatomic) float value;
@property (readonly) double currentAngle;
@property UIImageView* markerImageView;


- (float)angleFromValue:(float)value;
- (float)valueFromAngle:(float)angle;
- (BOOL) pointInside:(CGPoint)point;

@end
