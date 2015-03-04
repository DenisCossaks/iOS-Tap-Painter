//
//  TPPin.m
//  Tappainter
//
//  Created by Vadim on 9/17/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import "TPPin.h"
#import "Defs.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor-Expanded.h"
#import "UtilityCategories.h"
#import "TPColor.h"
#import "TPImageView.h"

#define TPCOLOR_KEY @"TPColor"
#define COLOR_FIXED_FLAG_KEY @"ColorFixed"
#define COORD_X_KEY @"x"
#define COORD_Y_KEY @"y"

@interface TPPin () {
    
    __weak IBOutlet UIView *backGroundView_;
    __weak IBOutlet UIView *borderView_;
    __weak UILabel* tipPlaceholder_;
    
    CGPoint touchBeginLocation_;
    UIColor* RGBColor_;
}

@property __weak IBOutlet UILabel *tipPlaceholder;

@end

@implementation TPPin

//@synthesize colorWasSet=colorFixed_;
@synthesize position=_position;
@synthesize tipPlaceholder=tipPlaceholder_;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _marginToEdge = 30;
    self.view.layer.masksToBounds = NO;
    backGroundView_.layer.cornerRadius = backGroundView_.frame.size.width/2;
    backGroundView_.layer.borderWidth = 4.0;
    backGroundView_.layer.borderColor = [UIColor colorWithRed:49.0/255.0 green:49.0/255.0 blue:49.0/255.0 alpha:1].CGColor;
    borderView_.layer.cornerRadius = borderView_.frame.size.width/2;
    if (RGBColor_) {
        backGroundView_.backgroundColor = RGBColor_;
    } else {
        RGBColor_ = backGroundView_.backgroundColor;
    }
}

+ (TPPin*)pinWithPin:(TPPin *)pin {
    TPPin* newPin = [[TPPin alloc] init];
    newPin.position = pin.position;
    newPin.tpColor = pin.tpColor;
    return newPin;
}

- (UIImageView*)parentImageView {
    UIImageView* parentView = (UIImageView*)self.view.superview;
    NSAssert(parentView == nil || [parentView isKindOfClass:[UIImageView class]], @"Pin's parent view has to be of UIImageView class");
    return parentView;
 }

- (CGPoint)positionInImage {
    return [self.parentImageView positionInImage:_position];
}

- (void)setPosition:(CGPoint)position {
    _position = position;
    float tipPositionOffsetX = tipPlaceholder_.center.x - self.view.bounds.size.width/2;
    float tipPositionOffsetY = tipPlaceholder_.center.y - self.view.bounds.size.height/2;
    position.x -= tipPositionOffsetX;
    position.y -= tipPositionOffsetY;
    self.view.center = position;
    if (!_tpColor) {
        self.color = [self grabColorAtTip];
    }
}

- (CGPoint)tipPositionFromCenter:(CGPoint)center {
    CGPoint position = center;
    float tipPositionOffsetX = tipPlaceholder_.center.x - self.view.bounds.size.width/2;
    float tipPositionOffsetY = tipPlaceholder_.center.y - self.view.bounds.size.height/2;
    position.x += tipPositionOffsetX;
    position.y += tipPositionOffsetY;
    return position;
}

- (UIColor*) grabColorAtTip {
    TPImageView* parentImageView = (TPImageView*)self.view.superview;
    if (parentImageView) {
        CGPoint tipPosition = [parentImageView convertPoint:tipPlaceholder_.center fromView:self.view];
        return [parentImageView.image getPixelColorAtLocation:[parentImageView positionInImage:tipPosition]];
    }
    
    return nil;
}

- (void) reset {
    _tpColor = nil;
    [self grabColorAtTip];
}

- (void) removeFromSuperview {
    [self.view removeFromSuperview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setColor:(UIColor *)color {
    if (!_tpColor) {
        backGroundView_.backgroundColor = color;
        RGBColor_ = color;
    }
}

- (UIColor*)color {
    return RGBColor_;
}

- (void)forceSetColor:(UIColor *)color {
    backGroundView_.backgroundColor = color;
    RGBColor_ = color;
    borderView_.backgroundColor = color;
}

- (void)setTpColor:(TPColor *)tpColor {
    _tpColor = tpColor;
    [self applyTpColor:tpColor];
}

- (void)setTpColorFromSearch:(TPColor *)tpColorFromSearch {
    _tpColorFromSearch = tpColorFromSearch;
    if (_tpColorFromSearch) {
        [self applyTpColor:tpColorFromSearch];
    }
}

- (void)applyTpColor:(TPColor*)tpColor {
    backGroundView_.backgroundColor = tpColor.color;
    RGBColor_ = tpColor.color;
    borderView_.hidden = NO;
    borderView_.backgroundColor = tpColor.color;
//    _colorChanged = YES;
}

- (void)restoreColor {
    if (_tpColor) {
        [self forceSetColor:_tpColor.color];
    } else {
        borderView_.hidden = YES;
        [self forceSetColor:[self grabColorAtTip]];
    }
}

- (void)setCenter:(CGPoint)center {
    self.view.center = center;
    if (!_tpColor) {
        self.color = [self grabColorAtTip];
    }
    _position = [self tipPositionFromCenter:center];
}

- (CGPoint)center {
    return self.view.center;
}


- (void)dealloc {
    [self.view removeFromSuperview];
}


#pragma mark -
#pragma mark Touch Event Functions

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"TPPin: touchesBegan");
    UITouch* touch = [touches anyObject];
    touchBeginLocation_ = [touch locationInView:self.view.superview];
    if (_delegate)
        [_delegate pinStartedDragging:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.view.superview];
    
    TPImageView* parentImageView = (TPImageView*)self.view.superview;
    float leftMargin = _marginToEdge + parentImageView.contentFrame.origin.x;
    
    
    CGRect safeAreaRect = CGRectInset(self.view.superview.bounds, leftMargin, _marginToEdge);
    // Don't move beyond screen, otherwise we'll lose it
    location.x =    location.x < safeAreaRect.origin.x ? safeAreaRect.origin.x :
    location.x > safeAreaRect.origin.x + safeAreaRect.size.width ? safeAreaRect.origin.x + safeAreaRect.size.width :
    location.x;
    location.y =    location.y < safeAreaRect.origin.y ? safeAreaRect.origin.y :
    location.y > safeAreaRect.origin.y + safeAreaRect.size.height ? safeAreaRect.origin.y + safeAreaRect.size.height :
    location.y;
    
    CGPoint center = self.view.center;
    center.x += location.x - touchBeginLocation_.x;
    center.y += location.y - touchBeginLocation_.y;
    self.position = [self tipPositionFromCenter:center];
    touchBeginLocation_ = location;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"TPPin: touchesEnded");
    [self touchesMoved:touches withEvent:event];
    if (_delegate) {
        [_delegate pinStoppedDragging:self];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"TPPin: touchesCancelled");
    if (_delegate) {
        [_delegate pinStoppedDragging:self];
    }
}

@end
