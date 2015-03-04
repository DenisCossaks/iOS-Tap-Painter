//
//  TPShareImagesViewController.m
//  Tappainter
//
//  Created by Vadim on 11/24/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import "TPShareImagesViewController.h"
#import "TPEditedImagesController.h"
#import "TPAppDefs.h"
#import "UtilityCategories.h"
#import "TPImageAsset.h"
#import "TPSavedImagesManager.h"
#import "FBHelper.h"
#import "TPImageWithSwatchViewController.h"
#import "TPWallPaintService.h"
#import <MessageUI/MessageUI.h>
#import "Flurry.h"

@interface TPShareImagesViewController () {
    __weak IBOutlet UIView *editedImagesContainerView_;
    __weak IBOutlet UIView *originalImagesContainerView_;
    __weak IBOutlet UIView *editedImagesSuperContainerView_;
    TPOriginalThumbsViewController* originalImagesController_;
    TPEditedImagesController* editedImagesController_;
}

@end

@implementation TPShareImagesViewController

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
    originalImagesController_.delegate = self;
    originalImagesController_.notificaitonToWatchFor = SHARE_IMAGES_PANEL_DID_APPEAR;
    editedImagesController_ = (TPEditedImagesController*)[self childControllerOfClass:[TPEditedImagesController class]];
    editedImagesController_.showCheckMark = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (bool)isEditedImagesPanelVisible {
    return editedImagesContainerView_.frame.origin.y == 0;
}


- (void)showEditedImagesView {
    if (![self isEditedImagesPanelVisible]) {
        [UIView animateWithDuration:0.5 animations:^{
            [editedImagesContainerView_ moveVerticallyTo:0];
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
    } else {
        [self hideEditedImagesView];
    }
}

- (void)originalAssetDeleted {
    
}

#pragma mark- Actios
- (IBAction)sendEmailAction:(id)sender {
    
    if ( ![TPSavedImagesManager markedImageAssets].count) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"No Photos Selected" message:@"Please select some photos first" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    } else {
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
            
            [controller setSubject:@"TapPainter"];
            controller.mailComposeDelegate = self;
            [controller setMessageBody:@"See the photos I painted with TapPainter!" isHTML:NO];
            
            int i = 1;
            for (TPImageAsset* asset in [TPSavedImagesManager markedImageAssets]) {
                // Generate an image offscreen that contains asset image and the swatch stacked under it
                TPImageWithSwatchViewController* imageWithSwatchController = [[TPImageWithSwatchViewController alloc] init];
                imageWithSwatchController.imageAsset = asset;
                UIGraphicsBeginImageContext(imageWithSwatchController.view.frame.size);
                [[imageWithSwatchController.view layer] renderInContext:UIGraphicsGetCurrentContext()];
                UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                NSData* imageData = UIImageJPEGRepresentation(screenshot, 1);
                if (asset.isOriginal) {
                    [controller addAttachmentData:imageData mimeType:@"image/jpeg" fileName:@"Original Room"];
                } else {
                    [controller addAttachmentData:imageData mimeType:@"image/jpeg" fileName:[NSString stringWithFormat:@"Painted Room %d", i++]];
                }
            }
            
            [self presentViewController:controller animated:YES completion:^{
            }];
        } else {
            [self showAlertWithTitle:@"Can't Send Email" andMessage:@"Make sure you have set up an email account on this device"];
        }
    }
}

- (IBAction)faceBookAction:(id)sender {
    if ( ![TPSavedImagesManager markedImageAssets].count) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"No Photos Selected" message:@"Please select a colored photos first" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    } else {
        [FBHelper postToWallWithImageAsset:[[TPSavedImagesManager markedImageAssets] lastObject]];
    }
}


- (IBAction)closeAction:(id)sender {
    [self hideEditedImagesView];
    [[NSNotificationCenter defaultCenter] postNotificationName:SHARE_IMAGES_PANEL_DISMISSED object:nil];
}

#pragma mark - MFMessageComposeViewControllerDelegate methods

-(void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
    if (result == MFMailComposeResultSent) {
        [TPSavedImagesManager unmarkAllImageAssets];
//        editedImagesController_.originalImageAsset = editedImagesController_.originalImageAsset; // Make it reload to remove checkmarks
        [Flurry logEvent:@"Image Shared" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"email", @"via", nil]];
    } else {
        [self showAlertWithTitle:@"Couldn't Send Email" andMessage:nil];
    }
    
    [self closeAction:nil];
}

@end
