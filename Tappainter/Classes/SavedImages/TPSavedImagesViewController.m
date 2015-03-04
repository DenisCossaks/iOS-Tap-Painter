//
//  TPSavedImagesViewController.m
//  Tappainter
//
//  Created by Vadim on 11/18/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import "TPSavedImagesViewController.h"
#import "TPOriginalThumbsViewController.h"
#import "TPEditedImagesController.h"
#import "UtilityCategories.h"
#import "TPImageAsset.h"
#import "TPAppDefs.h"
#import "TPSavedImagesManager.h"
#import "TPTutorialController.h"

@interface TPSavedImagesViewController () {
    
    __weak IBOutlet UIView *editedImagesContainerView_;
    __weak IBOutlet UIView *originalImagesContainerView_;
    __weak IBOutlet UIView *editedImagesSuperContainerView_;
    TPOriginalThumbsViewController* originalImagesController_;
    TPEditedImagesController* editedImagesController_;
}

@end

@implementation TPSavedImagesViewController

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
    originalImagesController_ = (TPOriginalThumbsViewController*)[self childControllerOfClass:[TPOriginalThumbsViewController class]];
    originalImagesController_.notificaitonToWatchFor = SAVED_IMAGES_PANEL_DID_APPEAR;
    originalImagesController_.delegate = self;
    editedImagesController_ = (TPEditedImagesController*)[self childControllerOfClass:[TPEditedImagesController class]];
    editedImagesController_.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:SAVED_IMAGES_PANEL_WILL_CLOSE object:nil
                                                       queue:nil usingBlock:^(NSNotification *note) {
                                                           [self hideEditedImagesView];
                                                       }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (bool)isEditedImagesPanelVisible {
    return editedImagesContainerView_.frame.origin.y <= 20;
}

- (void)showEditedImagesView {
    if (![self isEditedImagesPanelVisible]) {
        [UIView animateWithDuration:0.5 animations:^{
            if ( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                [editedImagesContainerView_ moveVerticallyTo:20]; // Don't cover status bar
            } else {
                [editedImagesContainerView_ moveVerticallyTo:0];
            }
        }];
    }
}

- (void)hideEditedImagesView {
    if ([self isEditedImagesPanelVisible]) {
        [UIView animateWithDuration:0.5 animations:^{
            [editedImagesContainerView_ moveVerticallyTo:editedImagesSuperContainerView_.frame.size.height];
        }];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"Touches Began: %@", [self class]);
    if ([self isEditedImagesPanelVisible]) {
        [editedImagesController_ touchesBegan:touches withEvent:event];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:SAVED_IMAGES_PANEL_SHOULD_CLOSE object:nil];        
    }
}

#pragma mark- TPOriginalImagescontrollerDelegate

- (void)selectionChanged:(TPImageAsset *)asset {
    if (asset.editedAssets.count) {
        if ([self isEditedImagesPanelVisible]) {
            [UIView animateWithDuration:0.25 animations:^{
                editedImagesController_.view.alpha = 0;
            } completion:^(BOOL finished) {
                editedImagesController_.originalImageAsset = asset.originalAsset;
                [UIView animateWithDuration:0.25 animations:^{
                    editedImagesController_.view.alpha = 1;
                }];
           }];
        } else {
            editedImagesController_.originalImageAsset = asset.originalAsset;
            [self showEditedImagesView];
        }
        
        if (asset.editedAssets.count > 1) {
            [self performBlock:^{
                [tutorialController showShareTutorial];
            } afterDelay:0.5];
        }
    } else {
        [self hideEditedImagesView];
    }
}

- (void)originalAssetDeleted {
    if ([self isEditedImagesPanelVisible]) {
        editedImagesController_.originalImageAsset = nil;
    }
}

#pragma mark- TPEditedImagesControllerDelegate

- (void)lastImageDeleted {
    [self hideEditedImagesView];
}

@end
