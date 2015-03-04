//
//  TPBrandData.h
//  Tappainter
//
//  Created by Vadim on 11/10/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef TESTRGB
#define COLOR_SERVER_URL @"http://fastrgb.com/api_test/"
#else
#define COLOR_SERVER_URL @"http://fastrgb.com/api_page/"
#endif


enum {
    ktpBrandsWebColor,
    ktpBrandsFirstBrandId
//    ktpBrandsBenjaminMoore = ktpBrandsFirstBrandId,
//    ktpBrandsBrand1 = ktpBrandsBenjaminMoore,
//    ktpBrandsSherwinWilliamsColor,
//    ktpBrandsBrand2 = ktpBrandsSherwinWilliamsColor,
//    ktpBrandsNumberOfBrands,
//    ktpBrandsBrand3,
//    ktpBrandsBrand4,
//    ktpBrandsBrand5
};



@interface TPPageData : NSObject

@property (nonatomic) NSInteger brandId;
@property NSArray* swatches;
@property int selectedSwatch;
@property (nonatomic) UIColor* averageColor;

@end

@interface TPSwatchData : NSObject

@property NSInteger brandId;
@property UIColor* color;
@property NSString* name;
@property NSString* code;
@property NSString* codePrefix;

+ (TPSwatchData*)swatchDataFromDictionary:(NSDictionary*)dict;
- (NSDictionary*)convertToDictionary;

@end

typedef enum {
    ktpBrandDataStatusError,
    ktpBrandDataStatusDownloading,
    ktpBrandDataStatusInitialized
} tpBrandDataStatus;

@interface TPBrandData : NSObject

@property (nonatomic) NSInteger brandId;
@property NSString* name;
@property NSArray* pages;
@property tpBrandDataStatus status;
@property NSString* codePrefix;
@property bool abortSearch;
@property (nonatomic) bool unlocked;

- (id)initWithName:(NSString*)brandName andID:(NSInteger) brandID;
- (void)convertColor:(UIColor*)color withCompletionBlock:(void (^)(TPPageData * pageData, NSString* error))block;
- (TPPageData*)lookUpCode:(NSString*)code;
- (NSArray*)matchingNames:(NSString*)substring;

@end

