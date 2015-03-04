//
//  TPAppDelegate.h
//  Tappainter
//
//  Created by Vadim on 9/15/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import <UIKit/UIKit.h>
#import <KiipSDK/KiipSDK.h>

@interface TPAppDelegate : UIResponder <UIApplicationDelegate, KiipDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) FBSession *session;
@property (nonatomic) float version;

@end
