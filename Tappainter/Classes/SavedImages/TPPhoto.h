//
//  TPPhoto.h
//  Tappainter
//
//  Created by Vadim on 10/15/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TPImageAsset;
@class ALAssetsLibrary;
@interface TPPhoto : NSObject

+ (TPPhoto*)newPhotoWithImage:(UIImage*)image andAssetURL:(NSURL*)assetURL;
+ (TPPhoto*)newPhotoWithImageAsset:(TPImageAsset*)imageAsset;
+ (TPPhoto*)newPhotoWithAssetURL:(NSURL*)assetURL;
+ (NSString*)assetIDfromURL:(NSURL*)assetURL;
+ (ALAssetsLibrary*)alAssetLibrary;
- (TPImageAsset*)addEditedAssetWithImage:(UIImage*)image;
- (void)delteEditedImageAsset:(TPImageAsset*)imageAsset;
- (void)wipeOut;

@property (nonatomic) UIImage* image;
@property TPImageAsset* originalAsset;
@property (nonatomic) NSArray* editedImageAssets;
@property NSURL* assetURL;

@end
