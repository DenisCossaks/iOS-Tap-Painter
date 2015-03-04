//
//  TPMagnifyingGlass.h
//  Tappainter
//
//  Created by Vadim on 2/1/14.
//  Copyright (c) 2014 MDi Touch. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TPImageView;
@interface TPMagnifyingGlass : UIViewController

@property TPImageView* viewWithImage;

- (void)grabFromPosition:(CGPoint)position;

@end
