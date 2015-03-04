//
//  TPWallPaintService.m
//  Tappainter
//
//  Created by Vadim on 9/25/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import "TPWallPaintService.h"
#import "UtilityCategories.h"
#import "UIColor-Expanded.h"
#import "TPColor.h"

#define SUCCES_BLOCK_KEY @"SuccessBlockKey"
#define FAILURE_BLOCK_KEY @"FailureBlock"
#define STATUS_CODE_KEY @"StatusCode"
#define START_TIME_KEY @"StartTime"
#define IMAGE_DATA_KEY @"ImageData"
#define EXPECTED_BYTES_KEY @"ExpectedBytes"
#define IMAGE_NAME_KEY @"ImageName"
#define UPLOAD_CONNECTION_TYPE_KEY @"UploadConnectionType"

#define IMAGE_PROCESSING_EXPECTED_TIME 30

#define SERVER_URL @"http://199.231.56.176:8080/tap_painter_server/"

@interface TPWallPaintService() {
    NSDate* applyingColorStartTime_;
    TPPaintServiceStepType stepType_;
    NSInteger numberOfUploadsOfOriginals_;
    NSInteger numberOfUploadsOfProcessed_;
    NSInteger numberOfPaintRequests_;
    NSDate* timeOfLastByeUploaded_;
}

@end

@implementation TPWallPaintService

@synthesize averageUploadTimeOfOriginalImage;
@synthesize averageUploadTimeOfProcessedlImage;

- (id)initWithDelegate:(id<TPWallPaintServiceDelegate>)delegate {
    self = [super init];
    if (self) {
        delegate_ = delegate;
    }
    
    return self;
}


- (void)paintImageWithName:(NSString*)name originalSize:(CGSize)size atPoint: (CGPoint)point withColor: (UIColor*)color success:(void (^)(UIImage*, NSString*))success failure:(void (^)(NSString*))failure {
    // Image is scaled to 640x480 on upload, so coordinates need to be scaled too
    point.x *= 640.0/size.width;
    point.y *= 480.0/size.height;
    
    [self paintImageWithName:name atPoint:point withColor:color successBlock:^{
        [self downloadProccessedImageWithName:name successBlock:^(UIImage *image, NSString* URL) {
            success(image, URL);
        } failureBlock:^(NSString *error) {
            failure(error);
        }];
    } failureBlock:^(NSString *error) {
        failure(error);
    }];
    
}

- (void)paintImageWithName:(NSString*)name originalID:(NSInteger)originalID originalSize:(CGSize)size atPoint:(CGPoint)point withColor:(TPColor *)tpColor andPolygon:(NSArray*)corners success:(void (^)(UIImage *, NSString *))success failure:(void (^)(tTPPaintStatus, NSString *))failure {
    // Image is scaled to 640x480 on upload, so coordinates need to be scaled too
//    point.x *= 640.0/size.width;
//    point.y *= 480.0/size.height;
    
//    NSLog(@"Corners: %@", corners);
//    NSMutableArray* scaledCorners = [NSMutableArray array];
//    for (NSArray* corner in corners) {
//        int x = [corner[0] intValue]; // * 640.0/size.width;
//        int y = [corner[1] intValue]; // * 480.0/size.height;
//        if (y < 0) y = 0;
//        if (y > size.height) y = size.height;
//        if (x < 0) x = 0;
//        if (x > size.width) x = size.width;
//        [scaledCorners addObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:x], [NSNumber numberWithInt:y], nil]];
//    }
//    NSLog(@"Scaled corners: %@", scaledCorners);
    
    [self paintImageWithName:name originalID:originalID  atPoint:point withColor:tpColor andPolygon:corners successBlock:^{
        [self downloadProccessedImageWithName:name successBlock:^(UIImage *image, NSString* URL) {
            success(image, URL);
        } failureBlock:^(NSString *error) {
            failure(kTPPaintStatusError, error);
        }];
    } failureBlock:^(tTPPaintStatus status, NSString *error) {
        failure(status, error);
    }];
    
}


