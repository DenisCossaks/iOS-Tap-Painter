//
//  UtilityCategories.h
//  Roshambo
//
//  Created by Vadim Dagman on 6/21/12.
//  Copyright (c) 2012 Digital Prunes, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

//#define TRACK_ALLOCATIONS

inline static bool isValidEmail(NSString* email) {
    NSArray* components = [email componentsSeparatedByString:@"@"];
    if ([components count] < 2)
        return NO;
    components = [(NSString*)components[1] componentsSeparatedByString:@"."];
    if ([components count] < 2)
        return NO;
    return YES;
}



#pragma mark- NSObject Utility Category

@interface NSObject (Utilities) <UIAlertViewDelegate>
 
- (id)convertToMutable: (id) object;
- (id)convertToMutable;
- (NSString*)generateGUID;
- (id)findObjectInAarray: (NSArray*) array byKey: (NSString*) key andStringValue: (NSString*) string; 
- (bool)findStringInArray: (NSArray*) stringArray equalTo: (NSString*) string;
- (id)associativeObjectForKey: (NSString *)key;
- (id)associativeObjectForKey: (NSString *)key release: (BOOL) release;
- (void)removeAssociativeObjectForKey: (NSString *)key;
- (void)setAssociativeObject: (id)object forKey: (NSString *)key;
- (UIAlertView*)displayProgressAlertWithMessage: (NSString*) message;
- (UIAlertView*)displayProgressAlertWithMessage: (NSString *)message cancelButton: (NSString *) cancelButtonName;
- (void)dismissProgressAlert: (UIAlertView*) alertView;
- (void)showAlertWithTitle: (NSString*) title andMessage: (NSString*) message;
+ (void)showAlertWithTitle: (NSString*) title andMessage: (NSString*) message;
//- (void)compareStringArray: (NSArray*) array1 toArray: (NSArray*) array2 withCallback: (void(^)(NSArray* array1Diff, NSArray* array2Diff))callback;
- (bool) coinFlip;
+ (bool)isNullObject:(id)object;
- (void) report_memory;
- (void) report_memory: (NSString*) location;
- (void)addAndTrackObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context;
- (void)removeAndTrackObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;
- (BOOL)checkInternetConnectionWithErrorAlert:(bool)errorAlert;

#ifdef TRACK_ALLOCATIONS
+ (int) totalAllocated;
+ (NSArray*) allocatedObjects;
#endif
@end

#pragma mark- NSObject Category- Blocks

@interface NSObject (Blocks)

+ (id)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay;
+ (id)performBlock:(void (^)(id arg))block withObject:(id)anObject afterDelay:(NSTimeInterval)delay;
+ (id)performBlockInBackground:(void (^)(void))block afterDelay:(NSTimeInterval)delay;
+ (id)performBlockInBackground:(void (^)(id arg))block withObject:(id)anObject afterDelay:(NSTimeInterval)delay;
- (id)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay;
- (id)performBlock:(void (^)(id arg))block withObject:(id)anObject afterDelay:(NSTimeInterval)delay;
- (void)runBlock:(void (^)())block;
+ (void)cancelBlock:(id)block;

@end

#pragma mark- NSString Utility Category

@interface NSString (Utilities)

+ (Boolean)isEmptyString:(NSString*)string;
- (Boolean)isEmptyString;
- (Boolean)isValidPhoneNumber;
- (Boolean)isValidZipCode;
- (Boolean)isValidEmailAddress;
- (NSString*)normalizePhoneNumber;
- (NSString*)formatPhoneNumber;
- (NSString*)urlEncode;
- (NSString*)urlDecode;
- (Boolean) isOnlyNumbers;
- (NSString*) firstWord;
- (NSString*) stringByTrimmingFirstWord;
- (NSInteger) findInArray: (NSArray*) stringArray;
- (NSString*) leaveDigitsOnly;
- (CGSize) sizeWithFontiOs7:(UIFont *)fontToUse;
- (bool)containsString:(NSString*)subString;
+ (NSString*) stringWithInt: (int) number;
+ (NSString*) stringWithFloat: (float) number;
+ (NSString*) stringWithFloat: (float) number maxPresision:(int)precision;
- (NSString*) initWithInt: (int) number;
+ (NSString*) timeStringFromSeconds: (int) sec;
#ifdef TRACK_ALLOCATIONS
+ (int) totalAllocated;
+ (NSArray*) allocatedStrings;
#endif
@end

#pragma mark- NSArray Utility Category
@interface NSArray (Utilities)

