//
//  TPTutorialSlideController.m
//  Tappainter
//
//  Created by Vadim Dagman on 3/3/14.
//  Copyright (c) 2014 MDi Touch. All rights reserved.
//

#import "TPTutorialSlideController.h"

@interface TPTutorialSlideController () {
    
    IBOutletCollection(UIView) NSArray *slideViews_;
    IBOutletCollection(UILabel) NSArray *textLabels_;
}

@end

@implementation TPTutorialSlideController

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
    UIView* visibleView = [self.view viewWithTag:_slideIndex+100];
    visibleView.hidden = NO;
    for (UILabel* label in textLabels_) {
        NSLog(@"Label text: %@ size %f", label.text, label.font.pointSize);
        UIFont* font = [UIFont fontWithName:@"MuseoSans-700" size:label.font.pointSize];
        label.font = font;
        label.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- External Methods

- (int)numberOfSlides {
    return(int)slideViews_.count;
}

@end
