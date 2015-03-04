//
//  TPBrandAgent.m
//  Tappainter
//
//  Created by Vadim on 11/10/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import "TPBrandAgent.h"
#import "TPBrandData.h"

@implementation TPBrandAgent

+ (void)loadBrandDataFromKey:(NSString *)key intoBrandData:(TPBrandData *)brandData {
    brandData.status = ktpBrandDataStatusDownloading;
    NSArray* pagesArray = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (pagesArray) {
//        NSLog(@"pages Array: %@", pagesArray);
        [self loadBrandData:brandData fromPagesArrays:pagesArray];
        brandData.status = ktpBrandDataStatusInitialized;
    } else {
        [self downloadBrandDataWithCompletionBlock:^(NSArray *pagesArray) {
            [[NSUserDefaults standardUserDefaults] setObject:pagesArray forKey:key];
            [self loadBrandData:brandData fromPagesArrays:pagesArray];
            brandData.status = ktpBrandDataStatusInitialized;
        }];
    }
}

// Has to be overridden
+ (void)loadBrandData:(TPBrandData*)brandData fromPagesArrays:(NSArray*)pagesArray {
}

// Has to be overridden
+ (void)downloadBrandDataWithCompletionBlock:(void (^)(NSArray *))block {
    block(nil);
}

// Has to be overridden
+ (void)convertColor:(UIColor *)color withCompletionBlock:(void (^)(TPPageData *, NSString*))block {
    block(nil, @"Color matching for this brand is coming soon");
}

+ (NSString*)brandName {
    return nil;
}

@end
