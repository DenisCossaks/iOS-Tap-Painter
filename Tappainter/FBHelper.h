//
//  FBHelper.h
//  RubyOnIce
//
//  Created by Vadim on 5/8/13.
//  Copyright (c) 2013 DigitalPrunes. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TPImageAsset;
@interface FBHelper : NSObject

+ (void) loginWithCompletionBlock: (void (^)(bool Success))block;
+ (void) postToWallWithImageURL: (NSString*) URL  andCompletionBlock: (void (^)(bool Success))block;
+ (void) signOut;
+ (bool) isLoggedIn;
+ (void) loginSilentlyWithCompletionBlock:(void (^)(bool Success))block;
+ (void) postToWallWithImageAsset:(TPImageAsset*)asset;

@end
