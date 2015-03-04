//
//  TPBrandData.m
//  Tappainter
//
//  Created by Vadim on 11/10/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//


#import "TPBrandData.h"
#import "UIColor-Expanded.h"
#import "TPAppDefs.h"

@implementation TPBrandData

- (id)initWithName:(NSString *)brandName andID:(NSInteger)brandID {
    self = [self init];
    if (self) {
        _status = ktpBrandDataStatusDownloading;
        _brandId = brandID;
        _name = brandName;
        NSArray* pagesArray;
        id value = [[NSUserDefaults standardUserDefaults] valueForKey:@"UpdatedForV1.1"];
        if (value) {
            pagesArray = [[NSUserDefaults standardUserDefaults] objectForKey:brandName];
        }
        _unlocked = [[NSUserDefaults standardUserDefaults] boolForKey:[self unlockKey]];
        if (pagesArray) {
            //        NSLog(@"pages Array: %@", pagesArray);
            if (pagesArray.count) {
                [self loadBrandDatafromPagesArrays:pagesArray];
            }
            if (self.pages.count) {
                self.status = ktpBrandDataStatusInitialized;
            } else {
                [self downloadBrandData];
            }
        } else {
            [self downloadBrandData];
        }
    }
    return self;
}

- (void)downloadBrandData {
    [self downloadBrandDataWithCompletionBlock:^(NSArray *pagesArray) {
        [self loadBrandDatafromPagesArrays:pagesArray];
        if (!_pages.count) {
            self.status = ktpBrandDataStatusError;
        } else {
            self.status = ktpBrandDataStatusInitialized;
            [[NSUserDefaults standardUserDefaults] setObject:pagesArray forKey:_name];
        }
        [[NSUserDefaults standardUserDefaults] setValue:@"Yes" forKey:@"UpdatedForV1.1"];
    }];
}

- (void)downloadBrandDataWithCompletionBlock:(void (^)(NSArray *))block {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString* urlString = [self buidURLWithBrandParameterAndParams:@"P=ALL"]; //[self attachBrandParameterToURL: @"http://fastrgb.com/api_test/?P=ALL"];
    NSLog(@"URL string: %@", urlString);
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            NSLog(@"brand dowload error: %@", connectionError.description);
        } else {
            NSString* JSONString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            NSLog(@"JSON String: %@", JSONString);
            JSONString = [JSONString stringByReplacingOccurrencesOfString:@"<pre>" withString:@""];
            JSONString = [JSONString stringByReplacingOccurrencesOfString:@"</pre>" withString:@""];
            NSMutableArray* structuredPagesArray = [NSMutableArray array];
            if (JSONString) {
                @try {
                    NSArray* allPagesArray = [NSJSONSerialization JSONObjectWithData:[JSONString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
                    int currentPageNumber = 1;
                    NSMutableArray* colorsArray = [NSMutableArray array];
                    for (NSDictionary* dict in allPagesArray) {
                        int pageNamber = [[dict valueForKey:@"page"] intValue];
                        if (pageNamber != currentPageNumber) {
                            [structuredPagesArray addObject:colorsArray];
                            currentPageNumber = pageNamber;
                            colorsArray = [NSMutableArray array];
                        }
                        [colorsArray addObject:dict];
                    }
                    [structuredPagesArray addObject:colorsArray];
                }
                @catch (NSException *exception) {
                }
                @finally {
                }
            }
            block(structuredPagesArray);
            
        }
    }];
}

- (NSString*)unlockKey {
    return [NSString stringWithFormat:@"%@_unlocked", self.name];
}

- (void)setUnlocked:(bool)unlocked {
    [[NSUserDefaults standardUserDefaults] setBool:unlocked forKey:[self unlockKey]];
    _unlocked = unlocked;
}

- (NSString*)buidURLWithBrandParameterAndParams:(NSString*)paramString {
    NSString* urlString = [NSString stringWithFormat:@"%@?%@", COLOR_SERVER_URL, paramString];
    return [self attachBrandParameterToURL:urlString];
}


