//
//  TPTutorialSlideshowController.m
//  Tappainter
//
//  Created by Vadim Dagman on 3/3/14.
//  Copyright (c) 2014 MDi Touch. All rights reserved.
//

#import "TPTutorialSlideshowController.h"
#import "TPTutorialSlideController.h"
#import "TPAppDefs.h"
#import "UtilityCategories.h"

#ifdef TAPPAINTER_TRIAL
#define SLIDES_CONTROLLER_NAME @"tutorialSlideControllerTrial"
#else
#define SLIDES_CONTROLLER_NAME @"tutorialSlideController"
#endif


@interface TPTutorialSlideshowController () {
    int numberOfSlides_;
    IBOutlet UIPageControl *pageControl_;
    UIPageViewController* pageViewController_;
    __weak IBOutlet UIView *pageControlContainerView_;
    __weak IBOutlet UIButton *tutorialButton_;
}

@end

@implementation TPTutorialSlideshowController

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
    TPTutorialSlideController* startingController = [self.storyboard instantiateViewControllerWithIdentifier:SLIDES_CONTROLLER_NAME];
    [startingController view];
    numberOfSlides_ = startingController.numberOfSlides;
    startingController.slideIndex = 0;
    pageControl_.numberOfPages = numberOfSlides_;
    pageControlContainerView_.layer.cornerRadius = 10;
    
    pageViewController_ = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    pageViewController_.dataSource = self;
    pageViewController_.delegate = self;
    // We need to cover all the control by making the frame taller (+ 37)
    [[pageViewController_ view] setFrame:CGRectMake(0, 0, [[self view] bounds].size.width, [[self view] bounds].size.height + 37)];
    [self addChildViewController:pageViewController_];
    [[self view] addSubview:[pageViewController_ view]];
    [pageViewController_ didMoveToParentViewController:self];
    
    
    NSArray *viewControllers = @[startingController];
    [pageViewController_ setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    
    CGRect bounds = pageControlContainerView_.bounds;
    bounds.size.width = [pageControl_ sizeForNumberOfPages:numberOfSlides_].width + 20;
    pageControlContainerView_.bounds = bounds;
    
    [self.view bringSubviewToFront:pageControlContainerView_];
//#ifdef TAPPAINTER_TRIAL
//    [tutorialButton_ shiftVerticallyBy:-74];
//#endif
    [self.view bringSubviewToFront:tutorialButton_];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    int index = ((TPTutorialSlideController*) viewController).slideIndex;
    
    if ((index == 0) || (index == (int)NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    int index = ((TPTutorialSlideController*) viewController).slideIndex;
    
    if (index == (int)NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == ((TPTutorialSlideController*) viewController).numberOfSlides) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (TPTutorialSlideController*)viewControllerAtIndex:(int)index {
    TPTutorialSlideController* controller = [self.storyboard instantiateViewControllerWithIdentifier:SLIDES_CONTROLLER_NAME];
    controller.slideIndex = index;
    return controller;
}


- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return numberOfSlides_;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

#pragma mark- UIPageViwControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
    tutorialButton_.hidden = YES;
}

- (void)pageViewController:(UIPageViewController *)pvc didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (completed) {
        TPTutorialSlideController* controller = [pvc.viewControllers lastObject];
        pageControl_.currentPage = controller.slideIndex;
    }
    tutorialButton_.hidden = NO;
}

#pragma mark- Action

- (IBAction)closeTutorial:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:TUTORIAL_SHOULD_CLOSE object:nil];
}


@end
