//
//  TPReviewUpgradePromptHelper.m
//  Tappainter
//
//  Created by Vadim Dagman on 4/8/14.
//  Copyright (c) 2014 MDi Touch. All rights reserved.
//

#import "TPReviewUpgradePromptHelper.h"
#import "UpgradeProductEngine.h"
#import "TPAppDefs.h"
#import "Flurry.h"

#define NEXT_NUMBER_OF_PAINTS_TO_PROMPT_TO_REVIEW_KEY @"NextNumberOfPaintsToPromptToReview"
#define NEXT_NUMBER_OF_PAINTS_TO_PROMPT_TO_UPGRADE_KEY @"NextNumberOfPaintsToPromptToUpgrade"
#define NEXT_NUMBER_OF_CREDITS_TO_PROMPT_TO_REVIEW_KEY @"NextNumberOfCreditsToPrompt"
#define CURRENT_NUMBER_OF_PAINTS_KEY @"CurrentNumberOfPaints"

#define PROMPT_TO_REVIEW_ALERT 1
#define PROMPT_TO_UPGRADE_ALERT 2

#ifdef TAPPAINTER_PRO
#define REVIEW_URL @"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=835306599&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"
const NSInteger kNumberOfPaintsBetweenPromptsToReview = 0;
const NSInteger kStartingNumberOfPaintsToPromptToReview = -1;
const NSInteger kNumberOfPaintsBetweenPromptsToUpgrade = 0;
const NSInteger kStartingNumberOfPaintsToPromptToUpgrade = -1;
#endif


#ifdef TAPPAINTER_STANDARD
#define REVIEW_URL @"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=835306599&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"
const NSInteger kNumberOfPaintsBetweenPromptsToReview = 30;
const NSInteger kStartingNumberOfPaintsToPromptToReview = 20;
const NSInteger kNumberOfPaintsBetweenPromptsToUpgrade = 0;
const NSInteger kStartingNumberOfPaintsToPromptToUpgrade = -1;
#endif

#ifdef TAPPAINTER_TRIAL
#define REVIEW_URL @"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=835306599&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"
const NSInteger kNumberOfPaintsBetweenPromptsToReview = 30;
const NSInteger kStartingNumberOfPaintsToPromptToReview = 20;
const NSInteger kNumberOfPaintsBetweenPromptsToUpgrade = 25;
const NSInteger kStartingNumberOfPaintsToPromptToUpgrade = 25;
#endif

static TPReviewUpgradePromptHelper* instance;

@implementation TPReviewUpgradePromptHelper {
    NSInteger nextNumberOfPaintsToPromptToReview_;
    NSInteger nextNumberOfPaintsToPromptToUpgrade_;
    NSInteger currentNumberOfPaints_;
}

- (id)init {
    self = [super init];
    if (self) {
        nextNumberOfPaintsToPromptToReview_ = [[NSUserDefaults standardUserDefaults] integerForKey:NEXT_NUMBER_OF_PAINTS_TO_PROMPT_TO_REVIEW_KEY];
        nextNumberOfPaintsToPromptToUpgrade_ = [[NSUserDefaults standardUserDefaults] integerForKey:NEXT_NUMBER_OF_PAINTS_TO_PROMPT_TO_UPGRADE_KEY];
        if (!nextNumberOfPaintsToPromptToReview_) nextNumberOfPaintsToPromptToReview_ = kStartingNumberOfPaintsToPromptToReview;
        if (!nextNumberOfPaintsToPromptToUpgrade_) nextNumberOfPaintsToPromptToUpgrade_ = kStartingNumberOfPaintsToPromptToUpgrade;
        
        currentNumberOfPaints_ = [[NSUserDefaults standardUserDefaults] integerForKey:CURRENT_NUMBER_OF_PAINTS_KEY];
    }
    return self;
}

#ifdef TAPPAINTER_PRO
- (bool)promptForReviewOrUpgrade {
    return NO;
}
#endif

