//
//  TPViewController.m
//  Tappainter
//
//  Created by Vadim on 9/15/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import "TPViewController.h"
#import "TPPin.h"
#import "Defs.h"
#import "UIColor-Expanded.h"
#import "UtilityCategories.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "TPCustomCameraViewController.h"
#import "UtilityCategories.h"
#import "TPAnimatedLogo.h"
#import "TPLeftBarView.h"
#import "TPTopBarView.h"
#import "TPSavedImagesManager.h"
#import "TPDraggablePinIcon.h"
#import "TPImageAsset.h"
#import "TPOriginalThumbsViewController.h"
#import "TPImageScrollView.h"
#import "TPColorPickerViewController.h"
#import "TPSwatchesViewController.h"
#import "TPColorPickerBaseViewController.h"
#import "TPPurchasedCodesViewController.h"
#import "TPAppDefs.h"
#import "TPRecentColorsViewController.h"
#import "TPBrandSelectionViewController.h"
#import "TPColor.h"
#import "TPButtonWithLabel.h"
#import "FBHelper.h"
#import "UpgradeProductEngine.h"
#import "TPCornerMarker.h"
#import "TPPolygonView.h"
#import "TPMagnifyingGlass.h"
#import <FacebookSDK/FacebookSDK.h>
#import "Flurry.h"
#import "TPSavedColors.h"
#import "TPImageView.h"
#import "TPTutorialController.h"
#import "FlurryAdDelegate.h"
#import "FlurryAds.h"
#import "TPReviewUpgradePromptHelper.h"
#import <MessageUI/MessageUI.h>
#import "TPImageWithSwatchViewController.h"
#import "TPAdsManager.h"

#define POPOVER_BACKGROUND_COLOR [UIColor colorWithRed:41.0/255.0 green:47.0/225.0 blue:61.0/255.0 alpha:1]
#define ALERT_FACEBOOK_SIGNOUT 1
#define ALERT_APPLY_NEW_COLOR 2
#define ALERT_SWITCH_TO_FAST_MODE 3
#define ALERT_SWITCHING_IMAGE 4
#define ALERT_CLEAR_POLYGON 5
#define ALERT_PAINT_NOW_OR_LATER 7
#define USE_CREDIT_ALERT 9
#define BUY_CREDIT_ALERT 10
#define SHARE_ALERT 11

TPViewController* thisController;
TPTutorialController* tutorialController;

@interface TPViewController () {

    TPAnimatedLogo* animatedLogo_;
    __weak IBOutlet TPLeftBarView *leftBarView_;
    __weak IBOutlet TPTopBarView *topBarView_;
    __weak IBOutlet UIImageView *imageView_;
    __weak IBOutlet UIView *progressView_;
    __weak IBOutlet UILabel *progressLabel_;
    __weak IBOutlet UIProgressView *progressBar_;
    __weak IBOutlet UIButton *photoAlbumButton_;
    __weak IBOutlet UIButton *addMarkerButton_;
    __weak IBOutlet UIButton *revertButton_;
    __weak IBOutlet UILabel *versionLabel_;
    __weak IBOutlet TPDraggablePinIcon *draggablePinIcon_;
    __weak IBOutlet UIView *slidingPanel_;
    IBOutletCollection(UIButton) NSArray *leftBarButtons_;
    IBOutletCollection(UIButton) NSArray *allButtons_;
    IBOutletCollection(UIButton) NSArray *topBarButtons_;
    IBOutlet UILongPressGestureRecognizer *longPressRecognizer_;
    __weak IBOutlet UIView *savedImagesPanelView_;
    __weak IBOutlet UIView *cameraContainerView_;
    __weak IBOutlet UIView *savingImageView_;
    __weak IBOutlet UIView *shareImagesView_;
    
    UIPopoverController* popoverForImagePicker_;
    UIImagePickerController* imagePickerController_;
    TPCustomCameraViewController* cameraViewController_;
    TPColorPickerViewController* colorPickerController_;
    TPSwatchesViewController* swatchesController_;
    TPRecentColorsViewController* recentColorsController_;
    TPBrandSelectionViewController* brandsSelectionController_;
    TPPurchasedCodesViewController* purchasedCodesController_;
    __weak IBOutlet UIImageView *statusBarBackgroundView_;
    __weak IBOutlet UIView *colorPickerContainerView_;
    __weak IBOutlet UIView *swatchesContainerView_;
    __weak IBOutlet UIView *recentColorsContainerView_;
    __weak IBOutlet UIView *purchasedCodesContainerView_;
    __weak IBOutlet UIButton *savedImagesButton_;
    __weak IBOutlet UIView *canvasView;
    __weak IBOutlet UIButton *useCameraButton_;
    __weak IBOutlet UIButton *selectFromLibraryButton_;
    __weak IBOutlet UILabel *selectPreviouslyUsedImageLabel_;
    __weak IBOutlet FBProfilePictureView *facebookImage_;
    __weak IBOutlet UIView *profilePictureBorderView_;
    __weak IBOutlet UIView *avatarContainerView_;
    __weak IBOutlet UIButton *faceBookButton_;
    __weak IBOutlet UIView *faceBookLoginScreen_;
    
    __weak IBOutlet UIImageView *longerShadowForCredits_;
    CGRect slidingPanelPanelOriginalFrame_;
    CGRect topBarViewOriginalFrame_;
    CGRect imageViewOriginalFrame_;
    CGRect savedImagesPanelOriginalFrame_;
    __weak IBOutlet TPImageScrollView *imageScrollView_;
    __weak IBOutlet UIView *saveImagesContainerView_;
    __weak IBOutlet UIView *brandsSelectionContainerView_;
    CGRect savedImageContainerFrame_;
    CGRect shareImagesContainerFrame_;
    
    bool addMarkerButtonClicked_;
    bool viewsAdjusted_;
    __weak IBOutlet UILabel *numberOfCreditsLabel_;
    __weak IBOutlet UIImageView *unlimitedCreditsIcon_;
    __weak IBOutlet UIImageView *throbberImageView_;
    __weak IBOutlet UIButton *clearButton_;
    __weak IBOutlet UIButton *clearAllButton_;
    __weak IBOutlet UIButton *quickModeButton_;
    __weak IBOutlet UIButton *customModeButton_;
    __weak IBOutlet UIView *tutorialContainerView_;
    __weak IBOutlet UIView *walkThroughTutorialContainerView_;
    CGRect walkThroughTutorialContainerViewFrame_;
   
    TPCornerMarker* selectedCornerMarker_;
    IBOutlet UITapGestureRecognizer *tapRecognizerForCornerMarker_;
    NSMutableArray* cornerMarkers_;
    TPPolygonView* polygonView_;
    TPMagnifyingGlass* magnifyingGlass_;
    __weak IBOutlet UILabel *creditsLeftLabel_;
    __weak IBOutlet UIButton *backButton;
    __weak IBOutlet TPButtonWithLabel *colorPickerButton_;
    __weak IBOutlet TPButtonWithLabel *swatchesButton_;
    __weak IBOutlet TPButtonWithLabel *tutorialButton_;
    __weak IBOutlet UIView *viewForCredits_;
    __weak IBOutlet TPButtonWithLabel *purchasedButton_;
    __weak IBOutlet TPButtonWithLabel *shareButton_;
    
    IBOutletCollection(UIButton) NSArray *buttonsToShiftForLite_;
    __weak IBOutlet UIImageView *topBarImageView_;
    IBOutletCollection(UIView) NSArray *viewToHideForLite_;
    IBOutletCollection(TPButtonWithLabel) NSArray *buttonsToShiftUpForLite_;
}

- (IBAction)InAppAction:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *animatedLogoPlaceholder_;
@property TPImageAsset* selectedImageAsset;
@property (nonatomic, retain) UIView *flurryContainer;

@end

@implementation TPViewController

@synthesize flurryContainer;

NSString *AdSpaceName=@"RTBTakeover";

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    thisController = self;
    
    versionLabel_.text = [NSString stringWithFormat:@"V: %@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
    
    imagePickerController_ = [[UIImagePickerController alloc]init];
    imagePickerController_.delegate = self;
    imagePickerController_.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        popoverForImagePicker_ = [[UIPopoverController alloc]
                    initWithContentViewController:imagePickerController_];
        popoverForImagePicker_.delegate = self;
    }

