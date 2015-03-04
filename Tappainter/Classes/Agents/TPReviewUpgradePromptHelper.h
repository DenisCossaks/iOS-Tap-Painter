//
//  TPReviewUpgradePromptHelper.h
//  Tappainter
//
//  Created by Vadim Dagman on 4/8/14.
//  Copyright (c) 2014 MDi Touch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TPReviewUpgradePromptHelper : NSObject<UIAlertViewDelegate>

+ (bool)promptForReviewOrUpgrade;

@end
