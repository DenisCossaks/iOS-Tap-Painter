//
//  TPColor.h
//  Tappainter
//
//  Created by Vadim on 11/9/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPBrandsManager.h"

@class TPSwatchData;
@interface TPColor : NSObject

@property (nonatomic) UIColor* color;
@property (nonatomic) TPSwatchData* swatchData;
@property (nonatomic) NSString* serializeKey;
@property (nonatomic) bool purchased;

- (id)initWithWebColor:(UIColor*)color;
- (id)initWithSwatchData:(TPSwatchData*)swatchData;
- (id)initWithSerializeKey:(NSString*)serializeKey;
//- (id)initWithDictionary:(NSDictionary*)dict;
//- (NSDictionary*)convertToDictionary;

@end