//    animatedLogo_ = [[TPAnimatedLogo alloc] initWithFrame:self.animatedLogoPlaceholder_.frame];
//    [self.animatedLogoPlaceholder_.superview addSubview:animatedLogo_];
    
    cornerMarkers_ = [NSMutableArray array];
    
//    [self initFlurryAds];
    
    [self setQuickMode];
    
    revertButton_.enabled = NO;
    addMarkerButton_.enabled = NO;
    [self displayNumberOfCredits];
    [[UpgradeProductEngine upgradeEngineSingleton] addObserver:self forKeyPath:@"numberOfCredits" options:NSKeyValueObservingOptionNew context:nil];
    
    [self addObserver:self forKeyPath:@"selectedImage" options:NSKeyValueObservingOptionNew context:nil];
    
    recentColorsController_ = (TPRecentColorsViewController*)[self childControllerOfClass:[TPRecentColorsViewController class]];
    swatchesController_ = (TPSwatchesViewController*)[self childControllerOfClass:[TPSwatchesViewController class]];
    colorPickerController_ = (TPColorPickerViewController*)[self childControllerOfClass:[TPColorPickerViewController class]];
    brandsSelectionController_ = [self childControllerOfClass:[TPBrandSelectionViewController class]];
    purchasedCodesController_ = [self childControllerOfClass:[TPPurchasedCodesViewController class]];
    if (![self isCameraSupported]) {
        useCameraButton_.hidden = TRUE;
        CGPoint center = selectFromLibraryButton_.center;
        center.x = CGRectGetMidX(selectFromLibraryButton_.superview.bounds);
        selectFromLibraryButton_.center = center;
    }
    if ([TPSavedImagesManager sharedSavedImagesManager].savedPhotos.count == 0) {
        selectPreviouslyUsedImageLabel_.hidden = YES;
        [selectFromLibraryButton_ moveVerticallyTo:selectFromLibraryButton_.superview.bounds.size.height/2 - selectFromLibraryButton_.bounds.size.height];
        [useCameraButton_ moveVerticallyTo:useCameraButton_.superview.bounds.size.height/2 - useCameraButton_.bounds.size.height];
    }
    
    profilePictureBorderView_.layer.cornerRadius = 2;
    throbberImageView_.animationImages = [NSArray arrayWithObjects:
                            [UIImage imageNamed:@"throbber-tp-state-A"],
                            [UIImage imageNamed:@"throbber-tp-state-B"],
                            [UIImage imageNamed:@"throbber-tp-state-C"],
                            [UIImage imageNamed:@"throbber-tp-state-D"],
                            nil];
    throbberImageView_.animationDuration = 0.3;
    throbberImageView_.animationRepeatCount = 0;
    
    tutorialController = [self childControllerOfClass:[TPTutorialController class]];
    tutorialController.containerView_ = tutorialContainerView_;
    
#ifdef TAPPAINTER_TRIAL
    [self configureUIForLite];
#endif
    
    [FBHelper loginSilentlyWithCompletionBlock:^(bool Success) {
        if (Success) {
            faceBookLoginScreen_.hidden = YES;
        }
    }];
    
    [self addNotificationObservers];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
        if (!viewsAdjusted_) {
            // For iOS 7 we need to shrink and shift all views down below the status bar,
            // Otherwise it will show on top of views. A bit of a hack, maybe will find a better solution later
            CGRect tempRect;
            for(UIView *sub in [[self view] subviews])
            {
                if (sub != statusBarBackgroundView_) {
                    tempRect = [sub frame];
                    tempRect.origin.y += 20.0f; //Height of status bar
                    if (imageScrollView_ == sub || imageView_ == sub) {
                        CGFloat surPlus = tempRect.origin.y + tempRect.size.height - [self height];
                        if (surPlus > 0) {
                            tempRect.size.height -= surPlus;
                        }
                    }
                    [sub setFrame:tempRect];
                }
            }
            viewsAdjusted_ = YES;
        }
    }
    shareImagesContainerFrame_ = shareImagesView_.frame;
    savedImageContainerFrame_ = saveImagesContainerView_.frame;
    walkThroughTutorialContainerViewFrame_ = walkThroughTutorialContainerView_.frame;
    
    if (!canvasView.hidden && [TPSavedImagesManager sharedSavedImagesManager].savedPhotos.count) {
        [self showSaveImagesPanel];
    }
#if 1 //def TAPPAINTER_PRO
    viewForCredits_.hidden = YES;
    tutorialButton_.frame = shareButton_.frame;
    shareButton_.frame = purchasedButton_.frame;
    purchasedButton_.hidden = YES;
#endif
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation  {
    return UIDeviceOrientationIsLandscape(toInterfaceOrientation);
}

#pragma mark- Service Methods

+ (void)presentBuyCredistController {
    [thisController InAppAction:nil];
}

- (void) getRecentPhotoThumbWithBlock:(void (^)(UIImage*))block {
    __block UIImage *image;
    
    ALAssetsLibrary *al = [[ALAssetsLibrary alloc] init];
    [al enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        NSNumber* type = [group valueForProperty:ALAssetsGroupPropertyType];
        if ([type intValue] == ALAssetsGroupSavedPhotos) {
            image = [UIImage imageWithCGImage:group.posterImage];
            block(image);
        }
    } failureBlock:^(NSError *error) {
        // User did not allow access to library
        // .. handle error
    }];
}

- (BOOL)isCameraSupported {
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (void)addCameraController {
    if (![self isCameraSupported]) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"This device doesn't have a Camera" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
    } else {
        if (!cameraViewController_) {
            cameraContainerView_.hidden = NO;
            CGRect frame = cameraContainerView_.bounds;
            cameraViewController_ = [[TPCustomCameraViewController alloc] initWithFrame:frame];
            cameraViewController_.delegate = self;
            cameraViewController_.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self addChildViewController:cameraViewController_];
            [cameraContainerView_ addSubview:cameraViewController_.view];
            [cameraContainerView_ setUserInteractionEnabled:YES];
            [cameraViewController_ didMoveToParentViewController:self];
            photoAlbumButton_.hidden = NO;
        }
    }
}

- (void)removeCameraController {
    if (cameraViewController_) {
        if (_selectedImageAsset) {
            canvasView.hidden = YES;
        }
        cameraViewController_.delegate = nil;
        [cameraViewController_ willMoveToParentViewController:nil];
        [cameraViewController_.view removeFromSuperview];
        [cameraViewController_ removeFromParentViewController];
        cameraViewController_ = nil;
        photoAlbumButton_.hidden = NO;
        cameraContainerView_.hidden = YES;
        
        if (!_selectedImageAsset && [TPSavedImagesManager sharedSavedImagesManager].savedPhotos.count) {
            [self showSaveImagesPanel];
        }
    }
}

- (void)selectButton:(UIButton*)button {
    for (UIButton* button in leftBarButtons_) {
        button.selected = NO;
    }
    button.selected = YES;
}

- (void)addSlidingPanelController:(UIViewController*)controller {
    [self addChildViewController:controller];
    [slidingPanel_ addSubview:controller.view];
    [controller didMoveToParentViewController:self];
}

- (void)removeSlindingPanelController {
    UIViewController* childController = self.childViewControllers[0];
    [childController willMoveToParentViewController:nil];
    [childController.view removeFromSuperview];
    [childController removeFromParentViewController];
}

- (void)showBrandsSelection {
    [self showSlidingPanelWthBlock:^{
        brandsSelectionContainerView_.frame = slidingPanel_.bounds;
//        currentColorPickerController_ = recentColorsController_;
        [slidingPanel_ addSubview:brandsSelectionContainerView_];
    }];
}

- (void)closeSlidingPanel{
    if ([self isSlidingPanelVisible]) {
        [self closeSlidingPanelWthCompletionBlock:^{
            for (UIButton* button in topBarButtons_) {
                button.userInteractionEnabled = YES;
            }
            imageScrollView_.scrollEnabled = YES;
            [self selectButton:nil]; // Unselect all left bar buttons
        }];
    }
}

