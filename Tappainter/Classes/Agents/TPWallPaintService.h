//
//  TPWallPaintService.h
//  Tappainter
//
//  Created by Vadim on 9/25/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TPWallPaintService;
@class TPColor;

typedef enum {
    TPUploadingStep,
    TPApplyingColorStep,
    TPDownloadingStep
} TPPaintServiceStepType;

typedef enum {
    kTPPaintStatusSuccess,
    kTPPaintStatusOriginalNotFound,
    kTPPaintStatusImageNotFound,
    kTPPaintStatusError
} tTPPaintStatus;


@protocol TPWallPaintServiceDelegate <NSObject>
- (void)paintService:(TPWallPaintService*)paintService step:(TPPaintServiceStepType)stepType;
- (void)paintService:(TPWallPaintService*)paintService progress:(float)progress;
@end

@interface TPWallPaintService : NSObject<NSURLConnectionDataDelegate, NSURLConnectionDelegate> {
    __weak id<TPWallPaintServiceDelegate> delegate_;
}
@property NSTimeInterval averageUploadTimeOfOriginalImage;
@property NSTimeInterval averageUploadTimeOfProcessedlImage;
@property NSTimeInterval averagePaintTime;

- (id) initWithDelegate: (id<TPWallPaintServiceDelegate>) delegate;
- (void)uploadImage: (UIImage*)image originalID:(NSInteger)originalID success:(void (^)(NSString* uploadName, NSInteger uploadID, NSString* URL))success failure:(void (^)(NSString*))failure;
- (void)getPictureIDForName:(NSString*)pictureName successBlock:(void (^)(NSInteger))success failureBlock:(void (^)(NSString*))failure;
- (void)paintImageWithName:(NSString*)name originalSize:(CGSize)size atPoint:(CGPoint)point withColor:(UIColor*)color success:(void (^)(UIImage*, NSString* URL))success failure:(void (^)(NSString*))failure;
- (void)rePaintImageWithId:(NSInteger)pictureID name:(NSString*)name originalSize:(CGSize)size atPoint:(CGPoint)point withColor:(UIColor*)color success:(void (^)(UIImage*, NSString* URL))success failure:(void (^)(NSString*))failure;
- (void)paintImageWithName:(NSString*)name originalID:(NSInteger)originalID originalSize:(CGSize)size atPoint:(CGPoint)point withColor:(TPColor *)tpColor andPolygon:(NSArray*)corners success:(void (^)(UIImage *, NSString *))success failure:(void (^)(tTPPaintStatus status, NSString* error))failure;
+ (void)getNumberOfFreeFanDecksWithCompletionBlock:(void(^)(int number))block;
@end


