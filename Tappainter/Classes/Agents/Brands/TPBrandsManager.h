//
//  TPBrandsManager.h
//  Tappainter
//
//  Created by Vadim on 11/9/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPBrandData.h"

@interface TPBrandsManager : NSObject

+ (NSString*)brandNameForId:(NSInteger)brandId;
+ (TPBrandData*)brandDataForId:(NSInteger)brandId;
+ (NSArray*)featuredBrands;
+ (NSArray*)allBrands;
+ (NSArray*)unlockedBrands;
+ (NSArray*)lockedBrands;
+ (NSInteger)currentBrand;
+ (TPBrandData*)currentBrandData;
+ (void)setCurrentBrand:(NSInteger)brandId;
+ (void)convertColor:(UIColor*)color withCompletionBlock:(void (^)(TPPageData * pageData, NSString* error))block;
+ (void)lookUpCode:(NSString*)code withCompletionBlock:(void (^)(TPPageData * pageData, NSString* error))block;
+ (int)brandsUnlocked;
+ (void)unlockBrand:(NSInteger)brandId;

@end
