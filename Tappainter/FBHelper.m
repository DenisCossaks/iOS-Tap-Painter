//
//  FBHelper.m
//  RubyOnIce
//
//  Created by Vadim on 5/8/13.
//  Copyright (c) 2013 DigitalPrunes. All rights reserved.
//

#import "FBHelper.h"
#import "TPAppDelegate.h"
#import "UtilityCategories.h"
#import "TPAppDefs.h"
#import "Flurry.h"
#import "TPImageWithSwatchViewController.h"

static FBHelper* sharedInstance;

#define WAS_LOGGED_IN_KEY @"WasLoggedIn"

@interface FBHelper() {
}

@property bool wasLoggedIn;
@property (nonatomic) bool isLoggedIn;

@end

@implementation FBHelper


+ (void) loginWithCompletionBlock:(void (^)(bool))block {
    TPAppDelegate *appDelegate = (TPAppDelegate*)[[UIApplication sharedApplication]delegate];
    if (!FBSession.activeSession.isOpen) {
        if (appDelegate.session == nil || appDelegate.session.state != FBSessionStateCreated) {
            // create a fresh session object
            NSArray *persmissions = [[NSArray alloc] initWithObjects:
                                     @"email",
//                                     @"publish_actions",
                                     @"user_likes",
                                     @"user_birthday",
                                     nil];
            appDelegate.session = [[FBSession alloc] initWithPermissions:persmissions];
            [FBSession setActiveSession:appDelegate.session];
        }
    
        
        [appDelegate.session openWithCompletionHandler:^(FBSession *session,
                                                         FBSessionState status,
                                                         NSError *error) {
            if (status == FBSessionStateOpen) {
                [Flurry logEvent:@"Facebook Login"];
                NSLog(@"Succesfully logged in to Facebook");
                [FBSession setActiveSession:appDelegate.session];
                [[FBRequest requestForMe] startWithCompletionHandler:
                 ^(FBRequestConnection *connection,
                   NSDictionary<FBGraphUser> *user,
                   NSError *error) {
                     if (!error) {
                         [[NSNotificationCenter defaultCenter] postNotificationName:LOGGED_IN_TO_FACEBOOK object:user.id];
                     }
                 }];
                if ( block )
                    block(TRUE);
            } else if (status == FBSessionStateClosedLoginFailed ) {
                NSString* failureReason = [[error userInfo] objectForKey:@"com.facebook.sdk:ErrorLoginFailedReason"];
                if ( [failureReason isEqual:@"com.facebook.sdk:UserLoginCancelled"] ) {
                } else {
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Couldn't Log In to Facebook" message:failureReason delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                }
                [FBSession.activeSession closeAndClearTokenInformation];
                if ( block )
                    block(FALSE);
            } else {
                BLOCK(FALSE);
            }
        }];
    } else {
        if ( block )
            block(TRUE);
    }
}

+ (void) loginSilentlyWithCompletionBlock:(void (^)(bool))block {
    TPAppDelegate *appDelegate = (TPAppDelegate*)[[UIApplication sharedApplication]delegate];
    if (!appDelegate.session) {
        NSArray *persmissions = [[NSArray alloc] initWithObjects:
                                 @"email",
                                 @"user_likes",
                                 @"user_birthday",
                                 nil];
        appDelegate.session = [[FBSession alloc] initWithPermissions:persmissions];
    }
    if ( appDelegate.session.state == FBSessionStateCreatedTokenLoaded ) {
        [self loginWithCompletionBlock:block];
    } else {
        block(false);
    }
}

+ (bool)isLoggedIn {
    return FBSession.activeSession.isOpen;
}

+ (void)postToWallWithImageAsset:(TPImageAsset *)asset {
    if ([self checkInternetConnectionWithErrorAlert:YES]) {
        TPImageWithSwatchViewController* imageWithSwatchController = [[TPImageWithSwatchViewController alloc] init];
        imageWithSwatchController.imageAsset = asset;
        
        // Generate an image offscreen that contains asset image and the swatch stacked under it
        UIGraphicsBeginImageContext(imageWithSwatchController.view.frame.size);
        //            UIGraphicsBeginImageContext(CGSizeMake(480, 480));
        [[imageWithSwatchController.view layer] renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        // Upload image now to be able to share it
        UIAlertView* alert = [self displayProgressAlertWithMessage:@"Uploading image for sharing..."];
        TPWallPaintService* paintSrvice = [[TPWallPaintService alloc] init];
        [paintSrvice uploadImage:screenshot originalID:0 success:^(NSString *uploadName, NSInteger uploadID, NSString *URL) {
            [self dismissProgressAlert:alert];
            [FBHelper postToWallWithImageURL:URL andCompletionBlock:^(bool Success) {
                if (Success) {
                    [Flurry logEvent:@"Image Shared" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"Facebook", @"via", nil]];
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Your Message Has Been Posted" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                }
            }];
        } failure:^(NSString *error) {
            [self dismissProgressAlert:alert];
            [self showAlertWithTitle:@"Error Uploading Image" andMessage:nil];
        }];
    }
}

+ (void) postToWallWithImageURL: (NSString*) URL  andCompletionBlock: (void (^)(bool Success))block {
    
    void(^postToWallBlock)(void) = ^(void) {
        TPAppDelegate *appDelegate = (TPAppDelegate*)[[UIApplication sharedApplication]delegate];
        NSMutableDictionary *params =
        [NSMutableDictionary dictionaryWithObjectsAndKeys:
         @"A creation of TapPainter - the premium room coloring tool", @"name",
         @"", @"caption",
         //     message,  @"description",
         @"http://tappainter.com", @"link",
         URL, @"picture",
         nil];
        
        
        [FBWebDialogs presentFeedDialogModallyWithSession:appDelegate.session
                                               parameters:params
                                                  handler:
         ^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
             if (error) {
                 NSLog(@"Post to wall error: %@", error.localizedDescription);
                 // Error launching the dialog or publishing a story.
                 BLOCK(false)
             } else {
                 if (result == FBWebDialogResultDialogNotCompleted) {
                     // User clicked the "x" icon
                     BLOCK(false)
                 } else {
                     // Handle the send request callback
                     NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                     if (![urlParams valueForKey:@"post_id"]) {
                         // User clicked the Cancel button
                         BLOCK(false)
                     } else {
                         // User clicked the Send button
                         NSString *requestID = [urlParams valueForKey:@"post_id"];
                         NSLog(@"Post ID: %@", requestID);
                         BLOCK(true)
                     }
                     //                 BLOCK(true);
                 }
             }
         }];
    };
    
    if (![FBHelper isLoggedIn]) {
        [FBHelper loginWithCompletionBlock:^(bool Success) {
            if (Success) {
                postToWallBlock();
            }
        }];
    } else {
        postToWallBlock();
    }
}

+ (void)signOut {
    [FBSession.activeSession closeAndClearTokenInformation];
}


/**
 * A function for parsing URL parameters.
 */
+ (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [[query urlDecode] componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [[kv objectAtIndex:1]
         stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [params setObject:val forKey:[kv objectAtIndex:0]];
    }
    return params;
}


+ (void)clearCookies {
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies])
    {
        NSLog(@"Cookie: %@", cookie);
        NSString* domainName = [cookie domain];
        NSRange domainRange = [domainName rangeOfString:@"facebook"];
        if(domainRange.length > 0)
        {
            [storage deleteCookie:cookie];
        }
    }
}

@end
