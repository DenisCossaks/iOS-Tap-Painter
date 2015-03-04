//
//  TPSingleSwatchViewController.m
//  Tappainter
//
//  Created by Vadim on 11/12/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import "TPSingleSwatchViewController.h"
#import "TPSwatchView.h"
#import "TPBrandsManager.h"
#import "TPPin.h"
#import "TPColor.h"
#import "TPSavedColors.h"
#import "TPAppDefs.h"
#import "TPSavedColors.h"

@interface TPSingleSwatchViewController () {
    
    __weak IBOutlet UILabel *labelLookingForMatch_;
    __weak IBOutlet UIView *viewForSwatch_;
    __weak IBOutlet UILabel *titleLabel_;
}

@end

@implementation TPSingleSwatchViewController

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
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [[NSNotificationCenter defaultCenter] addObserverForName:SLIDING_PANEL_WILL_CLOSE object:nil queue:nil usingBlock:^(NSNotification *note) {
        if (self.navigationController.visibleViewController == self) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    if (!_pageData) {
        [TPBrandsManager convertColor:self.colorMarker.color withCompletionBlock:^(TPPageData *pageData, NSString *error) {
            if (error) {
                labelLookingForMatch_.text = error;
            } else {
                _pageData = pageData;
                _pageData.selectedSwatch = 0;
                [self configureSwatch];
            }
        }];
    } else {
        [self configureSwatch];
    }
}

-(void)configureSwatch {
    labelLookingForMatch_.hidden = YES;
    TPSwatchView* swatchView = [[TPSwatchView alloc] initWithPageData:_pageData];
    swatchView.frame = viewForSwatch_.bounds;
    swatchView.colorMarker = self.colorMarker;
    swatchView.delegate = self;
    [swatchView enableSelection:YES];
    swatchView.launchedFromSearch = self.launchedFromSearch;
    [viewForSwatch_ addSubview:swatchView];
}

#pragma mark- TPSWatchViewDelegate

- (void)colorUsed:(TPColor *)tpColor {
    if (!_delegate) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:SLIDING_PANEL_SHOULD_CLOSE object:nil];
    } else {
        [_delegate colorUsed:tpColor];
    }
}


- (IBAction)backAction:(id)sender {
    if (self.colorMarker.tpColorFromSearch) {
        self.colorMarker.tpColor = self.colorMarker.tpColor; // Restore color
        self.colorMarker.tpColorFromSearch = nil;
        self.colorMarker.colorChanged = NO;
    }
    [self.navigationController popViewControllerAnimated:YES];
}
@end
