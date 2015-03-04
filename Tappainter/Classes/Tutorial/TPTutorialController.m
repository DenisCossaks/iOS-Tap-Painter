//
//  TPTutorialController.m
//  Tappainter
//
//  Created by Vadim Dagman on 2/25/14.
//  Copyright (c) 2014 MDi Touch. All rights reserved.
//

#import "TPTutorialController.h"
#import "TPPin.h"
#import "UtilityCategories.h"

@implementation TPTutorialController {
    
    __weak IBOutlet UIView *markerTutorialView_;
    __weak IBOutlet UIView *selectColorTutorialView_;
    __weak IBOutlet UIView *colorPickerTutorialView_;
    __weak IBOutlet UIView *convertColorTutorialView_;
    __weak IBOutlet UIView *swatchTutorialView_;
    __weak IBOutlet UIView *tapToPaintTutorialView_;
    __weak IBOutlet UIView *customModeTutorialView_;
    __weak IBOutlet UIView *recentImagesTutorialView_;
    __weak IBOutlet UIView *recentColorsTutorialView_;
    __weak IBOutlet UIView *revertTutorialView_;
    __weak IBOutlet UIView *flickTutorialView_;
    __weak IBOutlet UIView *cornersTutorial_;
    __weak IBOutlet UIView *removeCornersTutorial_;
    __weak IBOutlet UIView *shareTutorialView_;
    __weak IBOutlet UIView *revealTutorialView_;
    __weak IBOutlet UILabel *markerTutorialTip_;
    IBOutletCollection(UILabel) NSArray *textLabels_;
    UIView* activeTutorialView_;
    UIView* nextTutorialToShow_;
    UIView* testTutorialView_;
    __weak IBOutlet UILabel *shareTutorialTextLabel_;
}

- (void)viewDidLoad {
    for (UILabel* label in textLabels_) {
        NSLog(@"Label text: %@ size %f", label.text, label.font.pointSize);
        UIFont* font = [UIFont fontWithName:@"MuseoSans-700" size:label.font.pointSize];
        label.font = font;
        label.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1];
    }
    
//    testTutorialView_ = revertTutorialView_;
#ifdef TAPPAINTER_TRIAL
    [[NSUserDefaults standardUserDefaults] setObject:@"Shown" forKey:@"CustomModeTutorialShown"];
    [[NSUserDefaults standardUserDefaults] setObject:@"Shown" forKey:@"RecentImagesTutorialShown"];
    [[NSUserDefaults standardUserDefaults] setObject:@"Shown" forKey:@"RecentColorsTutorialShown"];
    [[NSUserDefaults standardUserDefaults] setObject:@"Shown" forKey:@"CornersTutorialShown"];
    [[NSUserDefaults standardUserDefaults] setObject:@"Shown" forKey:@"RemoveCornersTutorialShown"];
    [[NSUserDefaults standardUserDefaults] setObject:@"Shown" forKey:@"RevertFlickTutorialShown"];
    [shareTutorialView_ shiftVerticallyBy:-74];
    shareTutorialTextLabel_.text = @"Share an image through email or on Facebook.";
#endif
}

- (void)showTutorialForColorMarkerWithMarker:(TPPin *)marker {

    if ([self showTestTutorial]) return;
    
    if (![self tutorialShownForKey:@"MarkerTutorialShown"]) {
        // Tutorial image is placed to the right of the marker and it's guaranteed that there is enough space
        CGPoint origin;
        origin.x = marker.view.frame.origin.x + marker.view.frame.size.width;
        origin.y = marker.view.center.y - markerTutorialTip_.frame.origin.y;
        origin = [markerTutorialView_.superview convertPoint:origin fromView:marker.view.superview];
        CGRect frame = markerTutorialView_.frame;
        frame.origin = origin;
        markerTutorialView_.frame = frame;
        [self showTutorialView:markerTutorialView_];
        [[NSUserDefaults standardUserDefaults] setObject:@"Shown" forKey:@"MarkerTutorialShown"];
    }
    
}

- (void)showSelectColorTutorial {
    if ([self showTestTutorial]) return;
    if (![self tutorialShownForKey:@"SelectColortutorialShown"]) {
        [self showTutorialView:selectColorTutorialView_];
        [[NSUserDefaults standardUserDefaults] setObject:@"Shown" forKey:@"SelectColortutorialShown"];
    }
}

- (void)showColorPickerTutorial {
    if ([self showTestTutorial]) return;
    if (![self tutorialShownForKey:@"ColorPickerTutorialShown"]) {
        [self showTutorialView:colorPickerTutorialView_];
        nextTutorialToShow_ = convertColorTutorialView_;
        [[NSUserDefaults standardUserDefaults] setObject:@"Shown" forKey:@"ColorPickerTutorialShown"];
    }
}

- (void)showSwatchTutorial {
    if ([self showTestTutorial]) return;
    if (![self tutorialShownForKey:@"SwatchTutorialShown"]) {
        [self showTutorialView:swatchTutorialView_];
        [[NSUserDefaults standardUserDefaults] setObject:@"Shown" forKey:@"SwatchTutorialShown"];
    }
}

