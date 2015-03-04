//
//  TPBrandsManager.m
//  Tappainter
//
//  Created by Vadim on 11/9/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import "TPBrandsManager.h"
#import "TPSherwinWilliamsAgent.h"
#import "TPBenjamineMooreAgent.h"
#import "TPAppDefs.h"
#import "UtilityCategories.h"

#define BRAND_NAMES_KEY @"BrandNames"
#define CURRENT_BRAND_KEY @"CurrentBrand"
#define UNLOCKED_BRANDS_KEY @"UnlockedBrands"

static TPBrandsManager* instance;

@interface TPBrandsManager() {
    NSMutableArray* brandNames_;
    NSMutableArray* brandsData_;
    NSArray* featuredBrands_;
}

@property (readonly) NSArray* allBrands;
@property (readonly) NSArray* featuredBrands;
@property (nonatomic) NSInteger currentBrand;
@property (nonatomic) int unlockedBrands;

@end

@implementation TPBrandsManager

@synthesize allBrands=brandsData_;
@synthesize featuredBrands=featuredBrands_;

- (id)init {
    self = [super init];
    if (self) {
//        _currentBrand = 1;
        if ([self firstRunForV1_5]) {
            [self setCurrentBrand:0];
        }
        _unlockedBrands = [[NSUserDefaults standardUserDefaults] integerForKey:UNLOCKED_BRANDS_KEY];
        NSLog(@"Unlocked brands initialized: %d", _unlockedBrands);
        brandNames_ = [[[NSUserDefaults standardUserDefaults] objectForKey:BRAND_NAMES_KEY] mutableCopy];
        if (brandNames_) {
            [self loadBrandsData];
        } 
        if (!brandNames_) {
           brandNames_ = [NSMutableArray arrayWithArray:@[@"Webcolor"]];
        }
        if (!brandsData_) {
            brandsData_ = [NSMutableArray array];
        }
        // Now update from web in case there are new brands there
        if ([self checkInternetConnectionWithErrorAlert:NO]) {
            [self updateBrands];
        }
    }
    
    return self;
}

- (NSString*)brandNameForId:(NSInteger)brandId {
    if (brandId >= brandNames_.count) {
        return nil;
    }
    return brandNames_[brandId];
}

- (void)setCurrentBrand:(NSInteger)currentBrand {
    _currentBrand = currentBrand;
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:currentBrand] forKey:CURRENT_BRAND_KEY];
}

- (void)setUnlockedBrands:(int)unlockedBrands {
    _unlockedBrands = unlockedBrands;
    [[NSUserDefaults standardUserDefaults] setInteger:_unlockedBrands forKey:UNLOCKED_BRANDS_KEY];
    NSLog(@"Unlocked brands saved: %d", _unlockedBrands);
}

- (void)unlockBrand:(NSInteger)brandId {
    TPBrandData* brandData = [self brandDataForId:brandId];
    if (!brandData.unlocked) {
        brandData.unlocked = YES;
        self.unlockedBrands = self.unlockedBrands + 1;
    }
}

+ (int)brandsUnlocked {
    return [TPBrandsManager shardeInstance].unlockedBrands;
}

+ (void)unlockBrand:(NSInteger)brandId {
    [[TPBrandsManager shardeInstance] unlockBrand:brandId];
}

+ (TPBrandsManager*)shardeInstance {
    if (!instance) {
        instance = [[TPBrandsManager alloc] init];
    }
    
    return instance;
}

+ (NSString*)brandNameForId:(NSInteger)brandId {
    return [[TPBrandsManager shardeInstance] brandNameForId:brandId];
}

- (void)loadBrandsData {
    _currentBrand = [[[NSUserDefaults standardUserDefaults] valueForKey:CURRENT_BRAND_KEY] integerValue];
//    if (_currentBrand == 0)
//        _currentBrand = 1;
    brandsData_ = [NSMutableArray arrayWithCapacity:brandNames_.count-1];
    for (int i = 1; i < brandNames_.count; i++) {
        TPBrandData* brandData = [self loadBrandDataForBrandID:i];
        [brandsData_ addObject:brandData];
    }
}

- (TPBrandData*)loadBrandDataForBrandID:(NSInteger)brandID {
    TPBrandData* brandData = [[TPBrandData alloc] initWithName:[self brandNameForId:brandID] andID:brandID];
    return brandData;
}

- (TPBrandData*)brandDataForId:(NSInteger)brandId {
    if (brandId <= brandsData_.count)
        return brandsData_[brandId-1];
    else
        return  nil;
}

