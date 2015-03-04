//
//  TPSavedImagesManager.m
//  Tappainter
//
//  Created by Vadim on 10/13/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import "TPSavedImagesManager.h"
#import "TPPhoto.h"
#import "TPImageAsset.h"
#import "TPAppDefs.h"

#define ASSET_URLS_KEY @"AssetURLs"

static TPSavedImagesManager* sharedInstance;

@interface TPSavedImagesManager() {
    NSMutableArray* savedPhotos_;
    NSMutableArray* assetURLStrings_;
}

@property TPImageAsset* selectedImageAsset;

@end

@implementation TPSavedImagesManager

@synthesize savedPhotos=savedPhotos_;


- (id)init
{
    self = [super init];
    if (self) {
        [self loadPhotos];
    }
    return self;
}

+ (TPSavedImagesManager*)sharedSavedImagesManager {
    if (!sharedInstance) {
        sharedInstance = [[TPSavedImagesManager alloc] init];
    }
    
    return sharedInstance;
}

- (void)loadPhotos {
    savedPhotos_ = [NSMutableArray arrayWithCapacity:0];
#ifndef TAPPAINTER_TRIAL
    assetURLStrings_ = [[NSUserDefaults standardUserDefaults] objectForKey:ASSET_URLS_KEY];
#endif
    if (assetURLStrings_) {
        for (NSString* assetURLString in assetURLStrings_) {
            [savedPhotos_ addObject:[TPPhoto newPhotoWithAssetURL:[NSURL URLWithString:assetURLString]]];
        }
    } else {
        assetURLStrings_ = [NSMutableArray arrayWithCapacity:0];
    }
}

+ (TPImageAsset*)imageAssetWithAssetURL:(NSURL*)assetURL {
    return [[TPSavedImagesManager sharedSavedImagesManager] imageAssetWithAssetURL:assetURL];
}

- (TPImageAsset*)imageAssetWithAssetURL:(NSURL*)assetURL {
    
    TPPhoto* photo;
    if ([assetURLStrings_ containsObject:assetURL]) {
        NSInteger index = [assetURLStrings_ indexOfObject:assetURL.absoluteString];
        photo = [savedPhotos_ objectAtIndex:index];
    } else {
        photo = [TPPhoto newPhotoWithAssetURL:assetURL];
    }
    
    TPImageAsset* asset = photo.originalAsset;
    photo = nil;
    return asset;
}

+ (void)unmarkAllImageAssets {
    for (TPPhoto* photo in [TPSavedImagesManager sharedSavedImagesManager].savedPhotos) {
        photo.originalAsset.markedImageAssets = nil;
    }
}

+ (NSArray*)markedImageAssets {
    NSMutableArray* array = [NSMutableArray array];
    for (TPPhoto* photo in [TPSavedImagesManager sharedSavedImagesManager].savedPhotos) {
        if (photo.originalAsset.markedImageAssets && photo.originalAsset.markedImageAssets.count) {
            [array addObjectsFromArray:photo.originalAsset.markedImageAssets];
        }
    }
    return  array;
}

+ (int)editedAssetsCount {
    int editedAssetsCount = 0;
    for (TPPhoto* photo in [TPSavedImagesManager sharedSavedImagesManager].savedPhotos) {
        editedAssetsCount += photo.originalAsset.editedAssets.count;
    }
    return  editedAssetsCount;
}

+ (TPImageAsset*)imageAssetWithImage:(UIImage *)image andAssetURL:(NSURL *)assetURL {
    return [[TPSavedImagesManager sharedSavedImagesManager] imageAssetWithImage:image andAssetURL:assetURL];
}

