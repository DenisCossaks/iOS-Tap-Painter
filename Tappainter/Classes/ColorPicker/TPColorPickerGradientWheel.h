//
//  TPColorPickerGradientWheel.h
//  Tappainter
//
//  Created by Vadim on 10/11/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import "KZColorPickerWheel.h"

@interface TPColorPickerGradientWheel : KZColorPickerWheel

@property (nonatomic) UIColor* keyColor;
@property int thickness;

- (id)initWithFrame:(CGRect)frame andThickness:(int)thickness;
- (void)setKeyColor:(UIColor *)c;
// These need to be overridden by the derived class
- (UIColor*)startColorForKeyColor:(UIColor*)keyColor;
- (UIColor*)endColorForKeyColor:(UIColor*)keyColor;

@end
