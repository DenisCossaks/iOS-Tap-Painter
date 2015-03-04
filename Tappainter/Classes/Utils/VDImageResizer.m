//
//  VDImageResizer.m
//
//  Created by Vadim Dagman on 3/11/14.
//  Copyright (c) 2014 Digital Prunes. All rights reserved.
//

#import "VDImageResizer.h"
#import <ImageIO/ImageIO.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface VDImage : UIImage

@end

@implementation VDImage

- (void)dealloc {
    CGImageRelease(self.CGImage);
}

@end

static VDImageResizer* sharedInstance;

@implementation VDImageResizer {
}

// Helper methods for thumbnailForAsset:maxPixelSize:
static size_t getAssetBytesCallback(void *info, void *buffer, off_t position, size_t count) {
    ALAssetRepresentation *rep = (__bridge id)info;
    
    NSError *error = nil;
    size_t countRead = [rep getBytes:(uint8_t *)buffer fromOffset:position length:count error:&error];
    
    if (countRead == 0 && error) {
        // We have no way of passing this info back to the caller, so we log it, at least.
        NSLog(@"thumbnailForAsset:maxPixelSize: got an error reading an asset: %@", error);
    }
    
    return countRead;
}

static void releaseAssetCallback(void *info) {
    // The info here is an ALAssetRepresentation which we CFRetain in thumbnailForAsset:maxPixelSize:.
    // This release balances that retain.
    CFRelease(info);
}

// Returns a UIImage for the given asset, with size length at most the passed size.
// The resulting UIImage will be already rotated to UIImageOrientationUp, so its CGImageRef
// can be used directly without additional rotation handling.
// This is done synchronously, so you should call this method on a background queue/thread.
- (UIImage *)thumbnailForAsset:(ALAsset *)asset size:(CGSize)size {
    NSParameterAssert(asset != nil);
//    NSParameterAssert(size > 0);
    
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    
    if (!rep) {
        return nil;
    }
    
    CGDataProviderDirectCallbacks callbacks = {
        .version = 0,
        .getBytePointer = NULL,
        .releaseBytePointer = NULL,
        .getBytesAtPosition = getAssetBytesCallback,
        .releaseInfo = releaseAssetCallback,
    };
    
    CGDataProviderRef provider = CGDataProviderCreateDirect((void *)CFBridgingRetain(rep), [rep size], &callbacks);
    CGImageSourceRef source = CGImageSourceCreateWithDataProvider(provider, NULL);
    
    CGImageRef imageRef = CGImageSourceCreateThumbnailAtIndex(source, 0, (__bridge CFDictionaryRef) @{
                                                                                                      (NSString *)kCGImageSourceCreateThumbnailFromImageAlways : @YES,
                                                                                                      (NSString *)kCGImageSourceThumbnailMaxPixelSize : [NSNumber numberWithInt:MAX(size.width, size.height)],
                                                                                                      (NSString *)kCGImageSourceCreateThumbnailWithTransform : @YES,
                                                                                                      });
    
    if (!imageRef) {
        CFRelease(source);
        CFRelease(provider);
        return nil;
    }
    
    UIImage *toReturn = [[UIImage alloc] initWithCGImage:imageRef];// [UIImage imageWithCGImage:imageRef];
    
    CFRelease(imageRef);
    CFRelease(source);
    CFRelease(provider);
    
    return toReturn;
}


- (UIImage *)thumbnailForImageFile:(NSString *)imageFile size:(CGSize)size {
//    CGDataProviderDirectCallbacks callbacks = {
//        .version = 0,
//        .getBytePointer = NULL,
//        .releaseBytePointer = NULL,
//        .getBytesAtPosition = getAssetBytesCallback,
//        .releaseInfo = releaseAssetCallback,
//    };
//    
//    
    CGDataProviderRef provider = CGDataProviderCreateWithFilename([imageFile cStringUsingEncoding:NSUTF8StringEncoding]);
    CGImageSourceRef source = CGImageSourceCreateWithDataProvider(provider, NULL);
    
    CGImageRef imageRef = CGImageSourceCreateThumbnailAtIndex(source, 0, (__bridge CFDictionaryRef) @{
                                                                                                      (NSString *)kCGImageSourceCreateThumbnailFromImageAlways : @YES,
                                                                                                      (NSString *)kCGImageSourceThumbnailMaxPixelSize : [NSNumber numberWithInt:MAX(size.width, size.height)],
                                                                                                      (NSString *)kCGImageSourceCreateThumbnailWithTransform : @YES,
                                                                                                      });
    if (!imageRef) {
        CFRelease(source);
        CFRelease(provider);
        return nil;
    }
    
    UIImage *toReturn = [[UIImage alloc] initWithCGImage:imageRef];// [UIImage imageWithCGImage:imageRef];
    
    CFRelease(imageRef);
    CFRelease(source);
    CFRelease(provider);
    
    return toReturn;
}


+ (UIImage *)thumbnailForAsset:(ALAsset *)asset size:(CGSize)size {
    return [[[VDImageResizer alloc] init] thumbnailForAsset:asset size:size];
}

+ (UIImage *)thumbnailForImageFile:(NSString *)imageFile size:(CGSize)size {
    return [[[VDImageResizer alloc] init] thumbnailForImageFile:imageFile size:size];
}


@end