- (void)closeSlidingPanelWthCompletionBlock:(void(^)(void))block {
    if ([self isSlidingPanelVisible]) {
        tapRecognizerForCornerMarker_.enabled = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:SLIDING_PANEL_WILL_CLOSE object:nil];
        
        TPPin* colorMarker = _selectedImageAsset.colorMarker;
        if (colorMarker.colorChanged) {
            colorMarker.colorChanged = NO;
            // This means that the user has picked some color
            if (colorMarker.tpColorFromSearch) {
                // It's a color from swatches. Confirm we have enough credits and if we do confirm user wants to use it for painting with it
                _selectedImageAsset.colorMarker.tpColor = _selectedImageAsset.colorMarker.tpColorFromSearch;
                _selectedImageAsset.colorMarker.tpColor.purchased = YES;
                _selectedImageAsset.colorMarker.colorChanged = NO;
//                if ([UpgradeProductEngine isEnoughCredits:1]) {
//                    if ( [UpgradeProductEngine upgradeEngineSingleton].numberOfCredits != -1) {
//                        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Confirm Using Credit" message:@"Using a paint code will deduct one credit. Continue?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
//                        alert.tag = USE_CREDIT_ALERT;
//                        [alert show];
//                    } else {
//                        [UpgradeProductEngine creditsUsed:1];
                        [self askCurrentOrOriginal];
//                    }
//                } else {
//                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Not Enough Credits" message:@"You need one credit to paint with selected color. Do you want to buy more credits?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
//                    alert.tag = BUY_CREDIT_ALERT;
//                    [alert show];
//                }
            } else {
                // Just go paint now
                [self askCurrentOrOriginal];
            }
        }
        [UIView animateWithDuration:0.5 animations:^{
            slidingPanel_.frame = slidingPanelPanelOriginalFrame_;
            topBarView_.frame = topBarViewOriginalFrame_;
            imageScrollView_.frame = imageViewOriginalFrame_;
        } completion:^(BOOL finished) {
            [slidingPanel_.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            if (block)
                block();
        }];
    }
}

- (void)showSlidingPanel {
    [self showSlidingPanelWthBlock:nil];
}

- (void)showSlidingPanelWthBlock:(void(^)(void))block {
    void(^showPanelBlock)(void) = ^(void) {
        if (block)
            block();
        
       [self closeTutorial];
        // Slide color picker panel from the left and place it adjasent to the left bar
        CGRect slidingPanelNewFrame = slidingPanel_.frame;
        slidingPanelPanelOriginalFrame_ = slidingPanelNewFrame;
        slidingPanelNewFrame.origin.x = leftBarView_.frame.size.width;
        // Slide top bar to the left as well by half as much
        CGRect topBarNewFrame = topBarView_.frame;
        topBarViewOriginalFrame_ = topBarNewFrame;
        topBarNewFrame.origin.x += slidingPanel_.frame.size.width;
        // As for the image we move it for as much (but not too far) as to make sure the pin is not obscured
        float maxDistance = imageScrollView_.frame.size.width - (_selectedImageAsset.colorMarker.view.frame.origin.x + _selectedImageAsset.colorMarker.view.frame.size.width) - 10;
        maxDistance = MIN(maxDistance, slidingPanel_.frame.size.width);
        CGRect imageViewNewFrame = imageScrollView_.frame;
        imageViewOriginalFrame_ = imageViewNewFrame;
        imageViewNewFrame.origin.x += maxDistance;
        
        [UIView animateWithDuration:0.5 animations:^{
            slidingPanel_.frame = slidingPanelNewFrame;
            topBarView_.frame = topBarNewFrame;
            imageScrollView_.frame = imageViewNewFrame;
        } completion:^(BOOL finished) {
            for (UIButton* button in topBarButtons_) {
                button.userInteractionEnabled = NO;
            }
            imageScrollView_.scrollEnabled = NO;
            tapRecognizerForCornerMarker_.enabled = NO;
            
            if (colorPickerButton_.selected) {
                [tutorialController showColorPickerTutorial];
            }
//            else if (swatchesButton_.selected) {
//                [tutorialController showSwatchTutorial];
//            }
       }];
    };
    if ([self isSlidingPanelVisible]) {
        _selectedImageAsset.colorMarker.colorChanged = NO; // Don't ask to paint
        [self closeSlidingPanelWthCompletionBlock:showPanelBlock];
    } else {
        showPanelBlock();
        [[NSNotificationCenter defaultCenter] postNotificationName:SLIDING_PANEL_WILL_OPEN object:nil];
    }
}

- (void)showSaveImagesPanel {
    
    if (![self isSavedImagesPanelVisible]) {

        _selectedImageAsset.colorMarker.colorChanged = NO; // Don't ask to paint
        [self closeSlidingPanel];
        [self hideShareImagesPanelAnimated:NO];
        [self closeTutorial];
        imageView_.image = imageScrollView_.imageAsset.selectedImageAsset.image;
        imageView_.hidden = NO;
        
        saveImagesContainerView_.hidden = NO;
        [UIView animateWithDuration:0.5 animations:^{
            [saveImagesContainerView_ moveVerticallyTo:0];
        } completion:^(BOOL finished) {
            [[NSNotificationCenter defaultCenter] postNotificationName:SAVED_IMAGES_PANEL_DID_APPEAR object:nil];
        }];
        imageScrollView_.scrollEnabled = NO;
        savedImagesButton_.selected = YES;
        tapRecognizerForCornerMarker_.enabled = NO;
    }
}

- (void)hideSavedImagesPanelAnimated:(bool)animated {
    if ([self isSavedImagesPanelVisible]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SAVED_IMAGES_PANEL_WILL_CLOSE object:nil];
        if (animated) {
            [UIView animateWithDuration:0.5 animations:^{
                saveImagesContainerView_.frame = savedImageContainerFrame_;
            } completion:^(BOOL finished) {
                saveImagesContainerView_.hidden = YES;
            }];
        } else {
            saveImagesContainerView_.frame = savedImageContainerFrame_;
            saveImagesContainerView_.hidden = YES;
        }
        if (_selectedImageAsset) {
            [_selectedImageAsset upload];
            [TPSavedImagesManager setSelectedImageAsset:_selectedImageAsset];
            [self loadSelectedImageAsset];
        }
        savedImagesButton_.selected = NO;
        tapRecognizerForCornerMarker_.enabled = YES;
    }
}

- (bool)isSavedImagesPanelVisible {
    return saveImagesContainerView_.frame.origin.y != savedImageContainerFrame_.origin.y;
}

- (void)showShareImagesPanel {
    
    if (![self isShareImagesPanelVisible]) {
        
        _selectedImageAsset.colorMarker.colorChanged = NO; // Don't ask to paint
        [self closeSlidingPanel];
        [self hideSavedImagesPanelAnimated:NO];
        [self closeTutorial];
        
        imageView_.image = imageScrollView_.imageAsset.selectedImageAsset.image;
        imageView_.hidden = NO;
        
        shareImagesView_.hidden = NO;
        [UIView animateWithDuration:0.5 animations:^{
            [shareImagesView_ moveVerticallyTo:0];
        } completion:^(BOOL finished) {
            [[NSNotificationCenter defaultCenter] postNotificationName:SHARE_IMAGES_PANEL_DID_APPEAR object:nil];
            shareImagesView_.userInteractionEnabled = YES;
        }];
//        self.view.userInteractionEnabled = NO;
        tapRecognizerForCornerMarker_.enabled = NO;
    }
}

- (void)hideShareImagesPanelAnimated:(bool)animated {
    if ([self isShareImagesPanelVisible]) {
        if (animated) {
            [UIView animateWithDuration:0.5 animations:^{
                //                savedImagesPanelView_.frame = savedImagesPanelOriginalFrame_;
                shareImagesView_.frame = shareImagesContainerFrame_;
            } completion:^(BOOL finished) {
                shareImagesView_.hidden = YES;
            }];
        } else {
            //            savedImagesPanelView_.shareImagesContainerFrame_ = savedImagesPanelOriginalFrame_;
            shareImagesView_.frame = shareImagesContainerFrame_;
            shareImagesView_.hidden = YES;
        }
        if (_selectedImageAsset) {
            [_selectedImageAsset upload];
            [TPSavedImagesManager setSelectedImageAsset:_selectedImageAsset];
            [self loadSelectedImageAsset];
        }
        self.view.userInteractionEnabled = YES;
        [TPSavedImagesManager unmarkAllImageAssets];
        tapRecognizerForCornerMarker_.enabled = YES;
    }
}

- (bool)isShareImagesPanelVisible {
    return shareImagesView_.frame.origin.y != shareImagesContainerFrame_.origin.y;
}

- (bool)isSlidingPanelVisible {
    return slidingPanel_.frame.origin.x > 0;
}