- (void)uploadImage: (UIImage*)image originalID:(NSInteger)originalID  success:(void (^)(NSString* uploadName, NSInteger uploadID, NSString* URL))success failure:(void (^)(NSString*))failure {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSTimeInterval secs = [NSDate timeIntervalSinceReferenceDate];
    int msec = ((long)([NSDate timeIntervalSinceReferenceDate] * 1000 ))% 1000;
    NSLog(@"msec: %d sec: %f", msec, secs);
    NSString* name = [NSString stringWithFormat:@"%@%d", [dateFormatter stringFromDate:[NSDate date]], msec];
//    name = [NSString stringWithFormat:@"%@_%@", name, [self generateGUID]];
//    name = [name stringByReplacingOccurrencesOfString:@"-" withString:@"_"];
    [self doUploadImage:image originalID:originalID withName:name success:^{
        // Double-check it's actually there by trying to get an ID of the uploaded image
        [self getPictureIDForName:name successBlock:^(NSInteger pictureID) {
            success(name, pictureID, [NSString stringWithFormat:@"%@photo_store/%@.jpg", SERVER_URL, name]);
        } failureBlock:^(NSString *error) {
            failure(error);
        }];
    } failure:^(NSString * error) {
        failure(error);
    }];
}



- (void)doUploadImage: (UIImage*)image originalID:(NSInteger)originalID withName:(NSString*)name success:(void (^)(void))success failure:(void (^)(NSString*))failure {
    NSLog(@"doUploadImage: %@", image);
    stepType_ = TPUploadingStep;
    
    NSString *urlString = [NSString stringWithFormat:@"%@picture/save", SERVER_URL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    NSMutableData *body = [NSMutableData data];
    
    
    NSString *boundary = @"----WebKitFormBoundaryavYtVGwUgR9IVK5n";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    // text parameter
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"name\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[name dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    // text parameter
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"original_id\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithInt:(int)originalID] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
   // text parameter
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"description\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    // file
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    NSString* pictureFileName = [name stringByAppendingString:@".jpg"];
    NSString* contentDispiositionString = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"photo\"; filename=\"%@\"\r\n", pictureFileName];
    [body appendData:[contentDispiositionString dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:imageData]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Last text parameter - action
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"create\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Create" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    // close form
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // set request body
    [request setHTTPBody:body];
    
    NSURLConnection* uploadConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    
    if (delegate_) {
        [delegate_ paintService:self step:stepType_];
    }
    [uploadConnection setAssociativeObject:success forKey:SUCCES_BLOCK_KEY];
    [uploadConnection setAssociativeObject:failure forKey:FAILURE_BLOCK_KEY];
    [uploadConnection setAssociativeObject:[NSDate date] forKey:START_TIME_KEY];
    [uploadConnection setAssociativeObject:@"Upload" forKey:UPLOAD_CONNECTION_TYPE_KEY];
    [uploadConnection start];
    
}


- (void)paintImageWithName:(NSString*)name atPoint:(CGPoint)point withColor:(UIColor*)color successBlock:(void (^)(void))success failureBlock:(void (^)(NSString*))failure {
    stepType_ = TPApplyingColorStep;
    if (delegate_) {
        [delegate_ paintService:self step:stepType_];
    }
    NSString* colorString = [color hexStringFromColor];
    if ([colorString hasPrefix:@"0x"]) {
        colorString = [colorString substringFromIndex:2];
    }
    NSString *urlString = [NSString stringWithFormat:@"%@picture/paint?rgb=%@&x_coord=%d&y_coord=%d&img_name=%@", SERVER_URL, colorString, (int)point.x, (int)point.y, name];
    NSLog(@"urlString %@", urlString);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];
    
    applyingColorStartTime_ = [NSDate date];
    __block bool paintRequestInProgress_ = YES;
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        paintRequestInProgress_ = NO;
        if (connectionError) {
            failure(connectionError.description);
        } else {
            NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
            NSInteger status = [httpResponse statusCode];
            if (status == 200) {
                success();
            } else {
                //                    NSString* stringResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSString* errorMessage = [NSString stringWithFormat:@"HTTP Error %ld: %@", status, [NSHTTPURLResponse localizedStringForStatusCode:status]];
                failure(errorMessage);
            }
        }
    }];
    
    [NSObject performBlockInBackground:^{
        while (paintRequestInProgress_) {
            NSTimeInterval timeSinceStart = [[NSDate date] timeIntervalSinceDate:applyingColorStartTime_];
            [self performBlock:^{
                [delegate_ paintService:self progress:timeSinceStart/IMAGE_PROCESSING_EXPECTED_TIME];
            } afterDelay:0];
            [NSThread sleepForTimeInterval:0.1];
        }
    } afterDelay:0];
}

