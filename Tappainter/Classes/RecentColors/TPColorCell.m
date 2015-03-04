//
//  TPColorCell.m
//  Tappainter
//
//  Created by Vadim on 11/10/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import "TPColorCell.h"
#import "TPColor.h"
#import "TPBrandsManager.h"
#import "TPPin.h"
#import "TPAppDefs.h"
#import "UpgradeProductEngine.h"
#import "TPViewController.h"
#import "UtilityCategories.h"
#import "UIColor-Expanded.h"
#import "Flurry.h"

#define USE_CREDIT_ALERT 1
#define BUY_CREDIT_ALERT 2

@interface TPColorCell () {
    
    __weak IBOutlet UIButton *revealButton_;
    __weak IBOutlet UIButton *convertButton_;
    __weak IBOutlet UIButton *useButton_;
    __weak IBOutlet UILabel *brandLabel_;
    __weak IBOutlet UILabel *codeLabel_;
    __weak IBOutlet UIView *colorView_;
    __weak IBOutlet UILabel *nameLabel_;
    __weak IBOutlet UIView *nameView_;
    __weak IBOutlet UIView *codeView_;
}

@end

@implementation TPColorCell

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserverForName:SLIDING_PANEL_WILL_CLOSE object:nil  queue:nil usingBlock:^(NSNotification *note) {
            if (_selectable) {
//                useButton_.hidden = YES;
                revealButton_.hidden = YES;
                convertButton_.hidden = YES;
            }
        }];
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    [self processSetSelected:selected];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [self processSetSelected:selected];
}

- (void)processSetSelected:(BOOL)selected {
    if (!self.selectable) selected = YES;
    // Configure the view for the selected state
    useButton_.hidden = !(selected && self.selectable);
    [self showConvertRevealButton:selected];
    if (selected) {
        if (![_colorMarker.color.hexStringFromColor isEqualToString:_tpColor.color.hexStringFromColor]) {
            _colorMarker.colorChanged = YES;
        }
        _colorMarker.tpColor = _tpColor;
    }
}

- (void)setTpColor:(TPColor *)tpColor {
//    NSLog(@"Set tpColor to Cell: %x", tpColor);
    _tpColor = tpColor;
    TPSwatchData* swatchData = tpColor.swatchData;
    if (!self.selectable) {
        [self showConvertRevealButton:YES];
    }
    
    NSString* brandName = [NSString stringWithFormat:@" %@ ", [TPBrandsManager brandNameForId:swatchData ? swatchData.brandId : ktpBrandsWebColor]];
    
    float offsetToRightEdge = [brandLabel_ offsetFromRightEdgeToSuperView];
    brandLabel_.text = brandName;
    [brandLabel_ sizeToFit];
    float newOffsetToRightEdge = [brandLabel_ offsetFromRightEdgeToSuperView];
    [brandLabel_ shiftHorizontallyBy:(newOffsetToRightEdge-offsetToRightEdge)];
    
    offsetToRightEdge = [nameLabel_ offsetFromRightEdgeToSuperView];
    if (swatchData.name) {
        nameLabel_.text = [@" " stringByAppendingString:swatchData.name];
//        nameView_.hidden = NO;
    } else {
        nameLabel_.text = [@" " stringByAppendingString:[tpColor.color hexStringFromColor]];
        nameView_.hidden = NO;
    }
    [nameLabel_ sizeToFit];
    newOffsetToRightEdge = [nameLabel_ offsetFromRightEdgeToSuperView];
    [nameLabel_ shiftHorizontallyBy:(newOffsetToRightEdge-offsetToRightEdge)];
    [codeLabel_ shiftHorizontallyBy:(newOffsetToRightEdge-offsetToRightEdge)];
    
    colorView_.backgroundColor = tpColor.color;
    
    [tpColor addObserver:self forKeyPath:@"purchased" options:NSKeyValueObservingOptionNew context:nil];
    if (tpColor.purchased) {
        [self revealCode];
    }
    
}

- (void)showConvertRevealButton:(bool)show {
    TPSwatchData* swatchData = _tpColor.swatchData;
    if (!show) {
        convertButton_.hidden = revealButton_.hidden = YES;
    } else {
        if (!swatchData) {
            convertButton_.hidden = NO;
            revealButton_.hidden = YES;
        } else {
            convertButton_.hidden = YES;
            revealButton_.hidden = _tpColor.purchased;
        }
    }
}

- (IBAction)useAction:(id)sender {
    _colorMarker.colorChanged = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:SLIDING_PANEL_SHOULD_CLOSE object:nil];
//    _colorMarker.tpColor = _tpColor;
//    if (_delegate) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:COLOR_SELECTED object:nil];
//        [_delegate useColor:_tpColor];
//    }
}

- (IBAction)revealAction:(id)sender {
    if ([UpgradeProductEngine isEnoughCredits:1]) {
        if ( [UpgradeProductEngine upgradeEngineSingleton].numberOfCredits != -1) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Confirm Using Credit" message:@"Using a paint code will deduct one credit. Continue?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
            alert.tag = USE_CREDIT_ALERT;
            [alert show];
        } else {
            [UpgradeProductEngine creditsUsed:1];
            [self revealCode];
        }
    } else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Not Enough Credits" message:@"Not enough credits. Buy more?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
        alert.tag = BUY_CREDIT_ALERT;
        [alert show];
    }
}

- (IBAction)convertAction:(id)sender {
    [_colorMarker forceSetColor:_tpColor.color];
    if (_delegate) {
        [_delegate convertColor:_tpColor];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:CONVERT_COLOR object:_tpColor];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == USE_CREDIT_ALERT) {
        if (buttonIndex == 0) {
            [UpgradeProductEngine creditsUsed:1];
            [self revealCode];
            [[NSNotificationCenter defaultCenter] postNotificationName:CODE_REVEALED object:_tpColor];
            [Flurry logEvent:@"Code Revealed" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[_tpColor.color hexStringFromColor], @"color", nil]];
        }
    } else if (alertView.tag == BUY_CREDIT_ALERT) {
        if (buttonIndex == 0) {
            [TPViewController presentBuyCredistController];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"purchased"]) {
        bool purchased = [[change valueForKey:NSKeyValueChangeNewKey] boolValue];
        if (purchased) {
            [self revealCode];
        }
    }
}

- (void)revealCode {
    [_tpColor removeObserver:self forKeyPath:@"purchased"];
    NSString* code = _tpColor.swatchData.code;
    if (_tpColor.swatchData.codePrefix) {
        code = [_tpColor.swatchData.codePrefix stringByAppendingString:code];
    }
    codeLabel_.text = [@" " stringByAppendingString:code];
    [codeLabel_ sizeToFit];
//    codeView_.hidden = NO;
    nameView_.hidden = NO;
    revealButton_.hidden = YES;
    _tpColor.purchased = YES;
}

@end
