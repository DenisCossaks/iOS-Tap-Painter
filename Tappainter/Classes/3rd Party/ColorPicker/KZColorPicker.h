//
//  KZColorWheelView.h
//
//  Created by Alex Restrepo on 5/11/11.
//  Copyright 2011 KZLabs http://kzlabs.me
//  All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KZColorPickerWheel.h"

@class KZColorPickerWheelHue;
@class KZColorPickerBrightnessSlider;
@class KZColorPickerSaturationSlider;
@class KZColorPickerAlphaSlider;
@class KZColorPickerSwatchView;
@class KZColorPickerWheelBrightness;
@class KZColorPickerWheelSaturation;

@interface KZColorPicker : UIControl
{
	__weak IBOutlet KZColorPickerWheelHue *hueColorWheel;
    KZColorPickerSwatchView *currentColorIndicator;
	KZColorPickerWheelBrightness* brightnessWheel;
    KZColorPickerWheelSaturation* saturationWheel;
    NSMutableArray *swatches;
    
	UIColor *selectedColor;
    BOOL displaySwatches;
}

@property (nonatomic, retain) UIColor *selectedColor;
@property (nonatomic, retain) UIColor *oldColor;
- (void) setSelectedColor:(UIColor *)color animated:(BOOL)animated;
@end
