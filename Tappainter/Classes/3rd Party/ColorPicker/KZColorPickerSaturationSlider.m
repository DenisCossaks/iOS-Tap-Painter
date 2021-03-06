//
//  KZColorPickerSaturationSlider.m
//
//  Created by Alex Restrepo on 5/11/11.
//  Modified by Vadim Dagman on 9/29/2013
//  Copyright 2011 KZLabs http://kzlabs.me
//  All rights reserved.
//

#import "KZColorPickerSaturationSlider.h"
#import "HSV.h"
#import "UIColor-Expanded.h"

@implementation KZColorPickerSaturationSlider

- (id)initWithFrame:(CGRect)frame 
{
    if ((self = [super initWithFrame:frame])) 
	{		
        // Initialization code
        gradientLayer = [[CAGradientLayer alloc] init];
        gradientLayer.bounds = CGRectMake(horizontal ? 18 : 6,
                                          horizontal ? 6 : 18,
                                          frame.size.width - (horizontal ? 36 : 12),
                                          frame.size.height - (horizontal ? 12 : 36));
        
        gradientLayer.position = CGPointMake(frame.size.width * 0.5, frame.size.height * 0.5);
        gradientLayer.startPoint = CGPointMake(0.0, 0.5);
        gradientLayer.endPoint = CGPointMake(1.0, 0.5);
		gradientLayer.cornerRadius = 6.0;
		gradientLayer.borderWidth = 2.0;
		gradientLayer.borderColor = [[UIColor grayColor] CGColor];
                
		if ([self respondsToSelector:@selector(contentScaleFactor)])
			self.contentScaleFactor = [[UIScreen mainScreen] scale];
        
        [self.layer insertSublayer:gradientLayer atIndex:0];
		[self setKeyColor:[UIColor whiteColor]];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void) setKeyColor:(UIColor *)c
{	
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue
					 forKey:kCATransactionDisableActions];
	RGBType rgb = [c rgbType];
	HSVType hsv = RGB_to_HSV(rgb);
    UIColor* leftColor =  [UIColor colorWithHue:hsv.h
                                     saturation:1.0
                                     brightness:hsv.v
                                          alpha:1.0];
    UIColor* rightColor =  [UIColor colorWithHue:hsv.h
                                     saturation:0.1
                                     brightness:hsv.v
                                          alpha:1.0];

	gradientLayer.colors =  [NSArray arrayWithObjects:
							 (id)leftColor.CGColor,
							 (id)rightColor.CGColor,
							 nil];
	[CATransaction commit];
}

- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    gradientLayer.bounds = CGRectMake(horizontal ? 18 : 6,
                                      horizontal ? 6 : 18,
                                      frame.size.width - (horizontal ? 36 : 12),
                                      frame.size.height - (horizontal ? 12 : 36));
    
    gradientLayer.position = CGPointMake(frame.size.width * 0.5, frame.size.height * 0.5);
    self.value = self.value;
}
@end
