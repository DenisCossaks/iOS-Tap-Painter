//
//  KZColorPickerBrightnessSlider.h
//
//  Created by Alex Restrepo on 5/11/11.
//  Copyright 2011 KZLabs http://kzlabs.me
//  All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class CMColorPickerSliderGradient;
@interface KZColorPickerBrightnessSlider : KZUnitSlider
{
    CAGradientLayer *gradientLayer;
    UIColor* keyColor_;
}
- (void) setKeyColor:(UIColor *)c;
@end
