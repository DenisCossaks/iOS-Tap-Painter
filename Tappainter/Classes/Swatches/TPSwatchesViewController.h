//
//  TPSwatchesViewController.h
//  Tappainter
//
//  Created by Vadim on 11/2/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"
#import "TPColorPickerBaseViewController.h"
#import "TPSwatchView.h"

@interface TPSwatchesViewController : TPColorPickerBaseViewController<iCarouselDataSource, iCarouselDelegate, TPSwatchViewDelegate, UITextFieldDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate, UITableViewDelegate>

@end