- (void)paintImageWithName:(NSString*)name originalID:(NSInteger)originalID atPoint:(CGPoint)point withColor:(TPColor*)tpColor andPolygon:(NSArray*)corners successBlock:(void (^)(void))success failureBlock:(void (^)(tTPPaintStatus status, NSString* error))failure {
    stepType_ = TPApplyingColorStep;
    if (delegate_) {
        [delegate_ paintService:self step:stepType_];
    }
    NSString* colorString = [tpColor.color hexStringFromColor];
    if ([colorString hasPrefix:@"0x"]) {
        colorString = [colorString substringFromIndex:2];
    }
    NSString *urlString = [NSString stringWithFormat:@"%@picture/paint?rgb=%@&x_coord=%d&y_coord=%d&img_name=%@&original_id=%ld&web_color=%d",SERVER_URL, colorString, (int)point.x, (int)point.y, name, (long)originalID, tpColor.swatchData ? 0 : 1];
    if (corners.count) {
        for (NSArray* point in corners) {
            urlString = [NSString stringWithFormat:@"%@&ux=%d&uy=%d", urlString, [point[0] intValue], [point[1] intValue]];
        }
    }
    NSLog(@"urlString %@", urlString);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];
    
    applyingColorStartTime_ = [NSDate date];
    __block bool paintRequestInProgress_ = YES;
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        paintRequestInProgress_ = NO;
        if (connectionError) {
            failure(kTPPaintStatusError, connectionError.description);
        } else {
            NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
            NSInteger status = [httpResponse statusCode];
            if (status == 200) {
                NSError* error;
                NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                int statusCode = [[jsonDict valueForKey:@"status"] intValue];
                switch (statusCode) {
                    case 1:
                        success();
                        break;
                        
                    case -1:
                        NSLog(@"Paint error: Original Not Found");
                        failure(kTPPaintStatusOriginalNotFound, nil);
                        break;
                        
                    case -2:
                        NSLog(@"Paint error: Image Not Found");
                        failure(kTPPaintStatusImageNotFound, nil);
                        break;
                        
                   default:
                        NSLog(@"Paint error: Unknown error");
                        failure(kTPPaintStatusError, nil);
                        break;
                }
            } else {
                //                    NSString* stringResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSString* errorMessage = [NSString stringWithFormat:@"HTTP Error %ld: %@", (long)status, [NSHTTPURLResponse localizedStringForStatusCode:status]];
                failure(kTPPaintStatusError, errorMessage);
            }
        }
    }];
    
    [NSObject performBlockInBackground:^{
        while (paintRequestInProgress_) {
            NSTimeInterval timeSinceStart = [[NSDate date] timeIntervalSinceDate:applyingColorStartTime_];
            [self performBlock:^{
                [delegate_ paintService:self progress:timeSinceStart/IMAGE_PROCESSING_EXPECTED_TIME];
            } afterDelay:0];
            [NSThread sleepForTimeInterval:0.1];
        }
    } afterDelay:0];
}


- (void)rePaintImageWithId:(NSInteger)pictureID name:(NSString*)name originalSize:(CGSize)size atPoint:(CGPoint)point withColor:(UIColor*)color success:(void (^)(UIImage*, NSString* URL))success failure:(void (^)(NSString*))failure {
    stepType_ = TPApplyingColorStep;
    if (delegate_) {
        [delegate_ paintService:self step:stepType_];
    }
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString* urlString = [NSString stringWithFormat:@"%@picture/reusePainted/%ld",SERVER_URL, (long)pictureID];
    NSLog(@"urlString %@", urlString);
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            failure(connectionError.description);
        } else {
            NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
            NSInteger status = [httpResponse statusCode];
            if (status == 200) {
                [self paintImageWithName:name originalSize:size atPoint:point withColor:color success:success failure:failure];
            } else {
                NSString* errorMessage = [NSString stringWithFormat:@"HTTP Error %ld: %@", status, [NSHTTPURLResponse localizedStringForStatusCode:status]];
                failure(errorMessage);
            }
        }
    }];
}

