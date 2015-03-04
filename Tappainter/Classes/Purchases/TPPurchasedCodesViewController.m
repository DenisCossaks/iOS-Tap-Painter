//
//  TPPurchasedCodesViewController.m
//  Tappainter
//
//  Created by Vadim on 12/7/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import "TPPurchasedCodesViewController.h"
#import "TPColorsTableViewController.h"
#import "UtilityCategories.h"
#import "TPAppDefs.h"
#import "TPSavedColors.h"

@interface TPPurchasedCodesViewController () {
    
    __weak IBOutlet UILabel *haventPurchasedCodesLabel_;
    TPColorsTableViewController* colorsTableController_;
}

@end

@implementation TPPurchasedCodesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    colorsTableController_ = [self childControllerOfClass:[TPColorsTableViewController class]];
    colorsTableController_.colorCellDelegate = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:CODE_REVEALED object:nil
                                                       queue:nil usingBlock:^(NSNotification *note) {
                                                           haventPurchasedCodesLabel_.hidden = YES;
                                                           colorsTableController_.tpColors = [TPSavedColors colorsWithCodesRevealed];
                                                       }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([TPSavedColors colorsWithCodesRevealed].count)
        haventPurchasedCodesLabel_.hidden = YES;
    colorsTableController_.tpColors = [TPSavedColors colorsWithCodesRevealed];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setColorMarker:(TPPin *)colorMarker {
    colorsTableController_.colorMarker = colorMarker;
    [super setColorMarker:colorMarker];
}

#pragma mark- TPColorCellDelegate

- (void)useColor:(TPColor *)tpColor {
    [[NSNotificationCenter defaultCenter] postNotificationName:SLIDING_PANEL_SHOULD_CLOSE object:nil];
}

- (void)convertColor:(TPColor *)tpColor {
    
}

@end
