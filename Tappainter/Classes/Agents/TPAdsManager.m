//
//  TPAdsManager.m
//  Tappainter
//
//  Created by Vadim on 5/22/14.
//  Copyright (c) 2014 MDi Touch. All rights reserved.
//

#import "TPAdsManager.h"
#ifdef TAPPAINTER_TRIAL
#import <KiipSDK/KiipSDK.h>
#endif

static TPAdsManager* instance;

@implementation TPAdsManager {
    int numberOfPaints_;
}

- (void)showAdOnPaint {
#ifdef TAPPAINTER_TRIAL
    numberOfPaints_++;
    if (numberOfPaints_%2) {
        [[Kiip sharedInstance] saveMoment:@"Painting a Wall" withCompletionHandler:^(KPPoptart *poptart, NSError *error) {
            [poptart show];
        }];
    }
#endif
}

+ (TPAdsManager*)sharedInstance {
#ifdef TAPPAINTER_TRIAL
    if (!instance) {
        instance = [[TPAdsManager alloc] init];
    }
#endif
    return instance;
}

+ (void)showAdOnPaint {
    [[self sharedInstance] showAdOnPaint];
}

+ (void)showAdOnCreditUsed {
#ifdef TAPPAINTER_TRIAL
    [[Kiip sharedInstance] saveMoment:@"Selecting a Fan Deck" withCompletionHandler:^(KPPoptart *poptart, NSError *error) {
        [poptart show];
    }];
#endif
}

@end
