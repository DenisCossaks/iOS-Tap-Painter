//
//  KZColorWheelView.m
//
//  Created by Alex Restrepo on 5/11/11.
//  Copyright 2011 KZLabs http://kzlabs.me
//  All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "KZColorPicker.h"
#import "KZColorPickerWheelHue.h"
#import "HSV.h"
#import "UIColor-Expanded.h"
#import "Defs.h"
#import "KZColorPickerWheelBrightness.h"
#import "KZColorPickerWheelSaturation.h"

@interface KZColorPicker()
@property (nonatomic, retain) KZColorPickerBrightnessSlider *brightnessSlider;
@property (nonatomic, retain) KZColorPickerSaturationSlider *saturationSlider;
@property (nonatomic, retain) KZColorPickerAlphaSlider *alphaSlider;
@property (nonatomic, retain) UIView *currentColorView;
@property (nonatomic, retain) NSMutableArray *swatches;
//- (void) fixLocations;
@end


@implementation KZColorPicker
@synthesize brightnessSlider;
@synthesize saturationSlider;
@synthesize selectedColor;
@synthesize alphaSlider;
@synthesize swatches;
@synthesize oldColor = _oldColor;
@synthesize currentColorView = _currentColorView;

#define WHEEL_THICKNESS 45

- (void) setup
{
	[hueColorWheel addTarget:self action:@selector(colorWheelValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    saturationWheel = [[KZColorPickerWheelSaturation alloc] initWithFrame:CGRectMake(0, 0, hueColorWheel.bounds.size.width-WHEEL_THICKNESS*2, hueColorWheel.bounds.size.width-WHEEL_THICKNESS*2) andThickness:WHEEL_THICKNESS];
    saturationWheel.center = hueColorWheel.center;
    [self addSubview:saturationWheel];
	[saturationWheel addTarget:self action:@selector(colorWheelValueChanged:) forControlEvents:UIControlEventValueChanged];
    brightnessWheel = [[KZColorPickerWheelBrightness alloc] initWithFrame:CGRectMake(0, 0, saturationWheel.bounds.size.width-WHEEL_THICKNESS*2, saturationWheel.bounds.size.width-WHEEL_THICKNESS*2) andThickness:WHEEL_THICKNESS];
    [self addSubview:brightnessWheel];
    brightnessWheel.center = hueColorWheel.center;
	[brightnessWheel addTarget:self action:@selector(colorWheelValueChanged:) forControlEvents:UIControlEventValueChanged];
	
    // current color indicator hier.
    UIView *colorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, brightnessWheel.bounds.size.width-WHEEL_THICKNESS*2, brightnessWheel.bounds.size.width-WHEEL_THICKNESS*2)];
    colorView.layer.cornerRadius = colorView.bounds.size.width/2;
    colorView.clipsToBounds = YES;
    colorView.center = hueColorWheel.center;
    colorView.backgroundColor = [UIColor clearColor];
    colorView.layer.borderWidth = 2;
    colorView.layer.borderColor = [UIColor grayColor].CGColor;
    self.currentColorView = colorView;    
    [self addSubview:colorView];
    self.selectedColor = [UIColor whiteColor];
    [brightnessWheel setKeyColor:self.selectedColor];
    [saturationWheel setKeyColor:self.selectedColor];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) 
	{
        // Initialization code
		[self setup];
    }
    return self;
}

- (void) awakeFromNib
{
	[self setup];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setup];
}

- (void) setSelectedColor:(UIColor *)color animated:(BOOL)animated
{
	if (animated) 
	{
		[UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:1.0];
		self.selectedColor = color;
		[UIView commitAnimations];
	}
	else 
	{
		self.selectedColor = color;
	}
}

- (void) setSelectedColor:(UIColor *)c
{
    [self setSelectedColorInternal:c];
    HSVType hsv = [c hsvType];
    hueColorWheel.value = hsv.h;
    brightnessWheel.value = hsv.v;
    saturationWheel.value = hsv.s;
    [brightnessWheel setKeyColor:c];
    [saturationWheel setKeyColor:c];
}

- (void)colorWheelValueChanged:(KZColorPickerWheel*)colorPickerWheel {
	UIColor* color = [UIColor colorWithHue:hueColorWheel.value
                               saturation:saturationWheel.value
                               brightness:brightnessWheel.value
                                    alpha:1];
//    NSLog(@"Brightness value: %f", brightnessWheel.value);
    [self setSelectedColorInternal:color];
    if (colorPickerWheel == hueColorWheel) {
        [brightnessWheel setKeyColor:color];
        [saturationWheel setKeyColor:color];
    } else if (colorPickerWheel == brightnessWheel) {
        [saturationWheel setKeyColor:color];
    } else if (colorPickerWheel == saturationWheel) {
        [brightnessWheel setKeyColor:color];
    }
//    NSLog(@"New color: %@", color);
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)setSelectedColorInternal:(UIColor*)color {
    selectedColor = color;
    self.currentColorView.backgroundColor = selectedColor;
}

@end