- (void)downloadProccessedImageWithName:(NSString*)name successBlock:(void (^)(UIImage*, NSString* URL))success failureBlock:(void (^)(NSString*))failure {
    
    self.averagePaintTime = (self.averagePaintTime * numberOfPaintRequests_ + [[NSDate date] timeIntervalSinceDate:applyingColorStartTime_])/(numberOfPaintRequests_+1);
    numberOfPaintRequests_++;
    
    NSString* urlString = [NSString stringWithFormat:@"%@photo_store/%@out.jpg",SERVER_URL, name];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
    
    NSURLConnection* downloadConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    if (!downloadConnection) {
        failure(@"Conneciton error while downloading painted image");
    }
    
    [downloadConnection setAssociativeObject:success forKey:SUCCES_BLOCK_KEY];
    [downloadConnection setAssociativeObject:failure forKey:FAILURE_BLOCK_KEY];
    [downloadConnection setAssociativeObject:[NSMutableData data] forKey:IMAGE_DATA_KEY];
    [downloadConnection setAssociativeObject:name forKey:IMAGE_NAME_KEY];
    [downloadConnection start];
}

- (void)getPictureIDForName:(NSString*)pictureName successBlock:(void (^)(NSInteger))success failureBlock:(void (^)(NSString*))failure {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString* urlString = [NSString stringWithFormat:@"%@picture/getIdByName?name=%@", SERVER_URL, pictureName];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            failure(connectionError.description);
        } else {
            NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
            NSInteger status = [httpResponse statusCode];
            if (status == 200) {
                NSInteger imageID = 0;
                // Parse the returned response for the ID
                NSString* idString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                imageID = [idString intValue];
                if (imageID) {
                    success(imageID);
                } else {
                    failure(@"Error uploading picture");
                    
                }
            } else {
                NSString* errorMessage = [NSString stringWithFormat:@"HTTP Error %ld: %@", status, [NSHTTPURLResponse localizedStringForStatusCode:status]];
                failure(errorMessage);
            }
        }
    }];
}