#define BRANDS_V_1_5_KEY @"BrandsManager_Update1.5"

- (bool)firstRunForV1_5 {
    id value = [[NSUserDefaults standardUserDefaults] objectForKey:BRANDS_V_1_5_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:BRANDS_V_1_5_KEY];
    return value == nil;
}


+ (TPBrandData*)brandDataForId:(NSInteger)brandId {
    return [[TPBrandsManager shardeInstance] brandDataForId:brandId];
}

+ (void)convertColor:(UIColor*)color withCompletionBlock:(void (^)(TPPageData * pageData, NSString* error))block {
    [[self brandDataForId:[self currentBrand]] convertColor:color withCompletionBlock:block];
}

+ (NSArray*)allBrands {
    NSMutableArray* allBrands = [NSMutableArray arrayWithArray:[TPBrandsManager shardeInstance].allBrands];
    return [self sortedBrandsArrayFromArray:allBrands];
}

+ (NSArray*)featuredBrands {
    return [TPBrandsManager shardeInstance].featuredBrands;
}

+ (NSArray*)unlockedBrands {
    NSMutableArray* array = [NSMutableArray array];
    for (TPBrandData* brandData in [TPBrandsManager allBrands]) {
        if (brandData.unlocked) {
            [array addObject:brandData];
        }
    }
    return [self sortedBrandsArrayFromArray:array];
}

+ (NSArray*)lockedBrands {
    NSMutableArray* array = [NSMutableArray array];
    for (TPBrandData* brandData in [TPBrandsManager allBrands]) {
        if (!brandData.unlocked) {
            [array addObject:brandData];
        }
    }
    return [self sortedBrandsArrayFromArray:array];
}

+ (NSMutableArray*)sortedBrandsArrayFromArray:(NSMutableArray*)brandsArray {
    [brandsArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        TPBrandData* brand1 = obj1;
        TPBrandData* brand2 = obj2;
        return [brand1.name compare:brand2.name];
    }];
    return brandsArray;
}

+ (NSInteger)currentBrand {
    return [TPBrandsManager shardeInstance].currentBrand;
}

+ (TPBrandData*)currentBrandData {
    if ([self currentBrand] == 0) return nil;
    return [self brandDataForId:[self currentBrand]];
}

+ (void)setCurrentBrand:(NSInteger)brandId {
    [TPBrandsManager shardeInstance].currentBrand = brandId;
}

+ (void)lookUpCode:(NSString *)code withCompletionBlock:(void (^)(TPPageData *, NSString *))block {
    TPBrandData* brandData = [self currentBrandData];
    TPPageData* pageData = [brandData lookUpCode:code];
    if (pageData)
        block(pageData, nil);
    else
        block(pageData, @"Color code not found");
}

- (void)updateBrands {
    NSMutableArray* brandsList = [NSMutableArray array];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString* urlString = [NSString stringWithFormat:@"%@?L=LIST", COLOR_SERVER_URL];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            NSLog(@"Error getting brands list: %@", connectionError.description);
        } else {
            NSString* JSONString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            JSONString = [JSONString stringByReplacingOccurrencesOfString:@"<pre>" withString:@""];
            JSONString = [JSONString stringByReplacingOccurrencesOfString:@"</pre>" withString:@""];
            NSArray* responseArray = [NSJSONSerialization JSONObjectWithData:[JSONString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
            NSLog(@"Brands on sever: %@", responseArray);
            for (NSDictionary* brndDict in responseArray) {
                [brandsList addObject:[brndDict objectForKey:@"name"]];
            }
            if (brandsList) {
                NSMutableArray* downloadedBrands = [NSMutableArray arrayWithArray:@[@"Webcolor"]];
                [downloadedBrands addObjectsFromArray:brandsList];
                if (![downloadedBrands isEqualToArray:brandNames_]) {
                    bool updated = NO;
                    for (NSString* brandName in downloadedBrands) {
                        if (![brandNames_ containsObject:brandName]) {
                            [brandNames_ addObject:brandName];
                            TPBrandData* brandData = [self loadBrandDataForBrandID:[brandNames_ indexOfObject:brandName]];
                                [brandsData_ addObject:brandData];
                                updated = YES;
                        }
                    }
                    if (updated) {
                        [[NSUserDefaults standardUserDefaults] setObject:brandNames_ forKey:BRAND_NAMES_KEY];
                        [[NSNotificationCenter defaultCenter] postNotificationName:BRANDS_UPDATED object:nil];
                    }
                }
            }
        }
    }];
}

@end
