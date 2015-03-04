//
//  TPEditedImagesContainerController.m
//  Tappainter
//
//  Created by Vadim on 10/17/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import "TPEditedImagesContainerController.h"
#import "TPEditedImagesController.h"
#import "TPAppDefs.h"

@interface TPEditedImagesContainerController () {
    TPEditedImagesController* editedImagesControler_;
    __weak IBOutlet UIButton *doneButton_;
    __weak IBOutlet UIView *containerView_;
}
@end

@implementation TPEditedImagesContainerController

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
    doneButton_.layer.borderWidth = 2;
    doneButton_.layer.borderColor = [UIColor lightGrayColor].CGColor;
    doneButton_.layer.cornerRadius = 10;
}

- (void)viewWillLayoutSubviews {
    if ( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
        // For iOS 7 we need to shrink and shift all views down below the status bar,
        // Otherwise it will show on top of views. A bit of a hack, maybe will find a better solution later
        CGRect tempRect = self.view.frame;
        tempRect.origin.y += 20;
        tempRect.size.height -= 20;
        self.view.frame = tempRect;
    }
    
    editedImagesControler_ = self.childViewControllers[0];
    editedImagesControler_.originalImageAsset = _originalImageAsset;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setOriginalImageAsset:(TPImageAsset *)originalImageAsset {
    if (editedImagesControler_) {
        editedImagesControler_.originalImageAsset = originalImageAsset;
        containerView_.alpha = 0;
        [UIView animateWithDuration:0.5 animations:^{
            containerView_.alpha = 1;
        }];
    }
    _originalImageAsset = originalImageAsset;
}

#pragma mark- Actions

- (IBAction)doneAction:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:SAVED_IMAGES_PANEL_DISMISSED object:nil];
    [_delegate willDismiss];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    // It's here not to pass touches up to the main UI
}



@end
