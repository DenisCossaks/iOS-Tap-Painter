//
//  TPSavedColors.m
//  Tappainter
//
//  Created by Vadim on 11/9/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import "TPSavedColors.h"
#import "TPColor.h"
#import "TPAppDefs.h"

#define SAVED_COLORS_KEY @"SavedColors"
#define TPCOLOR_KEY @"TPColorKey"

static TPSavedColors* instance;

@interface TPSavedColors() {
//    NSMutableArray* savedColorKeys_;
    NSMutableArray* savedColors_;
}

@property NSArray* savedColors;

@end

@implementation TPSavedColors

@synthesize savedColors=savedColors_;

- (id)init {
    self = [super init];
    if (self) {
        [self loadSavedColors];
    }
    
    return self;
}

+ (TPSavedColors*)instance {
    if (!instance) {
        instance = [[TPSavedColors alloc] init];
    }
    return instance;
}

+ (NSArray*)savedColors {
    return [TPSavedColors instance].savedColors;
}

+ (NSArray*)colorsWithCodesRevealed {
    NSArray* allColors = [TPSavedColors instance].savedColors;
    NSMutableArray* colorsRevealed = [NSMutableArray array];
    for (TPColor* tpColor in allColors) {
        if (tpColor.purchased) {
            [colorsRevealed addObject:tpColor];
        }
    }
    return  colorsRevealed;
}


- (void)loadSavedColors {
    NSArray* savedColorsArray = [[NSUserDefaults standardUserDefaults] objectForKey:SAVED_COLORS_KEY];
    NSLog(@"Load Colors: %@", savedColorsArray);
    if (savedColorsArray) {
        savedColors_ = [NSMutableArray array];
        for (NSString* serializeKey in savedColorsArray) {
            [savedColors_ addObject:[[TPColor alloc] initWithSerializeKey:serializeKey]];
        }
    } else {
        savedColors_ = [NSMutableArray array];
    }
}

- (void)serialize {
    NSMutableArray* savedColorsArray = [NSMutableArray array];
    for (TPColor* tpColor in savedColors_) {
        [savedColorsArray addObject:[tpColor serializeKey]];
    }
    NSLog(@"Save Colors: %@", savedColorsArray);
    [[NSUserDefaults standardUserDefaults] setObject:savedColorsArray forKey:SAVED_COLORS_KEY];
}

- (void)saveColor:(TPColor*)tpColor {
    if (![savedColors_ containsObject:tpColor] && ![self existingColor:tpColor]) {
        [savedColors_ insertObject:tpColor atIndex:0];
        [self serialize];
        [[NSNotificationCenter defaultCenter] postNotificationName:COLOR_ADDED object:tpColor];
    }
}

- (bool)existingColor:(TPColor*)newTpColor {
    for (TPColor* tpColor in savedColors_) {
        if (tpColor.swatchData.brandId == newTpColor.swatchData.brandId && [tpColor.swatchData.code isEqualToString:newTpColor.swatchData.code]) {
            return YES;
        }
    }
    return NO;
}

- (void)deleteColor:(TPColor *)tpColor {
    [savedColors_ removeObject:tpColor];
    [self serialize];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


+ (void)saveColor:(TPColor *)tpColor {
    [[TPSavedColors instance] saveColor:tpColor];
    
}

+ (void)deleteColor:(TPColor *)tpColor {
    [[TPSavedColors instance] deleteColor:tpColor];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:COLOR_DELETED object:tpColor];

}

+ (TPColor*)tpColorForKey:(NSString *)key {
    for (TPColor* tpColor in [TPSavedColors savedColors]) {
        if ([tpColor.serializeKey isEqualToString:key]) {
            return tpColor;
        }
    }
    return nil;
}

@end
