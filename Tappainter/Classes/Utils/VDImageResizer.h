//
//  VDImageResizer.h
//
//  Created by Vadim Dagman on 3/11/14.
//  Copyright (c) 2014 Digital Prunes. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ALAssetRepresentation;
@class ALAsset;
@interface VDImageResizer : NSObject

@property CGSize size;

+ (UIImage *)thumbnailForAsset:(ALAsset *)asset size:(CGSize)size;
- (UIImage *)thumbnailForAsset:(ALAsset *)asset size:(CGSize)size;
+ (UIImage *)thumbnailForImageFile:(NSString *)imageFile size:(CGSize)size;

@end
