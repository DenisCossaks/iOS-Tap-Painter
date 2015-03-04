//
//  TPRoundedButtonWithBorder.m
//  Tappainter
//
//  Created by Vadim on 11/14/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import "TPRoundedButtonWithBorder.h"

@implementation TPRoundedButtonWithBorder

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)configure {
    [super configure];
    self.layer.borderColor = self.tintColor.CGColor;
    self.layer.borderWidth = 1;
}

@end
