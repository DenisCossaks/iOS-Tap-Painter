//
//  TPColor.m
//  Tappainter
//
//  Created by Vadim on 11/9/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import "TPColor.h"
#import "TPBrandData.h"
#import "UIColor-Expanded.h"
#import "UtilityCategories.h"

#define COLOR_STRING_KEY @"ColorString"
#define SWATCH_DATA_KEY @"SwatchData"
#define PURCHASED_KEY   @"PurchasedKey"
#define SERIALIZE_KEY_KEY @"SerializeKey"

@interface TPColor() {
}
@end

@implementation TPColor

- (id)init
{
    self = [super init];
    if (self) {
        _serializeKey = [self generateGUID];
        [self serialize];
    }
    return self;
}

- (id)initWithWebColor:(UIColor *)color {
    self = [self init];
    if (self) {
        _color = color;
        [self serialize];
    }
    return  self;
}

- (id)initWithSwatchData:(TPSwatchData *)swatchData {
    self = [self init];
    if (self) {
        _color = swatchData.color;
        _swatchData = swatchData;
        [self serialize];
    }
    return  self;
}

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        NSString* colorString = [dict valueForKey:COLOR_STRING_KEY];
        _color = [UIColor colorWithString:colorString];
        NSDictionary* swatchDataDict = [dict objectForKey:SWATCH_DATA_KEY];
        if (swatchDataDict) {
            _swatchData = [TPSwatchData swatchDataFromDictionary:swatchDataDict];
            _purchased = [[dict valueForKey:PURCHASED_KEY] boolValue];
        }
    }
    return self;
}

- (id)initWithSerializeKey:(NSString *)serializeKey {
    NSDictionary* dict = [[NSUserDefaults standardUserDefaults] valueForKey:serializeKey];
    _serializeKey = serializeKey;
    return [self initWithDictionary:dict];
}

- (NSDictionary*)convertToDictionary {
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          _color.stringFromColor, COLOR_STRING_KEY,
                          [_swatchData convertToDictionary], SWATCH_DATA_KEY,
                          [NSNumber numberWithBool:_purchased], PURCHASED_KEY,
                          nil];
    return dict;
}

- (void)serialize {
    [[NSUserDefaults standardUserDefaults] setValue:[self convertToDictionary] forKey:_serializeKey];
}

- (void)setSwatchData:(TPSwatchData *)swatchData {
    _swatchData = swatchData;
    if (swatchData) {
        _color = swatchData.color;
    }
    [self serialize];
}

- (void)setPurchased:(bool)purchased {
    _purchased = purchased;
    [self serialize];
}

- (void)setColor:(UIColor *)color {
    _color = color;
    [self serialize];
}

@end