- (TPImageAsset*)imageAssetWithImage:(UIImage *)image andAssetURL:(NSURL *)assetURL {
    TPPhoto* photo;
    if ([assetURLStrings_ containsObject:assetURL.absoluteString]) {
        NSInteger index = [assetURLStrings_ indexOfObject:assetURL.absoluteString];
        photo = [savedPhotos_ objectAtIndex:index];
    } else {
        if (!image) {
            return [self imageAssetWithAssetURL:assetURL];
        } else {
            photo = [TPPhoto newPhotoWithImage:image andAssetURL:assetURL];
        }
    }
    
    return photo.originalAsset;
}

+ (TPImageAsset*)saveEditedAssetWithImage:(UIImage *)image forExistingAsset:(TPImageAsset *)existingAsset {
    return [[TPSavedImagesManager sharedSavedImagesManager] saveEditedAssetWithImage:image forExistingAsset:existingAsset];
    
}

- (TPImageAsset*)saveEditedAssetWithImage:(UIImage *)image forExistingAsset:(TPImageAsset *)existingAsset {
    NSAssert([assetURLStrings_ containsObject:existingAsset.originalAssetURL.absoluteString], @"No existing images found");
    NSInteger index = [assetURLStrings_ indexOfObject:existingAsset.originalAssetURL.absoluteString];
    TPPhoto* photo = [savedPhotos_ objectAtIndex:index];
    return [photo addEditedAssetWithImage:image];
}

+ (void)saveOriginalAsset:(TPImageAsset *)imageAsset {
    [[TPSavedImagesManager sharedSavedImagesManager] saveOriginalAsset:imageAsset];
}

- (void)saveOriginalAsset:(TPImageAsset *)imageAsset {
    if (![assetURLStrings_ containsObject:imageAsset.originalAssetURL.absoluteString]) {
        TPPhoto* photo = [TPPhoto newPhotoWithImageAsset:imageAsset];
        [assetURLStrings_ addObject:photo.assetURL.absoluteString];
        [savedPhotos_ addObject:photo];
        self.savedPhotos = savedPhotos_; // Trigger notification for potential observers
        [[NSUserDefaults standardUserDefaults] setObject:assetURLStrings_ forKey:ASSET_URLS_KEY];
    }
}

+ (void)deleteImageAsset:(TPImageAsset *)imageAsset {
    [[TPSavedImagesManager sharedSavedImagesManager] deleteImageAsset:imageAsset];
}

+ (ALAssetsLibrary*)alAssetLibrary {
    return [TPPhoto alAssetLibrary];
}

- (void)deleteImageAsset:(TPImageAsset*)imageAsset {
    if (_selectedImageAsset == imageAsset) {
        _selectedImageAsset.selectedImageAsset = nil;
        _selectedImageAsset = nil;
    }
    NSInteger index = [assetURLStrings_ indexOfObject:imageAsset.originalAssetURL.absoluteString];
    TPPhoto* photo = [savedPhotos_ objectAtIndex:index];
    if ([imageAsset isOriginal]) {
        [assetURLStrings_ removeObject:photo.assetURL.absoluteString];
        [savedPhotos_ removeObject:photo];
        self.savedPhotos = savedPhotos_; // Trigger notification for potential observers
        [[NSUserDefaults standardUserDefaults] setObject:assetURLStrings_ forKey:ASSET_URLS_KEY];
    } else {
        [photo delteEditedImageAsset:imageAsset];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:IMAGE_DELETED_NOTIFICATION object:imageAsset];
}

+ (void)deleteEditedAssetsForAsset:(TPImageAsset *)imageAsset {
    for (TPImageAsset* asset in imageAsset.editedAssets) {
        [self deleteImageAsset:asset];
    }
}

+ (void)setSelectedImageAsset:(TPImageAsset *)selectedAsset {
    [TPSavedImagesManager sharedSavedImagesManager].selectedImageAsset = selectedAsset;
    selectedAsset.selectedImageAsset = selectedAsset;
}

+ (TPImageAsset*)selectedImageAsset {
    return [TPSavedImagesManager sharedSavedImagesManager].selectedImageAsset;
}

@end