#ifdef TAPPAINTER_STANDARD
- (bool)promptForReviewOrUpgrade {
    bool showPrompt = NO;
    
//    UIAlertView* alertToUpgrade = [[UIAlertView alloc] initWithTitle:@"Upgrade to TapPainter Pro?" message:@"Upgrade to TapPainter Pro and get all Color Fan Decks unlocked!" delegate:self cancelButtonTitle:@"Not Now" otherButtonTitles:@"Upgrade", nil];
//    alertToUpgrade.tag = PROMPT_TO_UPGRADE_ALERT;
//    
    UIAlertView* alertToReview = [[UIAlertView alloc] initWithTitle:@"Do You Like the App?" message:@"If you like TapPainter please take a moment to leave a review" delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Review", nil];
    alertToReview.tag = PROMPT_TO_REVIEW_ALERT;
    
    
    if ( nextNumberOfPaintsToPromptToReview_ >= 0) {
        currentNumberOfPaints_++;
        [[NSUserDefaults standardUserDefaults] setInteger:currentNumberOfPaints_ forKey:CURRENT_NUMBER_OF_PAINTS_KEY];
        if (!showPrompt) {
            if (currentNumberOfPaints_ >= nextNumberOfPaintsToPromptToReview_) {
                nextNumberOfPaintsToPromptToReview_ = currentNumberOfPaints_ + kNumberOfPaintsBetweenPromptsToReview;
                [[NSUserDefaults standardUserDefaults] setInteger:nextNumberOfPaintsToPromptToReview_ forKey:NEXT_NUMBER_OF_PAINTS_TO_PROMPT_TO_REVIEW_KEY];
                bool showPrompt = YES;
                [alertToReview show];
            }
        }
    }
    
    return showPrompt;
}
#endif

#ifdef TAPPAINTER_TRIAL
- (bool)promptForReviewOrUpgrade {
    bool showPrompt = NO;
    
    UIAlertView* alertToUpgrade = [[UIAlertView alloc] initWithTitle:@"Upgrade to TapPainter Standard?" message:@"Want more? Upgrade to TapPainter standard\n\n− No ads\n− select from recents\n− share images\n− and more" delegate:self cancelButtonTitle:@"Not Now" otherButtonTitles:@"Upgrade", nil];
    alertToUpgrade.tag = PROMPT_TO_UPGRADE_ALERT;
    
    UIAlertView* alertToReview = [[UIAlertView alloc] initWithTitle:@"Do You Like the App?" message:@"If you like TapPainter please take a moment to leave a review" delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Review", nil];
    alertToReview.tag = PROMPT_TO_REVIEW_ALERT;
    
    currentNumberOfPaints_++;
    [[NSUserDefaults standardUserDefaults] setInteger:currentNumberOfPaints_ forKey:CURRENT_NUMBER_OF_PAINTS_KEY];
    
    if (nextNumberOfPaintsToPromptToReview_ >= 0) {
        if (currentNumberOfPaints_ >= nextNumberOfPaintsToPromptToReview_) {
            nextNumberOfPaintsToPromptToReview_ = currentNumberOfPaints_ + kNumberOfPaintsBetweenPromptsToReview;
            [[NSUserDefaults standardUserDefaults] setInteger:nextNumberOfPaintsToPromptToReview_ forKey:NEXT_NUMBER_OF_PAINTS_TO_PROMPT_TO_REVIEW_KEY];
            showPrompt = YES;
            [alertToReview show];
        }
    }
    if (!showPrompt && nextNumberOfPaintsToPromptToUpgrade_ >= 0) {
        if (currentNumberOfPaints_ >= nextNumberOfPaintsToPromptToUpgrade_) {
            nextNumberOfPaintsToPromptToUpgrade_ = currentNumberOfPaints_ + kNumberOfPaintsBetweenPromptsToUpgrade;
            [[NSUserDefaults standardUserDefaults] setInteger:kNumberOfPaintsBetweenPromptsToUpgrade forKey:NEXT_NUMBER_OF_PAINTS_TO_PROMPT_TO_UPGRADE_KEY];
            showPrompt = YES;
            [alertToUpgrade show];
        }
    }
    return showPrompt;
}
#endif


+ (TPReviewUpgradePromptHelper*)instance {
    if (!instance) {
        instance = [[TPReviewUpgradePromptHelper alloc] init];
    }
    
    return instance;
}


+ (bool)promptForReviewOrUpgrade {
    return [[TPReviewUpgradePromptHelper instance] promptForReviewOrUpgrade];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == PROMPT_TO_REVIEW_ALERT) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            [Flurry logEvent:@"Review Selected"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:REVIEW_URL]];
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:-1] forKey:NEXT_NUMBER_OF_PAINTS_TO_PROMPT_TO_REVIEW_KEY]; //Don't prompt for review again
        }
    } else if (alertView.tag == PROMPT_TO_UPGRADE_ALERT) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            [Flurry logEvent:@"Upgrade Tapped" withParameters:@{@"Prompt":@"Upgrade"}];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:TAPPAINTER_STANDARD_URL]];
        }
    }
}



@end
