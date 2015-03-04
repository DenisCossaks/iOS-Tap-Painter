//
//  TPImage.m
//  Tappainter
//
//  Created by Vadim on 10/21/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import "TPImageAsset.h"
#import "TPWallPaintService.h"
#import "TPSavedImagesManager.h"
#import "TPPin.h"
#import "UtilityCategories.h"
#import "TPBrandData.h"
#import "TPColor.h"
#import "TPSavedColors.h"
#import "Flurry.h"
#import "TPCornerMarker.h"
#import "VDImageResizer.h"

#define UPLOAD_ID_KEY @"UploadID"
#define UPLOAD_NAME_KEY @"UploadName"
#define URL_KEY @"URL"
#define PIN_X_COORD @"PinXCoord"
#define PIN_Y_COORD @"PinYCord"
#define TPCOLOR_KEY @"TPColor"

typedef void(^tpImageUploadSuccessBlock)(void);
typedef void(^tpImageUploadFailureBlock)(NSString* error);

@interface TPImageAsset() {
    NSString* fileName_;
    bool beingUploaded_;
    TPWallPaintService* paintService_;
    id semaphore_;
    NSString* lastNetworkError_;
    tpImageUploadSuccessBlock uploadSuccessBlock_;
    tpImageUploadFailureBlock uploadFailureBlock_;
    __weak id<TPImageAssetProcessingDelegate> delegate_;
}

@property (nonatomic) NSString* uploadName;
@property (nonatomic) NSInteger uploadID;

@end

@implementation TPImageAsset

@synthesize selectedImageAsset=_selectedImageAsset;
@synthesize colorMarker=_colorMarker;
@synthesize markedImageAssets=_markedImageAssets;
@synthesize filePath=fileName_;

- (id)init
{
    self = [super init];
    if (self) {
        paintService_ = [[TPWallPaintService alloc] initWithDelegate:self];
        semaphore_ = [[NSObject alloc] init];
        [self addObserver:self forKeyPath:@"tpColor" options:NSKeyValueObservingOptionNew context:nil];
        _imageSize = CGSizeZero;
    }
    return self;
}

- (id)initWithImage:(UIImage *)image andOriginalAsset:(TPImageAsset *)original
{
    self = [self init];
    if (self) {
        self.image = [image imageByScalingAspectFitToSize:CGSizeMake(640, 640)];
        _imageSize = _image.size;
        // Save it to disc write away
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
        _assetID = [NSString stringWithFormat:@"%@-%@", original.assetID, [dateFormatter stringFromDate:[NSDate date]]];
        _originalAsset = original;
        [self saveImageToFile];
        [self serialize];
        [self releaseImage];
    }
    return self;
}

- (id)initWithAssetID:(NSString *)assetID
{
    self = [self init];
    if (self) {
        _assetID = assetID;
        [self deserialize];
        fileName_ = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.png", _assetID]];
//        self.image = [UIImage imageWithContentsOfFile:fileName_];
//        _imageSize = _image.size;
    }
    return self;
}

- (id)initWithAssetID:(NSString *)assetID andSize:(CGSize)size { // This one

    self = [self init];
    if (self) {
        _assetID = assetID;
        [self deserialize];
        fileName_ = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.png", _assetID]];
        self.image = [[UIImage imageWithContentsOfFile:fileName_] imageByScalingToSize:size];
        _imageSize = _image.size;
    }
    return self;
}


- (void)serialize {
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInteger:_uploadID], UPLOAD_ID_KEY,
                          _uploadName, UPLOAD_NAME_KEY,
                          _URL, URL_KEY,
                          nil];
    if (_colorMarker) {
        [dict setObject:[NSNumber numberWithFloat:_colorMarker.position.x] forKey:PIN_X_COORD];
        [dict setObject:[NSNumber numberWithFloat:_colorMarker.position.y] forKey:PIN_Y_COORD];
    }
    if (_tpColor) {
        [dict setObject:[_tpColor serializeKey] forKey:TPCOLOR_KEY];
    }
    [dict setObject:[NSNumber numberWithFloat:_imageSize.width] forKey:@"imageWidth"];
    [dict setObject:[NSNumber numberWithFloat:_imageSize.height] forKey:@"imageHeight"];
    NSLog(@"TPmageAsset Serialize: key: %@ dict: %@", [self serializeKey], dict);
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:[self serializeKey]];
}

