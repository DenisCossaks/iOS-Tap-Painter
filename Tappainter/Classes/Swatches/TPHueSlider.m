//
//  TPHueSlider.m
//  Tappainter
//
//  Created by Vadim on 11/5/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import "TPHueSlider.h"
#import "TPBrandData.h"

@interface TPHueSlider() {
}

@end

@implementation TPHueSlider

+ (Class)layerClass
{
    return [CAGradientLayer class];
}

- (CAGradientLayer *)gradientLayer
{
    return (CAGradientLayer *)self.layer;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#define MAX_NUMBER_OF_GRADIENT_STOPS 100
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
         UIImage* transparentImage = [UIImage imageNamed:@"TransparentImage"];
        [self setMinimumTrackImage:transparentImage forState:UIControlStateNormal];
        [self setMaximumTrackImage:transparentImage forState:UIControlStateNormal];
        UIImage* thumbImage = [UIImage imageNamed:@"HueSliderThumb"];
        [self setThumbImage:thumbImage forState:UIControlStateNormal];
    }
    
    return self;
}

- (void)setGradientFromBrandData:(TPBrandData*)brandData {
    NSMutableArray* colors = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray* locations = [NSMutableArray arrayWithCapacity:0];
    float step = 1;
    if (brandData.pages.count > MAX_NUMBER_OF_GRADIENT_STOPS) {
        step = (float)brandData.pages.count/(float)MAX_NUMBER_OF_GRADIENT_STOPS;
    }
    float floatI = 0.0;
    for (int i = 0; i < brandData.pages.count; ) {
        TPPageData* pageData = brandData.pages[i];
        UIColor* color = [pageData averageColor];
        [colors addObject:(id)color.CGColor];
        [locations addObject:[NSNumber numberWithFloat:(float)1/brandData.pages.count*i]];
        floatI += step;
        i = roundf(floatI);
    }
    [self gradientLayer].startPoint = CGPointMake(0, 0.5);
    [self gradientLayer].endPoint = CGPointMake(1, 0.5);
//    [self gradientLayer].locations = locations;
    [self gradientLayer].colors = colors;
}

@end
