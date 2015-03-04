//
//  TPImageWithSwatchViewController.m
//  Tappainter
//
//  Created by Vadim on 12/8/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import "TPImageWithSwatchViewController.h"
#import "TPColorCell.h"

// Optimum dimensions to post to Facebook with no cropping
#define OPTIMUM_WIDTH 640; // 917; //750.0
#define OPTIMUM_HEIGHT 480; //480; //403.0

@interface TPImageWithSwatchViewController () {
    
    __weak IBOutlet UIView *containerForImageView_;
    __weak IBOutlet UIImageView *imageView_;
    __weak IBOutlet TPColorCell *colorCell_;
}

@end

@implementation TPImageWithSwatchViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)setImageAsset:(TPImageAsset *)imageAsset {
    [self setImageAsset:imageAsset keepOriginalSize:NO];
}

- (void)setImageAsset:(TPImageAsset *)imageAsset keepOriginalSize:(BOOL)keepOriginalSize {
    CGFloat height = keepOriginalSize ? imageAsset.image.size.height : OPTIMUM_HEIGHT;
    CGFloat width = keepOriginalSize ? imageAsset.image.size.width : OPTIMUM_WIDTH;
    self.view.bounds = CGRectMake(0, 0, width, height); //optimium size to post to Facebook with no cropping
    
    if (imageAsset.tpColor) {
        colorCell_.tpColor = imageAsset.tpColor;
    } else {
        colorCell_.hidden = YES;
    }
    CGRect rect = colorCell_.frame;
    rect.origin.y = height - rect.size.height;
    colorCell_.frame = rect;
    
    containerForImageView_.frame = self.view.bounds;
    rect = imageView_.frame;
    rect.size = imageAsset.image.size;
//    rect.size.width = OPTIMUM_WIDTH;
//    rect.size.height = imageAsset.image.size.height*OPTIMUM_WIDTH/imageAsset.image.size.width;
    rect.size.width = width;
    rect.size.height = height; //imageAsset.imageSize.height*width/imageAsset.imageSize.width;
//    imageView_.frame = rect;
//    containerForImageView_.frame =imageView_.bounds;
    self.view.frame = rect;
    imageView_.image = imageAsset.image;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
