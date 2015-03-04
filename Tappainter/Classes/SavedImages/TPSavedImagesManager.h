//
//  TPSavedImagesManager.h
//  Tappainter
//
//  Created by Vadim on 10/13/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TPImageAsset;
@class ALAssetsLibrary;
@interface TPSavedImagesManager : NSObject

@property NSArray* savedPhotos;

+ (TPSavedImagesManager*)sharedSavedImagesManager;
+ (TPImageAsset*)imageAssetWithImage:(UIImage*)image andAssetURL:(NSURL*)assetURL;
+ (TPImageAsset*)imageAssetWithAssetURL:(NSURL*)assetURL;
+ (void)saveOriginalAsset:(TPImageAsset*)imageAsset;
+ (TPImageAsset*)saveEditedAssetWithImage:(UIImage*)image forExistingAsset:(TPImageAsset*)existingAsset;
+ (void)setSelectedImageAsset:(TPImageAsset*)selectedAsset;
+ (TPImageAsset*)selectedImageAsset;
+ (void)unmarkAllImageAssets;
+ (NSArray*)markedImageAssets;
+ (int)editedAssetsCount;
+ (void)deleteImageAsset:(TPImageAsset*)imageAsset;
+ (void)deleteEditedAssetsForAsset:(TPImageAsset*)imageAsset;
+ (ALAssetsLibrary*)alAssetLibrary;

@end