- (void)deserialize {
    NSDictionary* dict = [[NSUserDefaults standardUserDefaults] objectForKey:[self serializeKey]];
    NSLog(@"TPmageAsset Deserialize: key: %@ dict: %@", [self serializeKey], dict);
    _uploadName = [dict objectForKey:UPLOAD_NAME_KEY];
    _uploadID = [[dict objectForKey:UPLOAD_ID_KEY] integerValue];
    _URL = [dict objectForKey:URL_KEY];
    NSNumber* pinXPos = [dict objectForKey:PIN_X_COORD];
    if (pinXPos) {
        _colorMarker = [[TPPin alloc] init];
        NSNumber* pinYPos = [dict objectForKey:PIN_Y_COORD];
        _colorMarker.position = CGPointMake([pinXPos floatValue], [pinYPos floatValue]);
    }
    NSString* tpColorKey = [dict objectForKey:TPCOLOR_KEY];
    if (tpColorKey) {
        _tpColor = [TPSavedColors tpColorForKey:tpColorKey];
        if (_colorMarker) {
            _colorMarker.tpColor = _tpColor;
            _colorMarker.colorChanged = NO;
        }
    }
//    _imageSize.width = [[dict objectForKey:@"imageWidth"] floatValue];
//    _imageSize.height = [[dict objectForKey:@"imageHeight"] floatValue];
}

- (NSString*)serializeKey {
    return [@"imageAsset_" stringByAppendingString:_assetID];
}

- (id)initFromFile:(NSString*)fileName
{
    self = [self init];
    if (self) {
        fileName_ = fileName;
        self.image = [UIImage imageWithContentsOfFile:fileName];
        [self serialize];
    }
    return self;
}

- (void)setUploadID:(NSInteger)uploadID {
    _uploadID = uploadID;
    [self serialize];
}

- (void)setUploadName:(NSString *)uploadName {
    _uploadName = uploadName;
    [self serialize];
}

- (void)wipeOut {
    [[NSFileManager defaultManager] removeItemAtPath:fileName_ error:nil];
    if ([self serializeKey]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[self serializeKey]];
    }
}

- (void) saveImageToFile {
    NSLog(@"Image Size: %@", SIZE_TO_STRING(_image.size));
    fileName_ = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.png", _assetID]];
    [UIImagePNGRepresentation(_image) writeToFile:fileName_ atomically:YES];
//    NSURL* url = [NSURL fileURLWithPath:fileName_];
//   [url setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:nil];
}

- (bool)isOriginal {
    return _originalAsset == nil || _originalAsset == self;
}

- (NSArray*)editedAssets {
    if (self.isOriginal)
        return _editedAssets;
    else
        return _originalAsset.editedAssets;
}

- (NSURL*)originalAssetURL {
    if (self.isOriginal)
        return _originalAssetURL;
    else
        return _originalAsset.originalAssetURL;
}

- (void)setSelectedImageAsset:(TPImageAsset *)selectedImageAsset {
    if (self.isOriginal)
        _selectedImageAsset = selectedImageAsset;
    else
        self.originalAsset.selectedImageAsset = selectedImageAsset;
}

- (TPImageAsset *)selectedImageAsset {
    if (self.isOriginal)
        return _selectedImageAsset;
    else
        return _originalAsset.selectedImageAsset;
}

- (NSArray*)markedImageAssets {
    if (self.isOriginal)
        return _markedImageAssets;
    else
        return _originalAsset.markedImageAssets;
}

- (void)setMarkedImageAssets:(NSArray *)markedImageAssets {
    if (self.isOriginal)
        _markedImageAssets = markedImageAssets;
    else
        _originalAsset.markedImageAssets = markedImageAssets;
}

- (void)markImageAsset:(TPImageAsset *)asset {
//    NSAssert([self.editedAssets containsObject:asset], @"Marked image asset is not one of the Edited Assets");
    if (!self.markedImageAssets) {
        _originalAsset.markedImageAssets = [NSMutableArray array];
    }
    NSMutableArray* markedAssets = [self.markedImageAssets convertToMutableIfNeeded];
    [markedAssets addObject:asset];
    self.markedImageAssets = markedAssets;
}

- (void)unmarkImageAsset:(TPImageAsset *)asset {
//    NSAssert([self.editedAssets containsObject:asset], @"Marked image asset is not one of the Edited Assets");
    NSAssert([self.markedImageAssets containsObject:asset], @"Unmarked image assets wasn't previously marked");
    NSMutableArray* markedAssets = [self.markedImageAssets convertToMutableIfNeeded];
    [markedAssets removeObject:asset];
    self.markedImageAssets = markedAssets;
}

- (bool)isMarked {
    return [self.markedImageAssets containsObject:self];
}

