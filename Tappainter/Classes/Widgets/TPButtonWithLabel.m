//
//  TPButtonWithLabel.m
//  Tappainter
//
//  Created by Vadim on 12/3/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import "TPButtonWithLabel.h"

@interface TPButtonWithLabel() {
    __weak IBOutlet UILabel* label_;
}

@end

@implementation TPButtonWithLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [label_ setHighlighted:selected];
}

@end
