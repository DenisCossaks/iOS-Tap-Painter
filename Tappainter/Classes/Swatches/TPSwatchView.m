//
//  TPSwatchView.m
//  Tappainter
//
//  Created by Vadim on 11/3/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import "TPSwatchView.h"
#import "TPPin.h"
#import "TPAppDefs.h"
#import "TPColor.h"
#import "TPSavedColors.h"
#import "TPRoundedButton.h"
#import "Defs.h"
#import "TPBrandData.h"
#import "TPBrandsManager.h"
#import "UpgradeProductEngine.h"
#import "TPTutorialController.h"

#define MIN_BRIGHTNESS 0.4
#define MIN_SATURATION 0.4
#define NAME_LABEL_TAG 777

static NSMutableDictionary* brandLabelImages;

@interface TPSwatchView() {
    
    NSMutableArray* colorButtons;
    __weak IBOutlet UIButton* useButton_;
    bool selectionEnabled_;
    __weak IBOutlet UILabel *brandNameLabel_;
    __weak IBOutlet UIImageView *brandNameImageView_;
}

@end

@implementation TPSwatchView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        if (!brandLabelImages) {
            brandLabelImages = [NSMutableDictionary dictionary];
        }
    }
    
    return  self;
}

- (id)initWithHue:(float)hue andNumberOfColors:(int)numberOfColors
{
    self = [self initFromNib];
    if (self) {
        _numberOfColors = numberOfColors;
        [self createColorButtonsWithHue:hue];
    }
    return self;
}



- (id)initWithHue:(float)hue
{
    self = [self initFromNib];
    if (self) {
        [self createColorButtonsWithHue:hue];
    }
    return self;
}

- (id)initWithPageData:(TPPageData *)pageData {
    self = [self initFromNib];
    if (self) {
        self.pageData = pageData;
    }
    
    return self;
}


- (id)initFromNib {
    self = [[[NSBundle mainBundle] loadNibNamed:@"SwatchPage" owner:self options:nil] objectAtIndex:0];
    if (self) {
        _originalFrame = self.frame;
        [[NSNotificationCenter defaultCenter] addObserverForName:SLIDING_PANEL_WILL_CLOSE object:nil  queue:nil usingBlock:^(NSNotification *note) {
//            useButton_.hidden = YES;
        }];
    }
    
    return self;
}

