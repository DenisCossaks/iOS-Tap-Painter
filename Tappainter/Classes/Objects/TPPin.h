//
//  TPPin.h
//  Tappainter
//
//  Created by Vadim on 9/17/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TPPin;
@class TPColor;
@protocol TPPinDelegate <NSObject>

- (void)pinStartedDragging:(TPPin*)pin;
- (void)pinStoppedDragging:(TPPin*)pin;
//- (void)pinTapped:(TPPin*)pin;

@end

@interface TPPin : UIViewController 

@property (nonatomic) CGPoint position;
@property (nonatomic, readonly) UIColor* color;
@property (nonatomic) TPColor* tpColor;
@property (nonatomic) TPColor* tpColorFromSearch;
@property (nonatomic) CGPoint center;
@property __weak id<TPPinDelegate> delegate;
@property (nonatomic, readonly) UIImageView* parentImageView;
@property (nonatomic, readonly) CGPoint positionInImage;
@property float marginToEdge;
@property bool colorChanged;

+ (TPPin*)pinWithPin:(TPPin*)pin;
- (void) removeFromSuperview;
- (void) forceSetColor:(UIColor*)color;
- (void) restoreColor;
- (void) reset;

@end