#pragma mark- NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    NSLog(@"didSendBodyData: written:%ld/expected: %ld", (long)totalBytesWritten, (long)totalBytesExpectedToWrite);
    if (totalBytesExpectedToWrite == totalBytesWritten) {
        timeOfLastByeUploaded_ = [NSDate date];
    }
    float percentage = (float)totalBytesWritten/(float)totalBytesExpectedToWrite;
    if (delegate_) {
        [delegate_ paintService:self progress:percentage];
    }
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (stepType_ == TPDownloadingStep) {
        NSMutableData* imageData = [connection associativeObjectForKey:IMAGE_DATA_KEY];
        [imageData appendData:data];
        
        NSInteger expectedBytes = [[connection associativeObjectForKey:EXPECTED_BYTES_KEY] integerValue];
        if (expectedBytes != NSURLResponseUnknownLength) {
            float percentage = (float)imageData.length/(float)expectedBytes;
            if (delegate_) {
                [delegate_ paintService:self progress:percentage];
            }
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    void (^failureBlock)(NSString*) = [connection associativeObjectForKey:FAILURE_BLOCK_KEY];
    failureBlock(error.description);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"didReceiveResponse");
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    NSInteger status = [httpResponse statusCode];
    if (status == 200) {
        NSInteger expectedBytes = [response expectedContentLength];
        [connection setAssociativeObject:[NSNumber numberWithInteger:expectedBytes] forKey:EXPECTED_BYTES_KEY];
        if (stepType_ == TPApplyingColorStep) {
            stepType_ = TPDownloadingStep;
            if (delegate_ ) {
                [delegate_ paintService:self step:stepType_];
            }
        }
    } else {
        // Save status code to handle it in connectionDidFinishLoading
        [connection setAssociativeObject:[NSNumber numberWithInteger:status] forKey:STATUS_CODE_KEY];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connectionDidFinishLoading");
    NSNumber* status = [connection associativeObjectForKey:STATUS_CODE_KEY];
    if (status) {
        // There was an error
        NSTimeInterval timeSinceStart = [[NSDate date] timeIntervalSinceDate:applyingColorStartTime_];
        if ([status integerValue] == 404) {
            if (timeSinceStart < IMAGE_PROCESSING_EXPECTED_TIME) {
                // File not found which most likel means it's not ready yet. Try again a bit later
                [NSObject performBlock:^{
                    NSString* name = [connection associativeObjectForKey:IMAGE_NAME_KEY];
                    [self downloadProccessedImageWithName:name successBlock:[connection associativeObjectForKey:SUCCES_BLOCK_KEY] failureBlock:[connection associativeObjectForKey:FAILURE_BLOCK_KEY]];
                } afterDelay:1.0];
                if (delegate_) {
                    [delegate_ paintService:self progress:timeSinceStart/IMAGE_PROCESSING_EXPECTED_TIME];
                }
            } else {
                void (^failureBlock)(NSString*) = [connection associativeObjectForKey:FAILURE_BLOCK_KEY];
                failureBlock(@"Server seems to be too busy now. Please try again later.");
            }
        } else {
            void (^failureBlock)(NSString*) = [connection associativeObjectForKey:FAILURE_BLOCK_KEY];
            NSString* errorMessage = [NSString stringWithFormat:@"HTTP Error %d: %@", [status intValue], [NSHTTPURLResponse localizedStringForStatusCode:[status intValue]]];
            @synchronized(self) {
                id uploadType = [connection associativeObjectForKey:UPLOAD_CONNECTION_TYPE_KEY];
                if (uploadType) {
                    // Retry upload again. Ruby server gives that erro once in a while but the second attempt ususally succeeds
                    NSURLConnection* uploadConnection = [[NSURLConnection alloc] initWithRequest:[connection originalRequest] delegate:self startImmediately:NO];
                    [uploadConnection setAssociativeObject:[connection associativeObjectForKey:SUCCES_BLOCK_KEY] forKey:SUCCES_BLOCK_KEY];
                    [uploadConnection setAssociativeObject:[connection associativeObjectForKey:FAILURE_BLOCK_KEY] forKey:FAILURE_BLOCK_KEY];
                    [uploadConnection setAssociativeObject:@"Upload" forKey:UPLOAD_CONNECTION_TYPE_KEY];
                    [uploadConnection setAssociativeObject:[NSDate date] forKey:START_TIME_KEY];
                    [uploadConnection start];
                    
                }
            }
            failureBlock(errorMessage);
        }
    } else {
        id uploadType = [connection associativeObjectForKey:UPLOAD_CONNECTION_TYPE_KEY];
        if (uploadType) {
            NSLog(@"Response time after end of upload: %f", [[NSDate date] timeIntervalSinceDate:timeOfLastByeUploaded_]);
            void (^successBlock)() = [connection associativeObjectForKey:SUCCES_BLOCK_KEY];
            successBlock();
        } else {
            void (^successBlock)(UIImage*, NSString*) = [connection associativeObjectForKey:SUCCES_BLOCK_KEY];
            NSData* imageData = [connection associativeObjectForKey:IMAGE_DATA_KEY];
            UIImage* image = [UIImage imageWithData:imageData];
            [connection removeAssociativeObjectForKey:IMAGE_DATA_KEY];
            successBlock(image, connection.originalRequest.URL.absoluteString);
        }
    }
    
}

+ (void)getNumberOfFreeFanDecksWithCompletionBlock:(void (^)(int number))block {
    NSString* versionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString* appType;
#ifdef TAPPAINTER_STANDARD
    appType = @"standard";
#else
    appType = @"trial";
#endif
    NSString* urlString = [NSString stringWithFormat:@"%@picture/free_fandecks?apptype=%@&version=%@", SERVER_URL, appType, versionString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            block(-1);
        } else {
            NSString* responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            block([responseString intValue]);
        }
    }];
}
@end