- (double)width {
    // Due to orientation rotations width and height might be swapped
    if (self.view.frame.size.width > self.view.frame.size.height)
        return self.view.frame.size.width;
    else
        return self.view.frame.size.height;
}

- (double)height {
    // Due to orientation rotations width and height might be swapped
    if (self.view.frame.size.width > self.view.frame.size.height)
        return self.view.frame.size.height;
    else
        return self.view.frame.size.width;
}

- (TPPin*)placeMarkerAtLocation:(CGPoint)location {
    TPPin* pin = [[TPPin alloc] init];
    [[imageScrollView_ imageViewAtLocation:location] addSubview:pin.view];
    pin.position = location;
    _selectedImageAsset.colorMarker = pin;
    addMarkerButton_.enabled = NO;
    draggablePinIcon_.hidden = YES;
    pin.delegate = self;
    
    [tutorialController showTutorialForColorMarkerWithMarker:pin];
    
    return pin;
}

- (void)placeMarker:(TPPin*)pin {
    [[imageScrollView_ imageViewAtLocation:pin.position] addSubview:pin.view];
    pin.position = pin.position; //Make sure pin positions itself on the superview
    addMarkerButton_.enabled = NO;
    draggablePinIcon_.hidden = YES;
    pin.delegate = self;
}

- (void) removePin {
    _selectedImageAsset.colorMarker = nil;
    [self enableNewPinPlacement];
}

- (void) enableNewPinPlacement {
    addMarkerButton_.enabled = YES;
    draggablePinIcon_.hidden = NO;
}

- (void) showProgressView:(BOOL)show {
    progressView_.hidden = !show;
    show ? [throbberImageView_ startAnimating] : [throbberImageView_ stopAnimating];
}

- (bool)checkImage {
    if (!_selectedImageAsset) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Please select a picture first" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        if ([[TPSavedImagesManager sharedSavedImagesManager].savedPhotos count] != 0) {
            if (![self isSavedImagesPanelVisible]) {
                [self savedImagesAction:nil];
            }
        } else {
            [self pickPhotoAction:photoAlbumButton_];
        }
        return NO;
    }
    return YES;
}

- (bool)checkMarkerAndColor {
    if ( !_selectedImageAsset.colorMarker ) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Wall and Color Not Selected" message:@"Please position the paint roller on a wall and select a color." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [self hideSavedImagesPanelAnimated:YES];
        [self placeMarkerAtLocation:CGPointMake(CGRectGetMidX(imageScrollView_.bounds), imageScrollView_.bounds.size.height/4)];
        return NO;
    } else {
        return [self checkColor];
    }
    return YES;
}


- (bool)checkMarker {
    if ( !_selectedImageAsset.colorMarker ) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Wall is Not Selected" message:@"Please position the paint roller on a wall." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [self hideSavedImagesPanelAnimated:YES];
        [self placeMarkerAtLocation:CGPointMake(CGRectGetMidX(imageScrollView_.bounds), imageScrollView_.bounds.size.height/4)];
        return NO;
    }
    return YES;
}

- (bool)checkColor {
    if (!_selectedImageAsset.colorMarker.tpColor) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Please Select a Color" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [self colorPickerAction:nil];
        return NO;
    }
    return YES;
}

- (void)loadSelectedImageAsset {
    if (_selectedImageAsset) {
        [self clearAllAction:nil];
        imageScrollView_.imageAsset = _selectedImageAsset;
        imageScrollView_.scrollEnabled = YES;
        imageScrollView_.hidden = NO;
        canvasView.hidden = YES;
        imageView_.hidden = YES;
        [_selectedImageAsset upload];
        if (!_selectedImageAsset.colorMarker) {
            [self placeMarkerAtLocation:CGPointMake(CGRectGetMidX(imageView_.bounds), CGRectGetMidY(imageView_.bounds))];
        } else {
            [self placeMarker:_selectedImageAsset.colorMarker];
        }
        revertButton_.enabled = !_selectedImageAsset.isOriginal;
        backButton.enabled = !_selectedImageAsset.isOriginal;
        [self setQuickMode];
    }
}

- (void)paintImage {
    [TPSavedColors saveColor:_selectedImageAsset.colorMarker.tpColor];
    if (_selectedImageAsset.colorMarker.tpColor.purchased) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CODE_REVEALED object:nil];
    }
    
    progressLabel_.text = @"Processing Image...";
    [self showProgressView:YES];
    [throbberImageView_ startAnimating];
    
    // Convert poligon vertices into image coordinates
        
    [_selectedImageAsset paintWithPolygon:cornerMarkers_ delegate:self success:^(TPImageAsset *imageAsset) {
        [self showProgressView:NO];
        TPPin* pin = [TPPin pinWithPin:_selectedImageAsset.colorMarker];
        _selectedImageAsset = imageAsset;
        [TPSavedImagesManager setSelectedImageAsset:imageAsset];
        _selectedImageAsset.colorMarker = pin;
        _selectedImageAsset.tpColor = pin.tpColor;
        _selectedImageAsset.colorMarker.colorChanged = NO;
        [self loadSelectedImageAsset];
        
        if (![tutorialController showTutorialOnPaintFinished]) {
            if (pin.tpColor.swatchData && !pin.tpColor.purchased) {
                [tutorialController showRevealTutorial];
            }
        }
        
        if (![TPReviewUpgradePromptHelper promptForReviewOrUpgrade]) {
            [TPAdsManager showAdOnPaint];
        }
        
    } failure:^(NSString *error) {
        [self showProgressView:NO];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error Processing Picture" message:error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }];
}



- (void)switchToAsset:(TPImageAsset*)imageAsset {
    if (imageAsset.colorMarker) {
        NSLog(@"selectedAssetChanged: color marker position: %@", POINT_TO_STRING(imageAsset.colorMarker.position));
        imageAsset.colorMarker.tpColor = imageAsset.tpColor;
        [self placeMarker:imageAsset.colorMarker];
        imageAsset.colorMarker.colorChanged = NO;
    }
    else
        [self enableNewPinPlacement];
    _selectedImageAsset = imageAsset;
    backButton.enabled = revertButton_.enabled = !_selectedImageAsset.isOriginal;
    imageScrollView_.hidden = NO;
}

- (void)displayNumberOfCredits {
    int numberOfCredits = [UpgradeProductEngine upgradeEngineSingleton].numberOfCredits;
    if (numberOfCredits == -1) {
        unlimitedCreditsIcon_.hidden = NO;
        numberOfCreditsLabel_.hidden = YES;
        creditsLeftLabel_.text = @"unlimited credits";
        longerShadowForCredits_.hidden = NO;
    } else {
        unlimitedCreditsIcon_.hidden = YES;
        numberOfCreditsLabel_.hidden = NO;
        numberOfCreditsLabel_.text = [NSString stringWithInt:numberOfCredits];
        creditsLeftLabel_.text = numberOfCredits == 1 ? @"credit left" : @"credits left";
    }
}

- (void)askCurrentOrOriginal {
    if ([self checkPolygon] && [self checkInternetConnectionWithErrorAlert:YES]) {
        if (!_selectedImageAsset.isOriginal) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Add color to this image or repaint original?" message:nil delegate:self cancelButtonTitle:@"Repaint" otherButtonTitles:@"Not Now", @"Add Color", nil];
            alert.tag = ALERT_APPLY_NEW_COLOR;
            [alert show];
        } else {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Apply Color Now?" message:nil delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"Not Now", nil];
            alert.tag = ALERT_PAINT_NOW_OR_LATER;
            [alert show];
        }
    }
}

- (void)closeTutorial {
    if (tutorialButton_.selected) {
        CGRect frame = walkThroughTutorialContainerViewFrame_;
        frame.origin.y = self.view.frame.origin.y + self.view.frame.size.height;
        [UIView animateWithDuration:0.5 animations:^{
            walkThroughTutorialContainerView_.frame = frame;
        } completion:^(BOOL finished) {
            walkThroughTutorialContainerView_.hidden = YES;
        }];
        tutorialButton_.selected = NO;
    }
}

- (void)configureUIForLite {
    topBarImageView_.image = [UIImage imageNamed:@"TopBarTrial"];
    for (UIButton* button in buttonsToShiftForLite_) {
        [button shiftHorizontallyBy:208];
    }
    for (UIView* view in viewToHideForLite_) {
        view.hidden = YES;
    }
    
    CGFloat distanceToShiftUp = purchasedButton_.frame.origin.y - shareButton_.frame.origin.y;
    for (UIButton* button in buttonsToShiftUpForLite_) {
        [button shiftVerticallyBy:distanceToShiftUp];
    }
}

