//
//  TPAnimatedLogo.m
//  Tappainter
//
//  Created by Vadim on 10/12/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import "TPAnimatedLogo.h"

#define TIMER_INTERVAL 0.1
#define ANGLE_INCREMENT M_PI/2

@interface TPAnimatedLogo() {
    NSTimer* timer_;
    double currentAngle_;
}

@end

@implementation TPAnimatedLogo

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.image = [UIImage imageNamed:@"throbber-tp-state-A"];
        self.animationImages = [NSArray arrayWithObjects:
                                [UIImage imageNamed:@"throbber-tp-state-A"],
                                [UIImage imageNamed:@"throbber-tp-state-B"],
                                [UIImage imageNamed:@"throbber-tp-state-C"],
                                [UIImage imageNamed:@"throbber-tp-state-D"],
                                nil];
        self.animationDuration = 0.3;
        self.animationRepeatCount = 0;
    }
    return self;
}



@end
