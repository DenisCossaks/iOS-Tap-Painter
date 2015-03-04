//
//  TPPhoto.m
//  Tappainter
//
//  Created by Vadim on 10/15/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import "TPPhoto.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "TPImageAsset.h"
#import "UtilityCategories.h"

@interface TPPhoto() {
    NSMutableArray* editedImageAssets_;
    NSMutableArray* editedAssetIDs_;
}
@end

@implementation TPPhoto

@synthesize editedImageAssets=editedImageAssets_;

+ (TPPhoto*)newPhotoWithImageAsset:(TPImageAsset*)imageAsset {
    return [[TPPhoto alloc] initWithImageAsset:imageAsset];
}

- (id)initWithImageAsset:(TPImageAsset*)imageAsset {
    self = [super init];
    if (self) {
        editedImageAssets_ = [NSMutableArray arrayWithCapacity:0];
        editedAssetIDs_ = [NSMutableArray arrayWithCapacity:0];
        _assetURL = imageAsset.originalAssetURL;
        _originalAsset = imageAsset;
        _originalAsset.originalAsset = _originalAsset;
        _originalAsset.editedAssets = editedImageAssets_;
    }
    return self;
}

+ (TPPhoto*)newPhotoWithImage:(UIImage*)image andAssetURL:(NSURL*)assetURL {
    if (image.size.width > image.size.height) {
        image = [image imageByScalingToSize:CGSizeMake(640, 480)];
    } else {
        image = [image imageByScalingToSize:CGSizeMake(480, 640)];
    }
    return [[TPPhoto alloc] initWithImage:image andAssetURL:assetURL];
}

+ (TPPhoto*)newPhotoWithAssetURL:(NSURL*)assetURL {
    return [[TPPhoto alloc] initWithAssetURL:assetURL];
}

- (id)init
{
    self = [super init];
    if (self) {
        editedImageAssets_ = [NSMutableArray arrayWithCapacity:0];
        editedAssetIDs_ = [NSMutableArray arrayWithCapacity:0];
        _originalAsset = [[TPImageAsset alloc] init];
        _originalAsset.originalAsset = _originalAsset;
        _originalAsset.editedAssets = editedImageAssets_;
    }
    return self;
}

- (id)initWithImage:(UIImage*)image andAssetURL:(NSURL*)assetURL
{
    self = [self init];
    if (self) {
        _assetURL = assetURL;
        [self initializeWithImage:image andAssetURL:assetURL];
    }
    return self;
}

- (id)initWithAssetURL:(NSURL*)assetURL
{
    self = [self init];
    if (self) {
        _assetURL = assetURL;
        _originalAsset.originalAssetURL = assetURL;
//        ALAssetsLibrary *al = [[ALAssetsLibrary alloc] init];
        [[TPPhoto alAssetLibrary] assetForURL:assetURL resultBlock:^(ALAsset *asset) {
            _originalAsset.alAsset = asset;
//            ALAssetRepresentation *assetRepresentation = [asset defaultRepresentation];
//            
//            UIImage* image = [UIImage imageWithCGImage:[assetRepresentation fullScreenImage]
//                                                 scale:[assetRepresentation scale]
//                                           orientation:(UIImageOrientation)ALAssetOrientationUp];
//            if (image.size.width > image.size.height) {
//                image = [image imageByScalingToSize:CGSizeMake(640, 480)];
//            } else {
//                image = [image imageByScalingToSize:CGSizeMake(480, 640)];
//            }
            [self initializeWithAssetURL:assetURL];
            
        } failureBlock:^(NSError *error) {
        }];
    }
    return self;
}

+ (ALAssetsLibrary*)alAssetLibrary {
    static ALAssetsLibrary* alAssetLibrary;
    if (!alAssetLibrary) {
        alAssetLibrary = [[ALAssetsLibrary alloc] init];
    }
    return alAssetLibrary;
}

