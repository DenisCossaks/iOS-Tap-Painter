//
//  TPMagnifyingGlass.m
//  Tappainter
//
//  Created by Vadim on 2/1/14.
//  Copyright (c) 2014 MDi Touch. All rights reserved.
//

#import "TPMagnifyingGlass.h"
#import "TPImageView.h"

#define SCALE 1.5

@interface TPMagnifyingGlass () {
    
    __weak IBOutlet UIImageView *magnifiedImageView_;
}

@end

@implementation TPMagnifyingGlass

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
    magnifiedImageView_.layer.cornerRadius = magnifiedImageView_.frame.size.width/2;
    magnifiedImageView_.clipsToBounds = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)grabFromPosition:(CGPoint)position {
    position.x -= _viewWithImage.contentFrame.origin.x;
    float heightRatio = _viewWithImage.image.size.height/_viewWithImage.contentFrame.size.height;
    float widthRatio = _viewWithImage.image.size.width/_viewWithImage.contentFrame.size.width;
    float width = magnifiedImageView_.frame.size.width/SCALE * widthRatio;
    float height = magnifiedImageView_.frame.size.height/SCALE * heightRatio;
    position.x *= widthRatio;
    position.y *= heightRatio;
    CGRect rect = CGRectMake(position.x - width/SCALE/2.0, position.y - height/SCALE/2.0, width/SCALE, height/SCALE);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(_viewWithImage.image.CGImage, rect);
    // or use the UIImage wherever you like
    [magnifiedImageView_ setImage:[UIImage imageWithCGImage:imageRef]];
    CGImageRelease(imageRef);
}

@end
