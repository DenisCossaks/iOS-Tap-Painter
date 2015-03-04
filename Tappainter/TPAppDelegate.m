//
//  TPAppDelegate.m
//  Tappainter
//
//  Created by Vadim on 9/15/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import "TPAppDelegate.h"
#import "UpgradeProductEngine.h"
#import "TestFlight.h"
#import "Flurry.h"
#import <AdSupport/ASIdentifierManager.h>

@implementation TPAppDelegate
@synthesize session = _session;

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    // attempt to extract a token from the url
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:self.session];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
//    [TestFlight takeOff:@"14a3549f-3c33-4e46-a3f3-44c3f12d7741"];
//    [TestFlight setOptions:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:TFOptionReinstallCrashHandlers]];
    //note: iOS only allows one crash reporting tool per app; if using another, set to: NO
    [Flurry setCrashReportingEnabled:YES];
    [Flurry startSession:@"Y69Z2QRVQ3BRHW2J8CTZ"];
#ifdef TAPPAINTER_TRIAL
    NSLog(@"AD ID: %@", [ASIdentifierManager sharedManager].advertisingIdentifier);
    
    Kiip *kiip = [[Kiip alloc] initWithAppKey:@"5f03d83696826f483d4810b3f5916db8" andSecret:@"dc03c92b2797ae509819cf91eec18e82"];
    [Kiip setSharedInstance:kiip];
#endif
    //your code
    [application setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    [UpgradeProductEngine upgradeEngineSingleton]; // Let it download products information in its init
    [FBProfilePictureView class];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBAppCall handleDidBecomeActiveWithSession:self.session];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.session close];
}

- (float)version {
    return [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] floatValue];
}

@end
