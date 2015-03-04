//
//  TPRecentColorsViewController.m
//  Tappainter
//
//  Created by Vadim on 11/9/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import "TPRecentColorsViewController.h"
#import "TPSavedColors.h"
#import "TPColorCell.h"
#import "TPAppDefs.h"
#import "TPBrandSelectionViewController.h"
#import "TPPin.h"
#import "TPColor.h"
#import "UtilityCategories.h"
#import "TPColorsTableViewController.h"

@interface TPRecentColorsViewController () {
    
    __weak IBOutlet UILabel *noRecentColorsLabel_;
    TPColorsTableViewController* colorsTableController_;
}

@end

@implementation TPRecentColorsViewController

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
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    colorsTableController_ = [self childControllerOfClass:[TPColorsTableViewController class]];
    colorsTableController_.colorCellDelegate = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:COLOR_ADDED object:nil
                                                       queue:nil usingBlock:^(NSNotification *note) {
                                                           noRecentColorsLabel_.hidden = YES;
                                                           colorsTableController_.tpColors = [TPSavedColors savedColors];
                                                       }];
    [[NSNotificationCenter defaultCenter] addObserverForName:COLOR_DELETED object:nil
                                                       queue:nil usingBlock:^(NSNotification *note) {
                                                           colorsTableController_.tpColors = [TPSavedColors savedColors];
                                                       }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([TPSavedColors savedColors].count)
        noRecentColorsLabel_.hidden = YES;
    colorsTableController_.tpColors = [TPSavedColors savedColors];
}

- (void)setColorMarker:(TPPin *)colorMarker {
    colorsTableController_.colorMarker = colorMarker;
    [super setColorMarker:colorMarker];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- TPColorCellDelegate

- (void)convertColor:(TPColor*)tpColor {
    TPBrandSelectionViewController* controller = [UIStoryboard instantiateControllerWithId:@"brandSelection"];
    [self.colorMarker forceSetColor:tpColor.color];
    controller.tpColor = tpColor;
    controller.colorMarker = self.colorMarker;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)useColor:(TPColor *)tpColor {
    [[NSNotificationCenter defaultCenter] postNotificationName:SLIDING_PANEL_SHOULD_CLOSE object:nil];
}

@end