-(NSMutableDictionary*) convertToDictionaryForPropertyKey: (NSString*) propKey;
-(NSMutableDictionary*) convertToDictionaryForPropertyKey: (NSString*) propKey1 andKey: (NSString*) propKey2;
-(NSMutableArray*)convertToMutableIfNeeded;
@end

#pragma mark- NSMutableArray Utility Category
@interface NSMutableArray (Utilities)

-(void) mergeWithArray: (NSArray*) array;
#ifdef TRACK_ALLOCATIONS
+ (int) totalAllocated;
#endif
@end

#pragma mark- UILabel Utility Category
@interface UILabel (Utilities)
-(float) sizeThatFitsMultilineWithMaxFontSize: (float) maxFontSize;
@end

#pragma mark- NSDate Utility Category
@interface NSDate (Utilities)
-(int) minutesSinceDate: (NSDate*) date;
-(int) hoursSinceDate: (NSDate*) date;
-(int) daysSinceDate: (NSDate*) date;
-(int) weeksSinceDate: (NSDate*) date;
-(int) monthsSinceDate: (NSDate*) date;
-(int) yearsSinceDate: (NSDate*) date;
- (bool) sameDateAs:(NSDate*)date;
@end

#pragma mark- UIView Utility Category
@interface UIView (Utilities)
-(void) moveToOrigin: (CGPoint) origin;
-(void) moveVerticallyTo: (int) y;
-(void) moveHorizontallyTo: (int) x;
-(void) shiftHorizontallyBy: (int) offset;
-(void) shiftVerticallyBy: (int) offset;
-(float) offsetFromRightEdgeToSuperView;
+(void) hideViews: (NSArray*) viewsArray;
+(bool) isAnyViewVisible: (NSArray*) viewsArray;
- (void)logSubViews;
- (void)logSubViewsForView:(UIView*)view;
+ (id)loadViewFromNib:(NSString*)nibName;
- (UIImage*)render;
#ifdef TRACK_ALLOCATIONS
+ (int) totalAllocated;
#endif
@end

#pragma mark- UIViewController Utility Category
@interface UIViewController (Utilities)
- (id)childControllerOfClass:(id) controllerClass;
@end

#pragma mark- UIViewStoryBoard Utility Category
@interface UIStoryboard (Utilities)
+ (id)instantiateControllerWithId:(NSString*)controllerID;
+ (void)setMainStoryBoardID:(NSString*)storyBoardID;
+ (id)instantiateControllerromStoryBoard:(NSString*)storyBoardID withId:(NSString*)controllerID;
@end


#pragma mark- UIImageView Utility Category
@interface UIImageView (Utilities)
// Translates position in imageView to original image coordinates (image is scaled in view)
- (CGPoint) positionInImage:(CGPoint) viewPosition;
@end

#pragma mark- UIColor Utility Category
@interface UIColor(Utilities)
- (NSString *)getHexRGBString;
@end

#pragma mark- UIImage Category - CS_Extensions
@interface UIImage (CS_Extensions)
- (UIImage *)imageAtRect:(CGRect)rect;
- (UIImage *)imageByScalingProportionallyToMinimumSize:(CGSize)targetSize;
- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize;
- (UIImage *)imageByScalingToSize:(CGSize)targetSize;
- (UIImage *)imageByScalingAspectFitToSize:(CGSize)targetSize;
- (UIImage*)cgImageByScalingAspectFitToSize:(CGSize)targetSize;
- (UIImage*)scaleWithAspectFitAndFixOrinetationToSize:(CGSize)targetSize;
- (UIImage*)cgScaleWithAspectFitAndFixOrinetationToSize:(CGSize)targetSize;
- (UIImage *)imageRotatedByRadians:(CGFloat)radians;
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;
- (UIColor*) getPixelColorAtLocation:(CGPoint)point;
- (UIImage *)fixOrientation;
- (UIImage*)imageByCopyingImage;
- (CIImage*)createCIImageWithColor: (UIColor*) color;
- (void)releaseCGImage;
+ (UIImage *)screenShot;
@end

#pragma mark- UIImage Category - Cache
@interface UIImage(Cache)

/* Used to free all allocated memory for cache */
+(void)freeCache;

/* The usual, horrible -imageNamed: turned pretty. */
//+(UIImage*)imageNamed:(NSString*)name;
+(UIImage*)imageNamed:(NSString*)name cached: (bool) cached;
//
///* With this you can choose if you want the images stored in the cache to autorelease*/
//+(void)setShouldAutorelease:(BOOL)value;
+ (NSDictionary*) cache;
#ifdef TRACK_ALLOCATIONS
+ (int) totalAllocated;
#endif

@end

