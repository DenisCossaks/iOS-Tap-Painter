//
//  TPTutorialController.h
//  Tappainter
//
//  Created by Vadim Dagman on 2/25/14.
//  Copyright (c) 2014 MDi Touch. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TPPin;
@interface TPTutorialController : UIViewController

@property __weak UIView* containerView_;

- (void)showTutorialForColorMarkerWithMarker:(TPPin*)marker;
- (void)showSelectColorTutorial;
- (void)showColorPickerTutorial;
- (void)showSwatchTutorial;
- (void)showPaintRollerTutorialForButton:(UIButton*)button;
- (bool)showTutorialOnPaintFinished;
- (void)showCornersTutorial;
- (void)showRemoveCornersTutorial;
- (void)showShareTutorial;
- (void)showRevealTutorial;
@end