#pragma mark- Notification Observers

- (void)addNotificationObservers {
    [[NSNotificationCenter defaultCenter] addObserverForName:IMAGE_SELECTED_NOTIFICATION object:nil
                                                       queue:nil usingBlock:^(NSNotification *note) {
                                                           TPImageAsset* imageAsset = (TPImageAsset*)note.object;
                                                           if (!imageAsset) { // Last saved image deleted
                                                               _selectedImageAsset = nil;
                                                               imageView_.image = nil;
                                                               imageView_.hidden = YES;
                                                               imageScrollView_.hidden = YES;
                                                               [self hideSavedImagesPanelAnimated:YES];
                                                               selectPreviouslyUsedImageLabel_.hidden = YES;
                                                               [selectFromLibraryButton_ moveVerticallyTo:selectFromLibraryButton_.superview.bounds.size.height/2 - selectFromLibraryButton_.bounds.size.height];
                                                               [useCameraButton_ moveVerticallyTo:useCameraButton_.superview.bounds.size.height/2 - useCameraButton_.bounds.size.height];
                                                               canvasView.hidden = NO;
                                                           } else if (imageAsset != _selectedImageAsset) {
                                                               _selectedImageAsset = imageAsset;
                                                               imageScrollView_.hidden = YES;
                                                               imageView_.image = _selectedImageAsset.image;
                                                               canvasView.hidden = YES;
                                                           }
                                                       }];
    [[NSNotificationCenter defaultCenter] addObserverForName:SAVED_IMAGES_PANEL_DISMISSED object:nil
                                                       queue:nil usingBlock:^(NSNotification *note) {
                                                           [self hideSavedImagesPanelAnimated:NO];
                                                       }];
    [[NSNotificationCenter defaultCenter] addObserverForName:SAVED_IMAGES_PANEL_SHOULD_CLOSE object:nil
                                                       queue:nil usingBlock:^(NSNotification *note) {
                                                           [self hideSavedImagesPanelAnimated:YES];
                                                       }];
    [[NSNotificationCenter defaultCenter] addObserverForName:SHARE_IMAGES_PANEL_DISMISSED object:nil
                                                       queue:nil usingBlock:^(NSNotification *note) {
                                                           [self hideShareImagesPanelAnimated:YES];
                                                       }];
    [[NSNotificationCenter defaultCenter] addObserverForName:SLIDING_PANEL_SHOULD_CLOSE object:nil
                                                       queue:nil usingBlock:^(NSNotification *note) {
                                                           [self closeSlidingPanel];
                                                       }];
    [[NSNotificationCenter defaultCenter] addObserverForName:CONVERT_COLOR object:nil
                                                       queue:nil usingBlock:^(NSNotification *note) {
                                                           brandsSelectionController_.tpColor = note.object;
                                                           brandsSelectionController_.colorMarker = _selectedImageAsset.colorMarker;
                                                           [self showBrandsSelection];
                                                       }];
    [[NSNotificationCenter defaultCenter] addObserverForName:LOGGED_IN_TO_FACEBOOK object:nil
                                                       queue:nil usingBlock:^(NSNotification *note) {
                                                           faceBookButton_.hidden = YES;
                                                           avatarContainerView_.hidden = NO;
                                                           facebookImage_.profileID = note.object;
                                                       }];
    [[NSNotificationCenter defaultCenter] addObserverForName:COLOR_SELECTED object:nil
                                                       queue:nil usingBlock:^(NSNotification *note) {
                                                           [self askCurrentOrOriginal];
                                                       }];
    [[NSNotificationCenter defaultCenter] addObserverForName:IMAGE_DELETED_NOTIFICATION object:nil
                                                       queue:nil usingBlock:^(NSNotification *note) {
                                                           TPImageAsset* asset = note.object;
                                                           if (_selectedImageAsset == asset) {
                                                               _selectedImageAsset = nil;
                                                               imageScrollView_.imageAsset = nil;
                                                           }
                                                       }];
    [[NSNotificationCenter defaultCenter] addObserverForName:TUTORIAL_SHOULD_CLOSE object:nil
                                                       queue:nil usingBlock:^(NSNotification *note) {
                                                           [self closeTutorial];
                                                       }];
}

#pragma mark- Flurry Ads methods

float currentViewWidth, currentViewHeight;
int width, height ;
bool displayFlurryAdNow;

- (void)initFlurryAds {
//    [Flurry setDebugLogEnabled:YES];
    [FlurryAds setAdDelegate:self];
    
    // Fetch fullscreen ads early when a later display is likely. For
    // example, at the beginning of a level.
    
    width = self.view.frame.size.width;
    height = self.view.frame.size.height;
    
    //for the landscape only apps
    currentViewWidth =  MAX (width, height);
    currentViewHeight =  MIN (width, height);
    
    //for the portrait only apps no need to construct the fulurryContainer, can provide self.view.frame as the parm to fetchAdForSpace call
    
    
    self.flurryContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, currentViewWidth, currentViewHeight)];
    
    [FlurryAds fetchAdForSpace:AdSpaceName frame:self.flurryContainer.frame size:FULLSCREEN];
    
}

-(void) displayFlurryAd {
    
    if ([FlurryAds adReadyForSpace:AdSpaceName]) {
        [FlurryAds displayAdForSpace:AdSpaceName onView:self.view];
        
    } else {
        // Fetch an ad and display as son as we recived it
        displayFlurryAdNow = YES;
        [FlurryAds fetchAdForSpace:AdSpaceName frame:self.flurryContainer.frame size:FULLSCREEN];
    }
}

- (void)spaceDidReceiveAd:(NSString *)adSpace {
    NSLog(@"=========== Ad Space [%@] Did Receive Ad ================ ", adSpace);
    
    if (displayFlurryAdNow) {
        [self displayFlurryAd];
        [FlurryAds fetchAdForSpace:AdSpaceName frame:self.flurryContainer.frame size:FULLSCREEN];
    }
    displayFlurryAdNow = NO;
}

- (void)spaceDidFailToReceiveAd:(NSString *)adSpace error:(NSError *)error {
    NSLog(@"=========== Ad Space [%@] Did Fail to Receive Ad with error [%@] ================ ", adSpace, error);
    
}

- (void)spaceDidDismiss:(NSString *)adSpace interstitial:(BOOL)interstitial {
    if (interstitial) {
        NSLog(@"Flurry AdSpace: Ad dismissed");
    }
}


#pragma mark- Polygon methods

- (TPCornerMarker*)placeCornerMarkerAtLocation:(CGPoint)location {
    TPCornerMarker* marker = [[TPCornerMarker alloc] init];
    UIImageView* viewUnderMarker = [imageScrollView_ imageViewAtOffset:location.x];
    if (!polygonView_) {
        polygonView_ = [[TPPolygonView alloc] initWithFrame:imageView_.bounds];
        [viewUnderMarker addSubview:polygonView_];
        [_selectedImageAsset.colorMarker.view.superview bringSubviewToFront:_selectedImageAsset.colorMarker.view];
    }
    
    [viewUnderMarker addSubview:marker.view];
    marker.position = [viewUnderMarker convertPoint:location fromView:imageScrollView_];
    marker.cmDelegate = self;
    marker.delegate = self;
    revertButton_.enabled = YES;
    backButton.enabled = YES;
    
    return marker;
}

- (void)selectCornerMarker:(TPCornerMarker*)selectedMarker {
    for (TPCornerMarker* marker in cornerMarkers_) {
        marker.selected = marker == selectedMarker;
    }
    selectedCornerMarker_ = selectedMarker;
}

- (TPCornerMarker*)cornerMarkerAtLocation:(CGPoint)location {
    for (TPCornerMarker* marker in cornerMarkers_) {
        CGPoint locationInMarker = [marker.view convertPoint:location fromView:imageScrollView_];
        if ([marker.view hitTest:locationInMarker withEvent:nil]) {
            return marker;
        }
    }
    return nil;
}

- (bool)colorMarkerLocation:(CGPoint)location {
    CGPoint locationInMarker = [_selectedImageAsset.colorMarker.view convertPoint:location fromView:imageView_];
    return [_selectedImageAsset.colorMarker.view hitTest:locationInMarker withEvent:nil];
}

- (bool)isPolygonMode {
    return customModeButton_.selected;
}