- (void)setColorMarker:(TPPin *)colorMarker {
    _colorMarker = colorMarker;
    [self serialize];
}

- (void)paintWithPolygon:(NSArray*)corners delegate:(id<TPImageAssetProcessingDelegate>)delegate success:(void (^)(TPImageAsset*))success failure:(void (^)(NSString*))failure {
    delegate_ = delegate;
    

    void(^blockOnSuccess)(UIImage *image, NSString* URL) = ^(UIImage *image, NSString* URL) {
        [Flurry endTimedEvent:@"Paint" withParameters:nil];
        TPImageAsset* imageAsset = [TPSavedImagesManager saveEditedAssetWithImage:image forExistingAsset:self];
        [self releaseCGImageforImage:image];
        imageAsset.URL = URL;
        delegate_ = nil;
        success(imageAsset);
    };
    
    void(^blockOnError)(NSString* error) = ^(NSString* error) {
        [Flurry endTimedEvent:@"Paint" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"Error", @"Status", nil]];
        [Flurry logError:@"Paint Error" message:error error:nil];
        delegate_ = nil;
        failure(error);
    };
    
    NSMutableArray* points = [NSMutableArray array];
    for (TPCornerMarker* marker in corners) {
        [points addObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:marker.positionInImage.x], [NSNumber numberWithInt:marker.positionInImage.y], nil]];
    }
    
    [Flurry logEvent:@"Paint" timed:YES];
    [paintService_ paintImageWithName:_uploadName originalID:self.originalAsset.uploadID originalSize:self.imageSize atPoint:_colorMarker.positionInImage withColor:_colorMarker.tpColor andPolygon:points success:^(UIImage *image, NSString* URL) {
        blockOnSuccess(image, URL);
    } failure:^(tTPPaintStatus status, NSString* error) {
        if (status == kTPPaintStatusOriginalNotFound) {
            [self.originalAsset uploadWithSuccess:^{
                [paintService_ paintImageWithName:_uploadName originalID:self.originalAsset.uploadID originalSize:self.imageSize atPoint:_colorMarker.positionInImage withColor:_colorMarker.tpColor andPolygon:points success:^(UIImage *image, NSString* URL) {
                    blockOnSuccess(image, URL);
                } failure:^(tTPPaintStatus status, NSString* error) {
                    if (status == kTPPaintStatusImageNotFound) {
                        [self uploadWithSuccess:^{
                            [paintService_ paintImageWithName:_uploadName originalID:self.originalAsset.uploadID originalSize:self.imageSize atPoint:_colorMarker.positionInImage withColor:_colorMarker.tpColor andPolygon:points success:^(UIImage *image, NSString* URL) {
                                blockOnSuccess(image, URL);
                            } failure:^(tTPPaintStatus status, NSString* error) {
                                blockOnError(error);
                            }];
                        } failure:^(NSString *error) {
                            blockOnError(error);
                        }];
                    } else {
                        blockOnError(error);
                    }
                }];
            } failure:^(NSString *error) {
                blockOnError(error);
            }];
        } else if (status == kTPPaintStatusImageNotFound) {
            [self uploadWithSuccess:^{
                [paintService_ paintImageWithName:_uploadName originalID:self.originalAsset.uploadID originalSize:self.imageSize atPoint:_colorMarker.positionInImage withColor:_colorMarker.tpColor andPolygon:points success:^(UIImage *image, NSString* URL) {
                    blockOnSuccess(image, URL);
                } failure:^(tTPPaintStatus status, NSString* error) {
                    if (status == kTPPaintStatusOriginalNotFound) {
                        [self.originalAsset uploadWithSuccess:^{
                            [paintService_ paintImageWithName:_uploadName originalID:self.originalAsset.uploadID originalSize:self.imageSize atPoint:_colorMarker.positionInImage withColor:_colorMarker.tpColor andPolygon:points success:^(UIImage *image, NSString* URL) {
                                blockOnSuccess(image, URL);
                            } failure:^(tTPPaintStatus status, NSString* error) {
                                blockOnError(error);
                            }];
                        } failure:^(NSString *error) {
                            blockOnError(error);
                        }];
                    } else {
                        blockOnError(error);
                    }
                }];
            } failure:^(NSString *error) {
                blockOnError(error);
            }];
        } else {
            blockOnError(error);
        }
    }];
    
}



- (CGSize)imageSize {
    if (_imageSize.width != 0) return _imageSize;
    UIImage* image = self.image;
    _imageSize  = image.size;
    return _imageSize;
}


