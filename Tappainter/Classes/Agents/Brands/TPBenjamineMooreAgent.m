//
//  TPBenjamineMooreAgent.m
//  Tappainter
//
//  Created by Vadim on 11/10/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import "TPBenjamineMooreAgent.h"
#import "TPBrandData.h"

@implementation TPBenjamineMooreAgent

+ (NSString*)brandName {
    return @"Benjamin Moore Classic Colors";
}

+ (TPPageData*)pageDataFromPageDataArray:(NSArray*) array {
    NSMutableArray* swatches = [NSMutableArray array];
    for (NSDictionary* colorData in array) {
        TPSwatchData* swatchData = [[TPSwatchData alloc] init];
        int red = [[colorData valueForKey:@"r"] intValue];
        int blue = [[colorData valueForKey:@"b"] intValue];
        int green = [[colorData valueForKey:@"g"] intValue];
        swatchData.color = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
        NSArray* components = [[colorData objectForKey:@"name"] componentsSeparatedByString:@" "];
        swatchData.code = components[0];
        swatchData.name = components[1];
        swatchData.brandId = ktpBrandsBenjaminMoore;
        [swatches addObject:swatchData];
    }
    TPPageData* pageData = [[TPPageData alloc] init];
    pageData.brandId = ktpBrandsBenjaminMoore;
    pageData.swatches = swatches;
    return pageData;
}



@end