- (bool)checkPolygon {
    if (![self isPolygonMode]) {
        return YES;
    }
    if (cornerMarkers_.count < 3) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Custom Shape Not Defined" message:@"At least 3 corner markers are needed for a custom shape." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return false;
    }
    
    CGMutablePathRef path = CGPathCreateMutable();
    for (TPCornerMarker* marker in cornerMarkers_) {
        if (marker == [cornerMarkers_ firstObject]) {
            CGPathMoveToPoint(path, NULL, marker.position.x, marker.position.y);
        } else {
            CGPathAddLineToPoint(path, NULL, marker.position.x, marker.position.y);
        }
    }
    CGPathCloseSubpath(path);
    bool colrMarkerWithin = CGPathContainsPoint(path, NULL, CGPointMake(_selectedImageAsset.colorMarker.position.x, _selectedImageAsset.colorMarker.position.y), false);
    CGPathRelease(path);
    if (!colrMarkerWithin) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Paint Roller not Positioned" message:@"Please make sure the paint roller is inside the custom shape." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return false;
    }
    
    return YES;
}


- (void)drawPolygon {
    if (cornerMarkers_.count < 1)
        return;
    
    polygonView_.corners = cornerMarkers_;
    [polygonView_ setNeedsDisplay];
}

- (void)setPolygonMode {
    clearButton_.hidden = clearAllButton_.hidden = NO;
    quickModeButton_.selected = NO;
    customModeButton_.selected = YES;
    revertButton_.enabled = !_selectedImageAsset.isOriginal;
}

- (void)setQuickMode {
    [self clearAllAction:nil];
    clearButton_.hidden = clearAllButton_.hidden = YES;
    quickModeButton_.selected = YES;
    customModeButton_.selected = NO;
    revertButton_.enabled = !_selectedImageAsset.isOriginal;
}



#pragma mark- Actions

- (IBAction)cameraAction:(id)sender {
    [self hideSavedImagesPanelAnimated:YES];
    [self selectButton:sender];
    [self addCameraController];
}

- (IBAction)pickPhotoAction:(id)sender {
    [self hideSavedImagesPanelAnimated:YES];
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            UIView* button  = sender;
            CGRect popoverRect = [self.view convertRect:button.frame
                                               fromView:button.superview];
            NSLog(@"SElf.view: %@", self.view);
            NSLog(@"SElf.view.window: %@", self.view.window);
            [popoverForImagePicker_ presentPopoverFromRect:popoverRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny  animated:YES];
        }
        else
        {
            [self presentViewController:imagePickerController_ animated:YES completion:nil];
        }
    }
}


- (IBAction)brushAction:(id)sender {
    
    if ([self checkImage] && [self checkPolygon] && [self checkMarkerAndColor]) {
        [self askCurrentOrOriginal];
    }
}

- (IBAction)colorPickerAction:(id)sender {
    [self slidingPanelActionWithSender:sender viewController:colorPickerController_ andControllerContainerView:colorPickerContainerView_];
}


- (IBAction)swatchesAction:(id)sender {
    [self slidingPanelActionWithSender:sender viewController:swatchesController_ andControllerContainerView:swatchesContainerView_];
}

- (IBAction)mySwatchesAction:(id)sender {
    [self slidingPanelActionWithSender:sender viewController:purchasedCodesController_ andControllerContainerView:purchasedCodesContainerView_];
}

- (IBAction)recentColorsAction:(id)sender {
    [self slidingPanelActionWithSender:sender viewController:recentColorsController_ andControllerContainerView:recentColorsContainerView_];
}


- (IBAction)savedImagesAction:(id)sender {
    
    _selectedImageAsset.colorMarker.colorChanged = NO;
    [self closeSlidingPanel];
    if ([[TPSavedImagesManager sharedSavedImagesManager].savedPhotos count] == 0 ) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"You have no saved images" message:@"Please select an image from your photo library" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        if (!canvasView.hidden)
            [self pickPhotoAction:selectFromLibraryButton_];
        else
            [self pickPhotoAction:photoAlbumButton_];
        return;
    }
    
    if (![self isSavedImagesPanelVisible]) {
        [self showSaveImagesPanel];
    } else {
        [self hideSavedImagesPanelAnimated:YES];
    }
}

- (IBAction)revertAction:(id)sender {
    
    if ([self isPolygonMode] &&  cornerMarkers_.count) {
        if (cornerMarkers_.count < 3) {
            [self clearAllAction:nil];
        } else {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Confirm Clear Custom Shape" message:@"Do you want to clear the custom shape?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
            alert.tag = ALERT_CLEAR_POLYGON;
            [alert show];
        }
        
    } else {
        if (!_selectedImageAsset)
            return;
        _selectedImageAsset = _selectedImageAsset.originalAsset;
        _selectedImageAsset.colorMarker.tpColor = _selectedImageAsset.tpColor;
        [[imageScrollView_ originalImageView] addSubview:_selectedImageAsset.colorMarker.view];
        _selectedImageAsset.colorMarker.position = _selectedImageAsset.colorMarker.position; //Make sure pin positions itself on the superview
        _selectedImageAsset.colorMarker.delegate = self;
        NSLog(@"revert: color marker position: %@", POINT_TO_STRING(_selectedImageAsset.colorMarker.position));
        [imageScrollView_ scrollToOriginal];
        revertButton_.enabled = NO;
        backButton.enabled = NO;
    }
    
}

- (IBAction)shareAction:(id)sender {
#ifdef TAPPAINTER_TRIAL
    if (!_selectedImageAsset || _selectedImageAsset.isOriginal) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"No Photos to Share" message:@"Please paint a wall first" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    } else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Share This Image" message:nil delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Through email", @"On Facebook", nil];
        alert.tag = SHARE_ALERT;
        alert.delegate = self;
        [alert show];
    }
#else
    if (![TPSavedImagesManager editedAssetsCount]) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"No Photos to Share" message:@"You haven't painted any walls yet" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    } else {
        [self showShareImagesPanel];
    }
#endif
}

- (IBAction)touchAndHoldAction:(id)sender {
    NSLog(@"Tound and hold action");
    CGPoint location = [sender locationInView:imageView_];
    
    if (!_selectedImageAsset.colorMarker) {
        if (CGRectContainsPoint(CGRectInset(imageView_.bounds, 60, 60), location)) {
            [self placeMarkerAtLocation:location];
        }
    } else {
        _selectedImageAsset.colorMarker.position = location;
    }
}

- (IBAction)signOutAction:(id)sender {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Do You Want to Sign Out from Facebook?" message:nil delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    alert.tag = ALERT_FACEBOOK_SIGNOUT;
    [alert show];
}

- (IBAction)facebookLogIn:(id)sender {
    if ([self checkInternetConnectionWithErrorAlert:YES]) {
        [FBHelper loginWithCompletionBlock:^(bool Success) {
        }];
    }
}

- (IBAction)faceBookLoginFromstartupScreen:(id)sender {
    if ([self checkInternetConnectionWithErrorAlert:YES]) {
        [FBHelper loginWithCompletionBlock:^(bool Success) {
            if (Success) {
                faceBookLoginScreen_.hidden = YES;
            }
        }];
    }
}


- (IBAction)skip:(id)sender {
    faceBookLoginScreen_.hidden = YES;
    if ([TPSavedImagesManager sharedSavedImagesManager].savedPhotos.count) {
        [self showSaveImagesPanel];
    }
}

- (void)slidingPanelActionWithSender:(UIButton*)button viewController:(TPColorPickerBaseViewController*)controller andControllerContainerView:(UIView*)containerView {
    if ([self checkImage] && [self checkMarker]) {
        [self hideSavedImagesPanelAnimated:YES];
        if (button.selected) {
            [self closeSlidingPanel];
        } else {
            [self showSlidingPanelWthBlock:^{
                containerView.frame = slidingPanel_.bounds;
                controller.colorMarker = _selectedImageAsset.colorMarker;
                [slidingPanel_ addSubview:containerView];
                [self selectButton:button];
            }];
        }
    }
}