- (void)createColorButtonsWithHue:(float)hue {
    // Initialization code
    // Randomize number of colors from 5 to 10
    if (!_numberOfColors) {
        _numberOfColors = 5+rand()%6;
    }
    colorButtons = [NSMutableArray arrayWithCapacity:0];
    _hue = hue;
    
    float colorStripHeight = brandNameImageView_.frame.origin.y/_numberOfColors;
    float saturationStep = (1-MIN_SATURATION)/_numberOfColors;
    float brightnessStep = (1-MIN_BRIGHTNESS)/_numberOfColors;
    for (int i = 0; i < _numberOfColors; i++) {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        // Make butons overlap a bit to avoid gaps when view is resized
        button.frame = CGRectMake(0, colorStripHeight*i-1, self.frame.size.width, colorStripHeight+2);
        button.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        UIColor* color = [UIColor colorWithHue:hue saturation:(1-saturationStep*i) brightness:(MIN_BRIGHTNESS+brightnessStep*i) alpha:1];
        button.backgroundColor = color;
        [button addTarget:self action:@selector(colorButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        button.enabled = NO;
        [colorButtons addObject:button];
        
    }
}

- (void)createColorButtonsWithPageData:(TPPageData*)pageData {
    _numberOfColors = (int)pageData.swatches.count;
    colorButtons = [NSMutableArray arrayWithCapacity:0];
    
    float colorStripHeight = brandNameImageView_.frame.origin.y/_numberOfColors;
    for (int i = 0; i < _numberOfColors; i++) {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        // Make butons overlap a bit to avoid gaps when view is resized
        button.frame = CGRectMake(0, colorStripHeight*i-1, self.frame.size.width, colorStripHeight+2);
        button.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        TPSwatchData* swatchData = pageData.swatches[i];
        UIColor* color = swatchData.color;
        button.backgroundColor = color;
        [button addTarget:self action:@selector(colorButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i;
        [self addSubview:button];
        button.enabled = NO;
        [colorButtons addObject:button];
//        if ([UpgradeProductEngine upgradeEngineSingleton].numberOfCredits == -1) {
            // Show names and codes for Unlimited package
            UILabel* nameCodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, colorStripHeight/2-10, self.frame.size.width-20, 18)];
            nameCodeLabel.tag = NAME_LABEL_TAG;
            nameCodeLabel.backgroundColor = [UIColor whiteColor];
            nameCodeLabel.textAlignment = NSTextAlignmentLeft;
            nameCodeLabel.textColor = [UIColor blackColor];
            nameCodeLabel.font = [UIFont systemFontOfSize:14];
            NSString* nameCodeString = [@" " stringByAppendingString:[swatchData.name substringToIndex:MIN(40, swatchData.name.length)]];
//            nameCodeString = [nameCodeString stringByAppendingString:@" "];
//            if (swatchData.codePrefix) {
//                nameCodeString  = [nameCodeString stringByAppendingString:swatchData.codePrefix];
//            }
//            nameCodeString = [nameCodeString stringByAppendingString:swatchData.code];
//            nameCodeString = [nameCodeString stringByAppendingString:@" "];
            
            nameCodeLabel.text = nameCodeString;
            [nameCodeLabel sizeToFit];
            [button addSubview:nameCodeLabel];
            nameCodeLabel.hidden = YES;
#if 1 //def TAPPAINTER_PRO
            if (i == 0) nameCodeLabel.hidden = NO;
#endif
//        }
    }
}

- (void)layoutSubviews {
    if (_pageData.selectedSwatch != -1 && selectionEnabled_) {
        [self placeUseButtonOnColorButton:colorButtons[_pageData.selectedSwatch]];
    }
}

- (void)setPageData:(TPPageData *)pageData {
    _pageData = pageData;
    [brandNameImageView_ setImage:nil];
//    logoImageView_.image = [TPBrandsManager brandLogoForId:pageData.brandId];
    NSString* brandName = [TPBrandsManager brandNameForId:pageData.brandId];
    UIImage* image = [brandLabelImages valueForKey:brandName];
    if (!image) {
        NSLog(@"REndering label");
        // Generate an image from label to make sure it scales properly when swatch transformed in and out of deck
        brandNameLabel_.text = brandName;
        brandNameLabel_.hidden = NO;
        UIGraphicsBeginImageContextWithOptions(brandNameLabel_.frame.size, NO, 0.0f);
        [[brandNameLabel_ layer] renderInContext:UIGraphicsGetCurrentContext()];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [brandLabelImages setValue:image forKeyPath:brandName];
        brandNameLabel_.text = nil;
    }
    brandNameLabel_.hidden = YES;
    [brandNameImageView_ setImage:image];

    [colorButtons makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [colorButtons removeAllObjects];
    [self createColorButtonsWithPageData:pageData];
}

- (void)updateForHue:(float)hue {
    [colorButtons makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [colorButtons removeAllObjects];
    [self createColorButtonsWithHue:hue];
}

- (void)enableSelection:(bool)enable {
    for (UIButton* button in  colorButtons) {
        button.enabled = enable;
        UIView* view = [button viewWithTag:NAME_LABEL_TAG];
        view.hidden = !enable;
#if 1 //def TAPPAINTER_PRO
        NSInteger index =  [colorButtons indexOfObject:button];
        if (index == 0) {
            view.hidden = NO;
        }
#endif
    }
    if (enable) {
        [self bringSubviewToFront:useButton_];
        useButton_.hidden = NO;
   } else {
        useButton_.hidden = YES;
    }
    selectionEnabled_ = enable;
}

- (void)colorButtonClicked:(UIButton*)sender {
    UIButton* button = (UIButton*)sender;
    [self placeUseButtonOnColorButton:button];
}

- (void)placeUseButtonOnColorButton:(UIButton*)colorButton {
    TPSwatchData* swatchData = _pageData.swatches[colorButton.tag];
    TPColor* tpColor = [[TPColor alloc] initWithSwatchData:swatchData];
    if (![_colorMarker.tpColor.color.hexStringFromColor isEqualToString:swatchData.color.hexStringFromColor]) {
        _colorMarker.colorChanged = YES;
    }
//    if ([UpgradeProductEngine upgradeEngineSingleton].numberOfCredits == -1) {
        tpColor.purchased = YES; // With Unlimited package the color codes are immediately revealed
//    }
    if (self.launchedFromSearch & !tpColor.purchased) {
        _colorMarker.tpColorFromSearch = tpColor;
    } else {
        _colorMarker.tpColor = tpColor;
    }
    
    CGPoint center = CGPointMake((int)CGRectGetMidX(colorButton.bounds), (int)CGRectGetMidY(colorButton.bounds));
    center.x = (int)center.x; // Allign on integer, otehrwise the buttons will get distorted
    center.y = (int)center.y;
    useButton_.center = center;
    [colorButton addSubview:useButton_];
    NSLog(@"Center: %@", POINT_TO_STRING(useButton_.center));
    useButton_.hidden = NO;
    
    [tutorialController showPaintRollerTutorialForButton:useButton_];
}

- (IBAction)useAction:(id)sender {
    self.colorMarker.colorChanged = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:SLIDING_PANEL_SHOULD_CLOSE object:nil];
    
}


@end
