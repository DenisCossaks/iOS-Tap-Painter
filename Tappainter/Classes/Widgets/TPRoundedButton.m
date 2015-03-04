//
//  TPRoundedButton.m
//  Tappainter
//
//  Created by Vadim on 11/4/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import "TPRoundedButton.h"

@implementation TPRoundedButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self configure];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self configure];
    }
    return self;
}

- (void)configure {
    self.layer.cornerRadius = 5;
}

@end