- (IBAction)InAppAction:(id)sender {
    UIVideoEditorController* controller = [UIStoryboard instantiateControllerWithId:@"purchaseController"];
    self.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)clearAction:(id)sender {
    if (cornerMarkers_.count) {
        if (cornerMarkers_.count == 1) {
            [self clearAllAction:nil];
        } else {
            TPCornerMarker* marker = [cornerMarkers_ lastObject];
            [cornerMarkers_ removeLastObject];
            [marker removeFromSuperview];
            [self drawPolygon];
        }
    } else {
        NSAssert(!_selectedImageAsset.isOriginal, @"Back button should be disabled when current image is original");
        if (_selectedImageAsset == [_selectedImageAsset.editedAssets firstObject]) {
            [self revertAction:nil];
        } else {
            NSInteger index = [_selectedImageAsset.editedAssets indexOfObject:_selectedImageAsset] - 1;
            TPImageAsset* asset = _selectedImageAsset.editedAssets[index];
            [imageScrollView_ scrollToAsset:asset withCompletionBlock:^{
                [self switchToAsset:asset];
            }];
        }
    }
}

- (IBAction)clearAllAction:(id)sender {
    [cornerMarkers_ makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [cornerMarkers_ removeAllObjects];
    selectedCornerMarker_ = nil;
    [polygonView_ removeFromSuperview];
    polygonView_ = nil;
    if (_selectedImageAsset) {
        backButton.enabled = revertButton_.enabled = !_selectedImageAsset.isOriginal;
    }
}

- (IBAction)tapAction:(id)sender {
    
    if (!tutorialContainerView_.hidden) return;
    
    UITapGestureRecognizer* recognizer = sender;
    CGPoint location = [recognizer locationOfTouch:0 inView:imageView_];
    if ([self colorMarkerLocation:location]) {
        if (!_selectedImageAsset.colorMarker.tpColor) {
            // Paint with color that is under the pin
            _selectedImageAsset.colorMarker.tpColor = [[TPColor alloc] initWithWebColor:_selectedImageAsset.colorMarker.color];
        }
        [self brushAction:self];
    }
    else if ([self isPolygonMode]) {
        CGRect contentFrame = [imageScrollView_ originalImageView].contentFrame;
        if (![self cornerMarkerAtLocation:location] && location.x > contentFrame.origin.x && location.x < contentFrame.origin.x + contentFrame.size.width) {
            TPCornerMarker* marker = [self placeCornerMarkerAtLocation:[recognizer locationOfTouch:0 inView:imageScrollView_]];
            [cornerMarkers_ addObject:marker];
            [self selectCornerMarker:marker];
            [self drawPolygon];
            
            if (cornerMarkers_.count == 3) {
                [tutorialController showRemoveCornersTutorial];
            }
        }
    }
}

- (IBAction)customModeAction:(id)sender {
    if ([self checkMarker]) {
        [self setPolygonMode];
        
        [tutorialController showCornersTutorial];
    }
}


- (IBAction)quickModeAction:(id)sender {
    if ([cornerMarkers_ count]) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@" Custom Shape will be cleared" message:@"Continuing to Quick mode will clear the custom shape. Continue?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        alert.tag = ALERT_SWITCH_TO_FAST_MODE;
        [alert show];
    } else {
        clearButton_.hidden = clearAllButton_.hidden = YES;
        quickModeButton_.selected = YES;
        customModeButton_.selected = NO;
    }
}

- (IBAction)dealsAction:(id)sender {
    [self displayFlurryAd];
}

- (IBAction)tutorialAction:(id)sender {
    if (!((UIButton*)sender).selected) {
        CGRect frame = walkThroughTutorialContainerViewFrame_;
        frame.origin.y = self.view.frame.origin.y + self.view.frame.size.height;
        walkThroughTutorialContainerView_.frame = frame;
        walkThroughTutorialContainerView_.hidden = NO;
        [UIView animateWithDuration:0.5 animations:^{
            walkThroughTutorialContainerView_.frame = walkThroughTutorialContainerViewFrame_;
        }];
        [sender setSelected:YES];
    } else {
        [self closeTutorial];
    }
}

#pragma mark- UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == ALERT_FACEBOOK_SIGNOUT) {
        if (buttonIndex == 0) {
            [FBHelper signOut];
            faceBookButton_.hidden = NO;
            avatarContainerView_.hidden = YES;
        }
    } else if (alertView.tag == ALERT_APPLY_NEW_COLOR ) {
        if ([self checkInternetConnectionWithErrorAlert:YES]) {
            if (buttonIndex == 0 && [self checkPolygon]) {
                TPPin* pin = _selectedImageAsset.colorMarker;
                _selectedImageAsset = _selectedImageAsset.originalAsset;
                _selectedImageAsset.colorMarker = pin;
                [[imageScrollView_ originalImageView] addSubview:pin.view];
                pin.position = pin.position; //Make sure pin positions itself on the superview
                [self paintImage];
            } else if (buttonIndex == 2) {
                [self paintImage];
            }
        }
    } else if (alertView.tag == ALERT_SWITCH_TO_FAST_MODE) {
        if (buttonIndex == 0) {
            customModeButton_.selected = YES;
            quickModeButton_.selected = NO;
        } else {
            [self clearAllAction:nil];
            customModeButton_.selected = NO;
            quickModeButton_.selected = YES;
        }
        clearButton_.hidden = clearAllButton_.hidden = quickModeButton_.selected;
    } else if (alertView.tag == ALERT_SWITCHING_IMAGE) {
        if (buttonIndex == 0) {
            [imageScrollView_ scrollToAsset:_selectedImageAsset];
        } else {
            TPImageAsset* imageAsset = [alertView associativeObjectForKey:@"imageAsset"];
            [self clearAllAction:nil];
            [self switchToAsset:imageAsset];
        }
    } else if (alertView.tag == ALERT_CLEAR_POLYGON) {
        if (buttonIndex == 0) {
            [self clearAllAction:nil];
        }
    } else if (alertView.tag == ALERT_PAINT_NOW_OR_LATER) {
        if (buttonIndex == 0) {
            [self paintImage];
        }
    } else if (alertView.tag == USE_CREDIT_ALERT) {
        if (buttonIndex == 0) {
            [UpgradeProductEngine creditsUsed:1];
            _selectedImageAsset.colorMarker.tpColor = _selectedImageAsset.colorMarker.tpColorFromSearch;
            _selectedImageAsset.colorMarker.tpColor.purchased = YES;
            _selectedImageAsset.colorMarker.colorChanged = NO;
            [self askCurrentOrOriginal];
            [Flurry logEvent:@"Credit Used for Painting" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[_selectedImageAsset.tpColor.color hexStringFromColor], @"color", nil]];
        } else {
            // Restore color
            _selectedImageAsset.colorMarker.tpColor = _selectedImageAsset.colorMarker.tpColor;
            _selectedImageAsset.colorMarker.colorChanged = NO;
        }
        _selectedImageAsset.colorMarker.tpColorFromSearch = nil;
    } else if (alertView.tag == BUY_CREDIT_ALERT) {
        // Restore color
        _selectedImageAsset.colorMarker.tpColor = _selectedImageAsset.colorMarker.tpColor;
        _selectedImageAsset.colorMarker.colorChanged = NO;
        _selectedImageAsset.colorMarker.tpColorFromSearch = nil;
        if (buttonIndex == 0) {
            [self InAppAction:nil];
        }
    } else if (alertView.tag == SHARE_ALERT) {
        if (buttonIndex == 1) {
            MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
            [controller setSubject:@"TapPainter"];
            controller.mailComposeDelegate = self;
            [controller setMessageBody:@"See the photo I painted with TapPainter!" isHTML:NO];
            
            // Generate an image offscreen that contains asset image and the swatch stacked under it
            TPImageWithSwatchViewController* imageWithSwatchController = [[TPImageWithSwatchViewController alloc] init];
            imageWithSwatchController.imageAsset = _selectedImageAsset;
            UIGraphicsBeginImageContext(imageWithSwatchController.view.frame.size);
            [[imageWithSwatchController.view layer] renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            NSData* imageData = UIImageJPEGRepresentation(screenshot,0);
            [controller addAttachmentData:imageData mimeType:@"image/jpeg" fileName:@"PaintedPhoto"];
            
            [self presentViewController:controller animated:YES completion:^{
            }];
        } else if (buttonIndex == 2) {
            [FBHelper postToWallWithImageAsset:_selectedImageAsset];
        }
    }
}

#pragma mark - MFMessageComposeViewControllerDelegate methods

-(void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
    if (result == MFMailComposeResultSent) {
        [Flurry logEvent:@"Image Shared" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"email", @"via", nil]];
    } else {
    }
}


