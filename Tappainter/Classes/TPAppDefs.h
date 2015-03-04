//
//  TPAppDefs.h
//  TapPainter specific defines and macros
//

// Notification messages
//
#define SLIDING_PANEL_SHOULD_CLOSE @"SlidingPanelShouldClose"
#define SLIDING_PANEL_WILL_CLOSE @"SlidingPanelWillClose"
#define SLIDING_PANEL_WILL_OPEN @"SlidingPanelWillOpen"
#define COLOR_ADDED @"ColorAdded"
#define COLOR_DELETED @"ColorDeleted"
#define COLOR_SELECTED @"ColorSelected"
#define CONVERT_COLOR @"ConvertColor"
#define CODE_REVEALED @"CodeRevealed"
#define IMAGE_SELECTED_NOTIFICATION @"ImageSelected"
#define IMAGE_DELETED_NOTIFICATION @"ImageDeleted"
#define SAVED_IMAGES_PANEL_DISMISSED @"SaveImagesPanelDismissed"
#define SAVED_IMAGES_PANEL_DID_APPEAR @"SaveImagesPanelDidAppear"
#define SAVED_IMAGES_PANEL_WILL_CLOSE @"SaveImagesPanelWillClose"
#define SAVED_IMAGES_PANEL_SHOULD_CLOSE @"SaveImagesPanelShouldClose"
#define SHARE_IMAGES_PANEL_DID_APPEAR @"ShareImagesPanelDidAppear"
#define SHARE_IMAGES_PANEL_DISMISSED @"ShareImagesPanelDismissed"
#define LOGGED_IN_TO_FACEBOOK @"LoggedInToFacebook"
#define BRANDS_UPDATED @"BrandsUpdated"
#define BRAND_SELECTED @"BrandSelected"
#define TUTORIAL_SHOULD_CLOSE @"TutorialShouldClose"

#define TAPPAINTER_STANDARD_URL @"https://itunes.apple.com/us/app/tappainter/id835306599?ls=1&mt=8"

@class TPTutorialController;
extern TPTutorialController* tutorialController;