- (void)showPaintRollerTutorialForButton:(UIButton *)button {
    if ([self showTestTutorial]) return;
    if (![self tutorialShownForKey:@"PaintRollerTutorialShown"]) {
        CGPoint buttonCenter = button.center;
        buttonCenter = [tapToPaintTutorialView_.superview convertPoint:buttonCenter fromView:button.superview];
        CGRect frame = tapToPaintTutorialView_.frame;
        frame.origin.y = buttonCenter.y - markerTutorialTip_.frame.origin.y;
        tapToPaintTutorialView_.frame = frame;
        [self showTutorialView:tapToPaintTutorialView_];
        [[NSUserDefaults standardUserDefaults] setObject:@"Shown" forKey:@"PaintRollerTutorialShown"];
    }
}

- (bool)showTutorialOnPaintFinished {
    if ([self showTestTutorial]) return YES;
    if (![self tutorialShownForKey:@"CustomModeTutorialShown"]) {
        [self showTutorialView:customModeTutorialView_];
        [[NSUserDefaults standardUserDefaults] setObject:@"Shown" forKey:@"CustomModeTutorialShown"];
        return YES;
    } else if (![self tutorialShownForKey:@"RecentImagesTutorialShown"]) {
        [self showTutorialView:recentImagesTutorialView_];
        [[NSUserDefaults standardUserDefaults] setObject:@"Shown" forKey:@"RecentImagesTutorialShown"];
        return YES;
    } else if (![self tutorialShownForKey:@"RecentColorsTutorialShown"]) {
        [self showTutorialView:recentColorsTutorialView_];
        [[NSUserDefaults standardUserDefaults] setObject:@"Shown" forKey:@"RecentColorsTutorialShown"];
        return YES;
    } else if (![self tutorialShownForKey:@"RevertFlickTutorialShown"]) {
        [self showTutorialView:revertTutorialView_];
        nextTutorialToShow_ = flickTutorialView_;
        [[NSUserDefaults standardUserDefaults] setObject:@"Shown" forKey:@"RevertFlickTutorialShown"];
        return YES;
    }
#ifdef TAPPAINTER_TRIAL
    else if (![self tutorialShownForKey:@"ShareTutorialShown"]) {
        [self showTutorialView:shareTutorialView_];
        [[NSUserDefaults standardUserDefaults] setObject:@"Shown" forKey:@"ShareTutorialShown"];
        return YES;
    }
#endif
    return NO;
}

- (void)showCornersTutorial {
    if ([self showTestTutorial]) return;
    if (![self tutorialShownForKey:@"CornersTutorialShown"]) {
        [self showTutorialView:cornersTutorial_];
        [[NSUserDefaults standardUserDefaults] setObject:@"Shown" forKey:@"CornersTutorialShown"];
    }
}

- (void)showRemoveCornersTutorial {
    if ([self showTestTutorial]) return;
    if (![self tutorialShownForKey:@"RemoveCornersTutorialShown"]) {
        [self showTutorialView:removeCornersTutorial_];
        [[NSUserDefaults standardUserDefaults] setObject:@"Shown" forKey:@"RemoveCornersTutorialShown"];
    }
}

- (void)showShareTutorial {
    if ([self showTestTutorial]) return;
    if (![self tutorialShownForKey:@"ShareTutorialShown"]) {
        [self showTutorialView:shareTutorialView_];
        [[NSUserDefaults standardUserDefaults] setObject:@"Shown" forKey:@"ShareTutorialShown"];
    }
}

- (void)showRevealTutorial {
    if ([self showTestTutorial]) return;
    if (![self tutorialShownForKey:@"RevealTutorialShown"]) {
        [self showTutorialView:revealTutorialView_];
        [[NSUserDefaults standardUserDefaults] setObject:@"Shown" forKey:@"RevealTutorialShown"];
    }
}

- (bool)tutorialShownForKey:(NSString*)key {
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

- (bool)showTestTutorial {
#ifdef TAPPAINTER_TRIAL
    return YES;
#endif
    if (testTutorialView_) {
        CGRect frame = testTutorialView_.frame;
        frame.origin = CGPointMake(200, 600);
        [self showTutorialView:testTutorialView_];
        return YES;
    }
    return NO;
}

- (void)showTutorialView:(UIView*)view {
    activeTutorialView_ = view;
    activeTutorialView_.alpha = 0;
    activeTutorialView_.hidden = NO;
    _containerView_.hidden = NO;
    [UIView animateWithDuration:1 animations:^{
        activeTutorialView_.alpha = 1;
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    bool hidecontainerView = nextTutorialToShow_ == nil;
    [UIView animateWithDuration:1 animations:^{
        activeTutorialView_.alpha = 0;
    } completion:^(BOOL finished) {
        _containerView_.hidden = hidecontainerView;
    }];
    if (nextTutorialToShow_) {
        [self showTutorialView:nextTutorialToShow_];
        nextTutorialToShow_ = nil;
    }
}

@end
