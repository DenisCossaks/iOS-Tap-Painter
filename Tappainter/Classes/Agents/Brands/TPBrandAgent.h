//
//  TPBrandAgent.h
//  Tappainter
//
//  Created by Vadim on 11/10/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TPBrandData;
@class TPPageData;
@interface TPBrandAgent : NSObject

+ (void)loadBrandDataFromKey:(NSString*)key intoBrandData:(TPBrandData*)brandData;
+ (void)loadBrandData:(TPBrandData*)brandData fromPagesArrays:(NSArray*)pagesArray;
+ (void)downloadBrandDataWithCompletionBlock:(void (^)(NSArray *))block;
// This has ot be overridden by a subclass
+ (void)convertColor:(UIColor*)color withCompletionBlock:(void (^)(TPPageData * pageData, NSString* error))block;
// Has to be overridden
+ (NSString*)brandName;


@end
