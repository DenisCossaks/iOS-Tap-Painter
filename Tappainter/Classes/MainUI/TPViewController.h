//
//  TPViewController.h
//  Tappainter
//
//  Created by Vadim on 9/15/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPDraggablePinIcon.h"
#import "TPImageAsset.h"
#import "TPPin.h"
#import "TPImageScrollView.h"
#import "TPCornerMarker.h"
#import <MessageUI/MessageUI.h>

//@protocol KZDefaultColorControllerDelegate;
@class TPCustomCameraViewController;
@class KZColorPicker;

@interface TPViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPopoverControllerDelegate,TPImageAssetProcessingDelegate,UIGestureRecognizerDelegate, TPDraggablePinIconDelegate, TPPinDelegate, TPImageScrollViewDelegate, TPCornerMarkerDelegate, MFMailComposeViewControllerDelegate> {
}

+ (void)presentBuyCredistController;

@end
