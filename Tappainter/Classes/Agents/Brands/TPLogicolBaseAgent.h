//
//  TPLogicolBaseAgent.h
//  Tappainter
//
//  Created by Vadim on 1/8/14.
//  Copyright (c) 2014 MDi Touch. All rights reserved.
//

#import "TPBrandAgent.h"

@interface TPLogicolBaseAgent : TPBrandAgent

+ (TPPageData*)pageDataFromPageDataArray:(NSArray*) array;
+ (void)getBrandsListwithCompletionBlock:(void (^)(NSArray* brandsList))block;

@end
