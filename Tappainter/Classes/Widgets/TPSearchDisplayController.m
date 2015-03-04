//
//  TPSearchDisplayController.m
//  Tappainter
//
//  Created by Vadim on 2/4/14.
//  Copyright (c) 2014 MDi Touch. All rights reserved.
//

#import "TPSearchDisplayController.h"

@implementation TPSearchDisplayController {
    bool hasMoved_;
    CGRect containerViewFrame_;
}


- (void)setActive:(BOOL)visible animated:(BOOL)animated {
    [super setActive:visible animated:animated];
    self.searchBar.showsCancelButton = NO;
    
    //move the dimming part down
    for (UIView *subview in self.searchContentsController.view.subviews) {
        //NSLog(@"%@", NSStringFromClass([subview class]));
        if ([subview isKindOfClass:NSClassFromString(@"UISearchDisplayControllerContainerView")])
        {
            if (!hasMoved_) {
                containerViewFrame_ = subview.frame;
                containerViewFrame_.origin.y += 12;
                hasMoved_ = YES;
            }
            subview.frame = containerViewFrame_;
        }
    }
}

@end