- (void)uploadWithSuccess:(tpImageUploadSuccessBlock)success failure:(tpImageUploadFailureBlock)failure {
    @synchronized(semaphore_) {
        if (_uploadName) {
            // Check if file is still there
            [paintService_ getPictureIDForName:_uploadName successBlock:^(NSInteger uploadID) {
                if (uploadID != _uploadID) {
                    // Whateevr went wrong it's not the same picure we have uploaded. Need to upload again.
                    self.uploadName = nil;
                    self.uploadID = 0;
                    [self upload];
                } else {
                    if (success)
                        success();
                }
            } failureBlock:^(NSString *error) {
                self.uploadName = nil;
                self.uploadID = 0;
               [self upload];
            }];
        } else {
            if (success)
                uploadSuccessBlock_ = success;
            if (failure)
                uploadFailureBlock_ = failure;
            
            if (!beingUploaded_) {
                beingUploaded_ = YES;
                __block UIImage* image = self.image;
                [paintService_ uploadImage:image originalID:self.originalAsset.uploadID success:^(NSString *uploadName, NSInteger uploadID, NSString* URL) {
                    @synchronized(semaphore_) {
                        beingUploaded_ = NO;
                        lastNetworkError_ = nil;
                        self.uploadName = uploadName;
                        self.uploadID = uploadID;
                        if (uploadSuccessBlock_)
                            uploadSuccessBlock_();
                        uploadSuccessBlock_ = nil;
                        uploadFailureBlock_ = nil;
                    }
                } failure:^(NSString *error) {
                    beingUploaded_ = NO;
                    if (uploadFailureBlock_)
                        uploadFailureBlock_(error);
                    uploadSuccessBlock_ = nil;
                    uploadFailureBlock_ = nil;
                    lastNetworkError_ = error;
                }];
                [self releaseCGImageforImage:image]; // CGImageRelease(image.CGImage);
                image = nil;
            } else {
                if (delegate_)
                    [delegate_ imageAsset:self processStepName:@"Uploading"];
            }
        }
    }
}

- (void)upload {
    [self uploadWithSuccess:nil failure:nil];
}

- (UIImage*)image {
    if (_image) return _image;
    return [self imageWithSize:CGSizeMake(640, 640)];
//    if (_alAsset) {
//        return [VDImageResizer thumbnailForAsset:_alAsset size:CGSizeMake(640, 640)];
//    } else if (fileName_) {
//        return [VDImageResizer thumbnailForImageFile:fileName_ size:CGSizeMake(640, 640)];
//    }
//    return nil;
}

- (UIImage*)imageWithSize:(CGSize)size {
    UIImage* image = nil;
    if (_alAsset) {
        image = [VDImageResizer thumbnailForAsset:_alAsset size:size];
    } else if (fileName_) {
        image = [VDImageResizer thumbnailForImageFile:fileName_ size:size];
    }
    return image;
}

#pragma mark- TPWallPaintServiceDelegate

- (void)paintService:(TPWallPaintService*)paintService step:(TPPaintServiceStepType)stepType {
    if (delegate_) {
        switch (stepType) {
            case TPUploadingStep:
                [delegate_ imageAsset:self processStepName:@"Uploading"];
                break;
                
            case TPApplyingColorStep:
                [delegate_ imageAsset:self processStepName:@"Applying color"];
                break;
                
            case TPDownloadingStep:
                [delegate_ imageAsset:self processStepName:@"Downloading"];
                break;
                
            default:
                break;
        }
    }
}

- (void)paintService:(TPWallPaintService*)paintService progress:(float)progress {
    if (delegate_)
        [delegate_ imageAsset:self progress:progress];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"tpColor"] /*|| [keyPath isEqualToString:@"position"]*/) {
        [self serialize];
    }
}

- (void)releaseImage {
    [self releaseCGImageforImage:_image];
    _image = nil;
}

- (void)releaseCGImageforImage:(UIImage*)image {
    if (CFGetRetainCount((__bridge CFTypeRef)(image)) > 1) {
        while (CFGetRetainCount(image.CGImage) > 1) {
            CGImageRelease(image.CGImage);
        }
        CGImageRelease(image.CGImage);
    } else {
        CGImageRelease(image.CGImage);
    }
}

- (void) dealloc {
    [self removeObserver:self forKeyPath:@"tpColor"];
    [self wipeOut];
//    fileName_ = nil;
//    paintService_ = nil;
//    semaphore_ = nil;
//    lastNetworkError_ = nil;
//    uploadSuccessBlock_ = nil;
//    uploadFailureBlock_ = nil;
//    delegate_ = nil;
}

@end