#pragma mark- UIGestureRecignizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer == longPressRecognizer_) {
        CGPoint location = [touch locationInView:imageView_];
        return ![self isSavedImagesPanelVisible] && _selectedImageAsset && _selectedImageAsset.colorMarker == nil && (CGRectContainsPoint(CGRectInset(imageView_.bounds, 60, 60), location));
    } else if (gestureRecognizer == tapRecognizerForCornerMarker_) {
        CGPoint location = [touch locationInView:imageScrollView_];
        TPCornerMarker* marker = [self cornerMarkerAtLocation:location];
        if (marker) {
            [self selectCornerMarker:marker];
            return NO;
        }
        return YES;
    }
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == longPressRecognizer_) {
        return ![self isSavedImagesPanelVisible] && _selectedImageAsset && _selectedImageAsset.colorMarker == nil;
    } 
    return YES;
}

#pragma mark- TPDraggablePinIconDelegate

- (void)startedDragging {
    [self hideSavedImagesPanelAnimated:YES];
}

- (TPPin*)placePinAtLocation:(CGPoint)location {
    TPPin* pin = [[TPPin alloc] init];
    [[imageScrollView_ imageViewAtLocation:location] addSubview:pin.view];
    pin.position = location;
    return pin;
}

- (void)pinAdded:(TPPin *)pin {
    _selectedImageAsset.colorMarker = pin;
    pin.delegate = self;
    addMarkerButton_.enabled = NO;
    draggablePinIcon_.hidden = YES;
}

#pragma mark- TPImageScrollViewDelegate

- (void)selectedAssetChanged:(TPImageAsset *)imageAsset {
    if (_selectedImageAsset != imageAsset) {
        if (cornerMarkers_.count) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@" Shape will be cleared" message:@"Custom shape will be lost if you continue. Continue?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            alert.tag = ALERT_SWITCHING_IMAGE;
            [alert setAssociativeObject:imageAsset forKey:@"imageAsset"];
            [alert show];
        } else {
            [self switchToAsset:imageAsset];
        }
    }
}

#pragma mark- TPPinDelegate

- (void)pinStartedDragging:(TPPin *)pin {
    imageScrollView_.scrollEnabled = NO;
}

- (void)pinStoppedDragging:(TPPin *)pin {
    imageScrollView_.scrollEnabled = YES;
    if (pin == selectedCornerMarker_) {
        [magnifyingGlass_.view removeFromSuperview];
        magnifyingGlass_ = nil;
    } else {
        [tutorialController showSelectColorTutorial];
    }
}

#pragma mark- TPCornerMarkerDelegate

- (void)cornerMarkerMoved:(TPCornerMarker *)marker {
    [self drawPolygon];
    if (!magnifyingGlass_) {
        magnifyingGlass_ = [[TPMagnifyingGlass alloc] init];
        [magnifyingGlass_ view];
        [marker.view.superview addSubview:magnifyingGlass_.view];
        magnifyingGlass_.viewWithImage = [imageScrollView_ imageViewAtLocation:marker.position];
   }
    int x;
    if (marker.view.frame.origin.x > magnifyingGlass_.view.frame.size.width) {
        x = marker.position.x - marker.view.frame.size.width/8 - magnifyingGlass_.view.frame.size.width/2;
    } else {
        x = marker.position.x + marker.view.frame.size.width/8 + magnifyingGlass_.view.frame.size.width/2;
    }
    int y;
    if (marker.view.frame.origin.y  >  magnifyingGlass_.view.frame.size.height) {
        y = marker.position.y - marker.view.frame.size.height/8 - magnifyingGlass_.view.frame.size.height/2;
    } else {
        y = marker.position.y + marker.view.frame.size.height/8 + magnifyingGlass_.view.frame.size.height/2;
    }
    magnifyingGlass_.view.center = CGPointMake(x, y);
    [magnifyingGlass_ grabFromPosition:marker.position];
}

//- (void)cornerMarkerSelected:(TPCornerMarker *)marker {
//    [self selectCornerMarker:marker];
//}
//
#pragma mark- TPImageAssetProcessingDelegate

- (void)imageAsset:(TPImageAsset *)imageAsset processStepName:(NSString *)stepName {
    progressBar_.progress = 0;
    progressLabel_.text = [@"Processing Picture..." stringByAppendingString:stepName];
}

- (void)imageAsset:(TPImageAsset *)imageAsset progress:(float)progress {
    progressBar_.progress = progress;
}

#pragma mark- UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSLog(@"Media info: %@", info);
    UIImage* image = [[info objectForKey:UIImagePickerControllerOriginalImage] scaleWithAspectFitAndFixOrinetationToSize:CGSizeMake(640, 480)];
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        savingImageView_.hidden = NO;
        [cameraContainerView_ bringSubviewToFront:savingImageView_];
//        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [[TPSavedImagesManager alAssetLibrary] writeImageToSavedPhotosAlbum:image.CGImage
                                                                orientation:ALAssetOrientationUp
                                                            completionBlock:^(NSURL *assetURL, NSError *error) {
                                  NSLog(@"assetURL %@", assetURL);
                                  if (assetURL) {
                                      _selectedImageAsset = [TPSavedImagesManager imageAssetWithAssetURL:assetURL];
                                      if (!_selectedImageAsset.image) {
                                          [_selectedImageAsset addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:nil];
                                      }
                                      [TPSavedImagesManager saveOriginalAsset:_selectedImageAsset];
                                      [TPSavedImagesManager setSelectedImageAsset:_selectedImageAsset];
                                  } else if ([ALAssetsLibrary authorizationStatus] != ALAuthorizationStatusAuthorized) {
                                      [self showAlertWithTitle:@"Can't Save Image" andMessage:@"TapPainter does not have access to your photos. Please enable access your device's Privacy Settings."];
                                      
                                  } else {
                                      [self showAlertWithTitle:@"Can't Save Image" andMessage:@"Unknown error tyring to save picture in your Photo Library."];
                                  }
                                  [self removeCameraController];
                                  savingImageView_.hidden = YES;
                                  imageView_.image = nil;
                             }];
    } else {
        _selectedImageAsset = [TPSavedImagesManager imageAssetWithAssetURL:[info objectForKey:UIImagePickerControllerReferenceURL]];
        canvasView.hidden = YES;
    }
    imageView_.hidden = NO;
    imageView_.image = image;
    imageScrollView_.hidden = YES;
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        [self removeCameraController];
    } else {
        [popoverForImagePicker_ dismissPopoverAnimated:YES];
    }
}

#pragma mark- UIPopoverControllerDelegate

- (void)popoverController:(UIPopoverController *)popoverController willRepositionPopoverToRect:(inout CGRect *)rect inView:(inout UIView *__autoreleasing *)view {
    
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
    return YES;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    if (_selectedImageAsset) {
#ifdef TAPPAINTER_TRIAL
        [TPSavedImagesManager deleteEditedAssetsForAsset:_selectedImageAsset];
#endif
        [TPSavedImagesManager setSelectedImageAsset:_selectedImageAsset];
        [TPSavedImagesManager saveOriginalAsset:_selectedImageAsset];
        if (!_selectedImageAsset.image) {
            [_selectedImageAsset addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:nil];
        } else {
            // Trigger the observer to start background upload
            //        self.selectedImage = _selectedImage;
            [self loadSelectedImageAsset];
        }
    } else {
        if ([TPSavedImagesManager sharedSavedImagesManager].savedPhotos.count) {
            [self showSaveImagesPanel];
        }
    }
}

#pragma mark -
#pragma mark Touch Event Functions

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch* touch = [touches anyObject];
    NSLog(@"Touches Began: %@", [self class]);
    
    if ([self isSlidingPanelVisible]) {
        CGPoint location = [touch locationInView:slidingPanel_];
        CGRect rect = CGRectInset(slidingPanel_.bounds, -50, 0);
        if (!CGRectContainsPoint(rect, location)) {
            [self closeSlidingPanel];
            return;
        }
    } else if ([self isSavedImagesPanelVisible]) {
        CGPoint location = [touch locationInView:savedImagesPanelView_];
        if (!CGRectContainsPoint(savedImagesPanelView_.bounds, location)) {
            [self hideSavedImagesPanelAnimated:YES];
            return;
        }
    }
    [super touchesBegan:touches withEvent:event];
    
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
}

#pragma mark - Observers
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"image"]) {
        [self loadSelectedImageAsset];
    } else if ([keyPath isEqualToString:@"numberOfCredits"]) {
        [self displayNumberOfCredits];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