- (NSString*)attachBrandParameterToURL:(NSString*)urlString {
    return [NSString stringWithFormat:@"%@&L=%@", urlString, [_name stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
}


- (void)loadBrandDatafromPagesArrays:(NSArray *)pagesArray {
    NSMutableArray* pages = [NSMutableArray array];
    for (NSArray* pageDataArray in pagesArray) {
        TPPageData* pageData = [self pageDataFromPageDataArray:pageDataArray];
        if (pageData.swatches.count) {
            [pages addObject: pageData];
        }
    }
    
    _pages = pages;
}

- (TPPageData*)pageDataFromPageDataArray:(NSArray*) array {
    NSMutableArray* swatches = [NSMutableArray array];
    for (NSDictionary* colorData in array) {
//        NSLog(@"Color data:%@ for brand:%@", colorData, _name);
        TPSwatchData* swatchData = [[TPSwatchData alloc] init];
        int red = [[colorData valueForKey:@"r"] intValue];
        int blue = [[colorData valueForKey:@"b"] intValue];
        int green = [[colorData valueForKey:@"g"] intValue];
        swatchData.color = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
        [self parseColorName:[colorData objectForKey:@"name"] intoSwatchData:swatchData];
        _codePrefix = swatchData.codePrefix;
        swatchData.brandId = _brandId;
        [swatches addObject:swatchData];
    }
    TPPageData* pageData = [[TPPageData alloc] init];
    pageData.brandId = _brandId;
    pageData.swatches = swatches;
    return pageData;
}

- (void)parseColorName:(NSString*)name intoSwatchData:(TPSwatchData*)swatchData {
    /*
    NSArray* components = [name componentsSeparatedByString:@" "];
    if ([components[0] isEqualToString:@"SW"]) {
        swatchData.codePrefix = components[0];
        swatchData.code = components[1];
        swatchData.name = components[2];
        for (int i = 3; i < components.count; i++) {
            swatchData.name = [NSString stringWithFormat:@"%@ %@", swatchData.name, components[i]];
        }
    } else {
        NSRange range = [components[0] rangeOfString:@"-"];
        if (range.location != NSNotFound) {
            swatchData.codePrefix = [components[0] substringToIndex:range.location+1];
            swatchData.code = [components[0] substringFromIndex:range.location+1];
        } else {
            swatchData.code = components[0];
        }
        swatchData.name = components[1];
        for (int i = 2; i < components.count; i++) {
            swatchData.name = [NSString stringWithFormat:@"%@ %@", swatchData.name, components[i]];
        }
    }
     */
    swatchData.name = name;
    swatchData.code = name; // Turns out the code and the name are inseparable, so just make them equal
    swatchData.codePrefix = nil;
}

- (void)convertColor:(UIColor *)color withCompletionBlock:(void (^)(TPPageData *, NSString*))block {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString* paramString = [NSString stringWithFormat:@"R=%d&G=%d&B=%d", (int)(color.red*255), (int)(color.green*255), (int)(color.blue*255)];
    NSString* urlString = [self buidURLWithBrandParameterAndParams:paramString]; // [NSString stringWithFormat:@"http://fastrgb.com/api_test/?R=%d&G=%d&B=%d", (int)(color.red*255), (int)(color.green*255), (int)(color.blue*255)];
    //    urlString = [self attachBrandParameterToURL:urlString];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            NSLog(@"SherwinWilliamsAgent: color matching error: %@", connectionError.description);
        } else {
            NSString* JSONString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            JSONString = [JSONString stringByReplacingOccurrencesOfString:@"<pre>" withString:@""];
            JSONString = [JSONString stringByReplacingOccurrencesOfString:@"</pre>" withString:@""];
            NSArray* colorsArray = [NSJSONSerialization JSONObjectWithData:[JSONString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
            //            NSLog(@"Colors array: %@", colorsArray);
            TPPageData* pageData = [self pageDataFromPageDataArray:colorsArray];
            block(pageData, nil);
        }
    }];
}

- (TPPageData*)lookUpCode:(NSString *)code {
    for (TPPageData* pageData in _pages) {
        for (TPSwatchData* swatchData in pageData.swatches) {
            NSLog(@"Code in library: %@ Code to compare: %@", swatchData.code, code);
            if ([swatchData.code isEqualToString:code]) {
                pageData.selectedSwatch = (int)[pageData.swatches indexOfObject:swatchData];
                return pageData;
            }
        }
    }
    return nil;
}

- (void)setBrandId:(NSInteger)brandId {
    _brandId = brandId;
    for (TPPageData* pageData in _pages) {
        pageData.brandId = brandId;
    }
}

- (NSArray*)matchingNames:(NSString *)substring {
    NSMutableArray* matches = [NSMutableArray array];
    for (TPPageData* pageData in _pages) {
        for (TPSwatchData* swatchData in pageData.swatches) {
            NSLog(@"Code in library: %@ Serach term: %@", swatchData.code, substring);
            NSRange range = [swatchData.code rangeOfString:substring options:NSCaseInsensitiveSearch];
            if (range.location != NSNotFound) {
                [matches addObject:swatchData.code];
            }
            if (_abortSearch) return nil;
        }
    }
    return matches;
}

@end

@implementation TPPageData

- (id)init {
    self = [super init];
    if (self) {
        _selectedSwatch = -1;
    }
    
    return self;
}

- (void)setBrandId:(NSInteger)brandId {
    _brandId = brandId;
    for (TPSwatchData* swatchData in _swatches) {
        swatchData.brandId = brandId;
    }
}

- (UIColor*)averageColor {
    float redTotal = 0.0;
    float blueTotal = 0.0;
    float greenTotal = 0.0;
    for (TPSwatchData* swatchData in _swatches) {
        redTotal += swatchData.color.red;
        blueTotal += swatchData.color.blue;
        greenTotal += swatchData.color.green;
    }
    
    return [UIColor colorWithRed:redTotal/_swatches.count green:greenTotal/_swatches.count blue:blueTotal/_swatches.count alpha:1];
}

@end

#define BRAND_ID_KEY @"BrandId"
#define COLOR_KEY @"Color"
#define CODE_KEY @"Code"
#define NAME_KEY @"Name"
#define CODE_PREFIX_KEY @"CodePrefix"

@implementation TPSwatchData

+ (TPSwatchData*)swatchDataFromDictionary:(NSDictionary *)dict {
    TPSwatchData* swatchData = [[TPSwatchData alloc] init];
    swatchData.brandId = [[dict objectForKey:BRAND_ID_KEY] integerValue];
    swatchData.name = [dict objectForKey:NAME_KEY];
    swatchData.code = [dict objectForKey:CODE_KEY];
    swatchData.color = [UIColor colorWithString:[dict objectForKey:COLOR_KEY]];
    swatchData.codePrefix = [dict objectForKey:CODE_PREFIX_KEY];
    return  swatchData;
}

- (NSDictionary*)convertToDictionary {
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInteger:_brandId], BRAND_ID_KEY,
                          _name, NAME_KEY,
                          _code, CODE_KEY,
                          _color.stringFromColor, COLOR_KEY,
                          _codePrefix, CODE_PREFIX_KEY,
                          nil];
    return dict;
}

@end