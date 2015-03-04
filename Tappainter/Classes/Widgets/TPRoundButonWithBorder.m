//
//  TPRoundButonWithBorder.m
//  Tappainter
//
//  Created by Vadim on 12/6/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import "TPRoundButonWithBorder.h"

@implementation TPRoundButonWithBorder

- (void)configure {
    self.layer.cornerRadius = self.frame.size.width/2;
    self.layer.borderColor = self.tintColor.CGColor;
    self.layer.borderWidth = 1;
}

@end
