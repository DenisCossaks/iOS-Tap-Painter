//
//  TPSavedColors.h
//  Tappainter
//
//  Created by Vadim on 11/9/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TPColor;
@interface TPSavedColors : NSObject

@property (readonly) NSArray* savedColors;

+ (NSArray*)savedColors;
+ (NSArray*)colorsWithCodesRevealed;
+ (void)saveColor:(TPColor*)tpColor;
+ (void)deleteColor:(TPColor*)tpColor;
+ (TPColor*)tpColorForKey:(NSString*)key;

@end
