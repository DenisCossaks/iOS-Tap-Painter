//
//  KZColorPickerWheelSaturation.m
//  Tappainter
//
//  Created by Vadim on 10/6/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import "KZColorPickerWheelSaturation.h"
#import "HSV.h"
#import "UIColor-Expanded.h"
#import <QuartzCore/QuartzCore.h>
#import "UtilityCategories.h"

@interface KZColorPickerWheelSaturation() 
@end

@implementation KZColorPickerWheelSaturation

- (id)initWithFrame:(CGRect)frame andThickness:(int)thickness
{
    self = [super initWithFrame:frame andThickness:thickness];
    if (self) {
        self.value = 1;
    }
    return self;
}

- (UIColor*)startColorForKeyColor:(UIColor*)keyColor {
    RGBType rgb = [keyColor rgbType];
    HSVType hsv = RGB_to_HSV(rgb);
    return [UIColor colorWithHue:hsv.h saturation:0 brightness:hsv.v alpha:1];
}

- (UIColor*)endColorForKeyColor:(UIColor*)keyColor {
    RGBType rgb = [keyColor rgbType];
    HSVType hsv = RGB_to_HSV(rgb);
    return [UIColor colorWithHue:hsv.h saturation:1 brightness:hsv.v alpha:1];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
