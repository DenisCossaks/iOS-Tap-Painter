//
//  TPColorPickerViewController.m
//  Tappainter
//
//  Created by Vadim on 11/2/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import "TPColorPickerViewController.h"
#import "KZColorPicker.h"
#import "TPPin.h"
#import "TPAppDefs.h"
#import "TPColor.h"
#import "TPSavedColors.h"
#import "TPBrandSelectionViewController.h"

@interface TPColorPickerViewController () {
    
    __weak IBOutlet UIView *currentColorView_;
    __weak IBOutlet UIButton *useButton_;
    __weak IBOutlet KZColorPicker *colorPicker_;
    TPColor* currentTpColor_;
}

@end

@implementation TPColorPickerViewController

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
	[colorPicker_ addTarget:self action:@selector(colorPickerChanged:) forControlEvents:UIControlEventValueChanged];
    [useButton_.superview bringSubviewToFront:useButton_];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    colorPicker_.selectedColor = self.colorMarker.color;
    currentColorView_.backgroundColor = self.colorMarker.color;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) colorPickerChanged:(KZColorPicker *)cp
{
    self.colorMarker.tpColor = [[TPColor alloc] initWithWebColor:cp.selectedColor];
    self.colorMarker.colorChanged = YES;
    currentColorView_.backgroundColor = cp.selectedColor;
}

- (void)setColorMarker:(TPPin *)colorMarker {
    [super setColorMarker:colorMarker];
    if (colorMarker.color) {
        colorPicker_.selectedColor = colorMarker.color;
        currentColorView_.backgroundColor = colorMarker.color;
    }
}

- (IBAction)useAction:(id)sender {
    if (!self.colorMarker.tpColor) {
        self.colorMarker.tpColor = [[TPColor alloc] initWithWebColor:self.colorMarker.color];
    }
    self.colorMarker.colorChanged = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:SLIDING_PANEL_SHOULD_CLOSE object:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    TPBrandSelectionViewController* controller = segue.destinationViewController;
    controller.colorMarker = self.colorMarker;
    currentTpColor_ = [[TPColor alloc] initWithWebColor:colorPicker_.selectedColor];
    controller.tpColor = currentTpColor_;
}
@end