- (void)initializeWithImage:(UIImage*)image andAssetURL:(NSURL*)assetURL { // This one
    
    _originalAsset.assetID = [TPPhoto assetIDfromURL:assetURL];
    [_originalAsset deserialize];
    _assetURL = assetURL;
    _originalAsset.originalAssetURL = assetURL;
    // Check to see if we already have saved edited images for that image
    editedAssetIDs_ = [[NSUserDefaults standardUserDefaults] objectForKey:_originalAsset.assetID];
    if (editedAssetIDs_) {
        for (NSString* assetID in editedAssetIDs_) {
            TPImageAsset* editedImageAsset = [[TPImageAsset alloc] initWithAssetID:assetID andSize:image.size];
            editedImageAsset.originalAsset = _originalAsset;
            [editedImageAssets_ addObject:editedImageAsset];
            // Make sure we invoke property setter to notify potential observers waiting for the image to load
            self.editedImageAssets = editedImageAssets_;
            _originalAsset.editedAssets = editedImageAssets_;
        }
    } else {
        editedAssetIDs_ = [NSMutableArray arrayWithCapacity:0];
    }
    _originalAsset.image = image;
}

- (void)initializeWithAssetURL:(NSURL*)assetURL { // This one
    _originalAsset.assetID = [TPPhoto assetIDfromURL:assetURL];
    [_originalAsset deserialize];
    _assetURL = assetURL;
    _originalAsset.originalAssetURL = assetURL;
    _originalAsset.originalAsset = _originalAsset;
    // Check to see if we already have saved edited images for that image
    editedAssetIDs_ = [[NSUserDefaults standardUserDefaults] objectForKey:_originalAsset.assetID];
    if (editedAssetIDs_) {
        for (NSString* assetID in editedAssetIDs_) {
            TPImageAsset* editedImageAsset = [[TPImageAsset alloc] initWithAssetID:assetID];
            editedImageAsset.originalAsset = _originalAsset;
            [editedImageAssets_ addObject:editedImageAsset];
            // Make sure we invoke property setter to notify potential observers waiting for the image to load
            self.editedImageAssets = editedImageAssets_;
            _originalAsset.editedAssets = editedImageAssets_;
        }
    } else {
        editedAssetIDs_ = [NSMutableArray arrayWithCapacity:0];
    }
    [_originalAsset setImage:nil];
}


- (UIImage*)image {
    return _originalAsset.image;
}

- (TPImageAsset*)addEditedAssetWithImage:(UIImage *)image {
#ifdef TAPPAINTER_TRIAL
    [editedAssetIDs_ removeAllObjects];
    [editedImageAssets_ removeAllObjects];
#endif
    TPImageAsset* editedImageAsset = [[TPImageAsset alloc] initWithImage:image andOriginalAsset:_originalAsset];
    [editedImageAssets_ addObject:editedImageAsset];
    [editedAssetIDs_ addObject:editedImageAsset.assetID];
#ifndef TAPPAINTER_TRIAL
    [[NSUserDefaults standardUserDefaults] setObject:editedAssetIDs_ forKey:_originalAsset.assetID];
#endif
    self.editedImageAssets = editedImageAssets_; //Notify potential ovservers about the change
    _originalAsset.editedAssets = editedImageAssets_;
    [_originalAsset serialize];
    return editedImageAsset;
}

- (void)delteEditedImageAsset:(TPImageAsset*)imageAsset {
    NSAssert([editedImageAssets_ containsObject:imageAsset], @"Edited image asset doesn't exist");
    NSInteger index =  [editedImageAssets_ indexOfObject:imageAsset];
    [imageAsset wipeOut];
    [editedImageAssets_ removeObjectAtIndex:index];
    [editedAssetIDs_ removeObjectAtIndex:index];
    [[NSUserDefaults standardUserDefaults] setObject:editedAssetIDs_ forKey:_originalAsset.assetID];
    // Make sure we invoke property setter to notify potential observers waiting for the image to load
    self.editedImageAssets = editedImageAssets_;
    _originalAsset.editedAssets = editedImageAssets_;
    [_originalAsset serialize];
}

- (void)wipeOut {
    if (_originalAsset) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:_originalAsset.assetID];
    }
}

+ (NSString*)assetIDfromURL:(NSURL*) assetURL {
    NSString* idString;
    NSArray* components = [assetURL.absoluteString componentsSeparatedByString:@"?"];
    NSAssert(components && [components count] > 1, @"Asset URL is missing \"?\" separator before parameters");
    components = [(NSString*)components[1] componentsSeparatedByString:@"&"];
    for (NSString* component in components) {
        if ([component hasPrefix:@"id="]) {
            idString = [component substringFromIndex:3];
            break;
        }
    }
    NSAssert(idString!=nil, @"Can't parse ID from the asset URL");
    return idString;
}

- (void)dealloc {
//    [self wipeOut];
}
@end
