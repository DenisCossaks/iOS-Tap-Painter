//
//  TPCustomCameraViewController.m
//  Tappainter
//
//  Created by Vadim on 9/30/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import "TPCustomCameraViewController.h"
#import "UtilityCategories.h"
#import "TPViewController.h"

@interface TPCustomCameraViewController () {
    CGRect frame_;
}

@end

@implementation TPCustomCameraViewController

- (id)initWithFrame:(CGRect)frame {
    self = [super init];
    if (self) {
        frame_ = frame;
    }
    return self;
}

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
    self.view.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.view.frame = frame_;
    self.view.hidden = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
}

@end
