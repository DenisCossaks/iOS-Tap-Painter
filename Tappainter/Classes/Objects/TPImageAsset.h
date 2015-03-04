//
//  TPImageAsset.h
//  Tappainter
//
//  Created by Vadim on 10/21/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPWallPaintService.h"

@class TPImageAsset;
@class TPPin;
@class TPColor;
@protocol TPImageAssetProcessingDelegate <NSObject>
- (void)imageAsset:(TPImageAsset*)imageAsset processStepName:(NSString*)stepName;
- (void)imageAsset:(TPImageAsset*)imageAsset progress:(float)progress;
@end

@class ALAsset;
@interface TPImageAsset : NSObject<TPWallPaintServiceDelegate>

- (id)initWithImage:(UIImage *)image andOriginalAsset:(TPImageAsset*)original;
- (id)initWithAssetID:(NSString*)assetID;
- (id)initWithAssetID:(NSString*)assetID andSize:(CGSize)size;
- (void)wipeOut;
- (void)upload;
//- (void)paintWithDelegate:(id<TPImageAssetProcessingDelegate>)delegate success:(void (^)(TPImageAsset*))success failure:(void (^)(NSString*))failure;
- (void)paintWithPolygon:(NSArray*)corners delegate:(id<TPImageAssetProcessingDelegate>)delegate success:(void (^)(TPImageAsset*))success failure:(void (^)(NSString*))failure;
- (void)serialize;
- (void)deserialize;
- (void)markImageAsset:(TPImageAsset*)asset;
- (void)unmarkImageAsset:(TPImageAsset*)asset;
- (UIImage*)imageWithSize:(CGSize)size;

@property (nonatomic) UIImage* image;
@property NSString* assetID;
@property NSString* URL;
@property NSString* filePath;
@property TPImageAsset* originalAsset;
@property (nonatomic) NSURL* originalAssetURL;
@property (nonatomic, readonly) bool isOriginal;
@property (nonatomic) NSArray* editedAssets;
@property (nonatomic) TPImageAsset* selectedImageAsset;
@property (nonatomic) NSArray* markedImageAssets;
@property (nonatomic) TPPin* colorMarker;
@property (nonatomic, readonly) bool isMarked;
@property (nonatomic) TPColor* tpColor;
@property ALAsset* alAsset;
@property (nonatomic) CGSize imageSize;

@end
