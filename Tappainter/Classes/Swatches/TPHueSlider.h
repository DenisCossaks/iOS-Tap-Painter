//
//  TPHueSlider.h
//  Tappainter
//
//  Created by Vadim on 11/5/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import "TPSlider.h"

@class TPBrandData;
@interface TPHueSlider : TPSlider

- (void)setGradientFromBrandData:(TPBrandData*)brandData;

@end
