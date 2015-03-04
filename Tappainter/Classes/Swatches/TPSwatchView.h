//
//  TPSwatchView.h
//  Tappainter
//
//  Created by Vadim on 11/3/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TPColor;
@protocol TPSwatchViewDelegate <NSObject>

- (void)colorUsed:(TPColor*)tpColor;

@end

@class TPPin;
@class TPPageData;
@interface TPSwatchView : UIView

@property int numberOfColors;
@property TPPin* colorMarker;
@property CATransform3D transformInCarousel;
@property CGRect originalFrame;
@property CGRect frameInCarousel;
@property float hue;
@property (nonatomic) TPPageData* pageData;
@property __weak id<TPSwatchViewDelegate> delegate;
@property bool launchedFromSearch;

- (id)initWithHue:(float)hue;
- (id)initWithHue:(float)hue andNumberOfColors:(int)numberOfColors;
- (id)initWithPageData:(TPPageData*)pageData;
- (void)updateForHue:(float)hue;
- (void)enableSelection:(bool)enable;

@end
