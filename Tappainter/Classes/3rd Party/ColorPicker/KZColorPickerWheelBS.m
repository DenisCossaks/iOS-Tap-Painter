//
//  KZColorPickerWheelBS.m
//  Tappainter
//
//  Created by Vadim on 10/9/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import "KZColorPickerWheelBS.h"

@implementation KZColorPickerWheelBS

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (float)angleFromValue:(float)value {
    return [super angleFromValue:value]/2;
}

- (float)valueFromAngle:(float)angle {
    float value = [super valueFromAngle:angle];
    if (value <= 0.5)
        return value*2;
    else
        return (1-value)*2;
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
