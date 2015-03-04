//
//  TPImageView.h
//  Tappainter
//
//  Created by Vadim on 2/15/14.
//  Copyright (c) 2014 MDi Touch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPImageView : UIImageView

@property CGRect contentFrame;
- (UIColor*) getPixelColorAtLocation:(CGPoint)point;
@end
