//
//  KZColorPickerSaturationSlider.h
//
//  Created by Alex Restrepo on 5/11/11.
//  Modified by Vadim Dagman on 9/29/2013
//  Copyright 2011 KZLabs http://kzlabs.me
//  All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "KZUnitSlider.h"

@class CMColorPickerSliderGradient;
@interface KZColorPickerSaturationSlider : KZUnitSlider
{
    CAGradientLayer *gradientLayer;
}
- (void) setKeyColor:(UIColor *)c;
@end
