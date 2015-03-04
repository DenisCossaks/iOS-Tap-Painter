//
//  TPSwatchesViewController.m
//  Tappainter
//
//  Created by Vadim on 11/2/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import "TPSwatchesViewController.h"
#import "TPSwatchView.h"
#import "TPRoundedButton.h"
#import "TPPin.h"
#import "TPBrandsManager.h"
#import "TPBrandData.h"
#import "TPHueSlider.h"
#import "TPColor.h"
#import "TPSavedColors.h"
#import "TPAppDefs.h"
#import "TPSingleSwatchViewController.h"
#import "UtilityCategories.h"
#import "TPCodeSearchCell.h"

//#define NUMBER_OF_ITEMS 40
#define NUMBER_OF_INVISIBLE_ITEMS_BOTTOM 0
#define NUMBER_OF_INVISIBLE_ITEMS_TOP 0
#define NUMBER_OF_PLACEHOLDER_ITEMS 0
#define TOP_SCROLL_OFFSET 5
#define BOTTOM_SCROLL_OFFSET 0

@interface TPSwatchesViewController () {
    
    __weak IBOutlet iCarousel *carousel_;
    __weak IBOutlet UIView *viewForSingleSwatch_;
    __weak IBOutlet UIView *carouselContainerView_;
    IBOutlet TPSwatchView *singleSwatchPlaceHolderView_;
    __weak IBOutlet UIButton *backButton_;
    __weak IBOutlet UIView *swatchInDeckPlaceholder_;
    int numberOfItems_;
    TPSwatchView* selectedSwatch_;
    __weak IBOutlet TPHueSlider *hueSlider_;
    __weak IBOutlet UIView *sliderPlaceholderView_;
    bool caruouselBeingDragged_;
    TPBrandData* currentBrandData_;
    __weak IBOutlet UILabel *downloadingSwatchesLabel_;
    __weak IBOutlet UIButton *brandsButton_;
    __weak IBOutlet TPRoundedButton *codeButton_;
    __weak IBOutlet UIView *enterCodeView_;
    __weak IBOutlet UIView *brandNameView_;
    __weak IBOutlet UITextField *codeTextField_;
    NSString* codePrefix_;
    __weak IBOutlet UIView *throbberView_;
    __weak IBOutlet UIActivityIndicatorView *activtyIndictor_;
    __weak IBOutlet UIView *searchBarContainerView_;
    NSArray* codeMatches_;
    UIActivityIndicatorView* activityIndicator_;
}

@end

@implementation TPSwatchesViewController

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
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
	// Do any additional setup after loading the view.
    carousel_.type = iCarouselTypeCoverFlow2;
    carousel_.vertical = YES;
    carousel_.perspective = -1.0f/1200.0f;
    carousel_.centerItemWhenSelected = NO;
    carousel_.stopAtItemBoundary = NO;
    hueSlider_.hidden = YES;
    hueSlider_.value = 0.5;
    //Make slider vertical
    hueSlider_.transform=CGAffineTransformRotate(hueSlider_.transform,-270.0/180*M_PI);
    hueSlider_.frame =  sliderPlaceholderView_.frame;
    // Register for the event that our custom slider will send when user tapped on a bar to jump to a new positin instead of dragging
    [hueSlider_ addTarget:self action:@selector(hueSliderValueJumpedAction:) forControlEvents:UIControlEventTouchDown];
    
    [self.searchDisplayController.searchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"SearchBarBackground"] forState:UIControlStateNormal];
    [self.searchDisplayController.searchBar setBackgroundImage:[UIImage imageNamed:@"SearchBarBackground"]];
    searchBarContainerView_.layer.cornerRadius = 7.0;
    
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"CodeSearchCell" bundle:nil] forCellReuseIdentifier:@"codeSearchCell"];
    self.searchDisplayController.searchResultsTableView.backgroundColor = [UIColor colorWithRed:41.0/255.9 green:47.0/255.0 blue:61.0/255.0 alpha:1];
    self.searchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    activityIndicator_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator_.hidesWhenStopped = YES;
    
   
    [[NSNotificationCenter defaultCenter] addObserverForName:SLIDING_PANEL_WILL_CLOSE object:nil  queue:nil usingBlock:^(NSNotification *note) {
        [self hideCodePanel];
        [codeTextField_ resignFirstResponder];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:SLIDING_PANEL_WILL_OPEN object:nil  queue:nil usingBlock:^(NSNotification *note) {
        if ([TPBrandsManager currentBrand]) {
            [brandsButton_ setTitle:[TPBrandsManager brandNameForId:[TPBrandsManager currentBrand]] forState:UIControlStateNormal];
            if (!selectedSwatch_) {
                [self reloadCarousel];
            }
        }
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:BRANDS_UPDATED object:nil queue:nil usingBlock:^(NSNotification *note) {
        if ([TPBrandsManager currentBrand]) {
            [brandsButton_ setTitle:[TPBrandsManager brandNameForId:[TPBrandsManager currentBrand]] forState:UIControlStateNormal];
            if (!selectedSwatch_) {
                [self reloadCarousel];
            }
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [brandsButton_ setTitle:[TPBrandsManager brandNameForId:[TPBrandsManager currentBrand]] forState:UIControlStateNormal];
    currentBrandData_ = [TPBrandsManager currentBrandData];
    hueSlider_.hidden = YES;
    if (!currentBrandData_) {
        downloadingSwatchesLabel_.text = @"";
        throbberView_.hidden = NO;
        activtyIndictor_.hidden = YES;
        carousel_.hidden = YES;
       [brandsButton_ setTitle:@"Select a brand" forState:UIControlStateNormal];
    } else if (currentBrandData_.status == ktpBrandDataStatusDownloading) {
        downloadingSwatchesLabel_.text = @"Downloading swatches library...";
        throbberView_.hidden = NO;
        activtyIndictor_.hidden = NO;
        carousel_.hidden = YES;
       if (currentBrandData_) {
            [currentBrandData_ addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        }
    } else if (currentBrandData_.status == ktpBrandDataStatusError) {
        downloadingSwatchesLabel_.text = @"Coming soon";
        throbberView_.hidden = NO;
        activtyIndictor_.hidden = YES;
        carousel_.hidden = YES;
    } else {
        [self reloadCarousel];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (int)indexToSwatchNumber:(int)index{
    return index + NUMBER_OF_PLACEHOLDER_ITEMS/2 - NUMBER_OF_INVISIBLE_ITEMS_TOP;
}

- (int)placeHolderIndexToSwatchNumber:(int)index {
    return index - NUMBER_OF_INVISIBLE_ITEMS_TOP;
}

#pragma mark- iCarouselDataSource

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return numberOfItems_;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    
    TPPageData* pageData = currentBrandData_.pages[[self indexToSwatchNumber:(int)index]];
    //create new view if no view is available for recycling
    if (view == nil)
    {
        view = [[TPSwatchView alloc] initWithPageData:pageData];
    }
    else
    {
        TPSwatchView* swatchView = (TPSwatchView*)view;
        swatchView.pageData = pageData;
    }
    
    view.tag = [self indexToSwatchNumber:(int)index];
    return view;
}

- (CGFloat)carousel:(iCarousel *)_carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    //customize carousel display
    switch (option)
    {
//        case iCarouselOptionVisibleItems:
//            return 40;
//            break;
            
        case iCarouselOptionWrap:
        {
            //normally you would hard-code this to YES or NO
            return YES;
        }
        case iCarouselOptionSpacing:
        {
            //add a bit of spacing between the item views
            return value * 1.6f;
        }
        case iCarouselOptionFadeMax:
        {
                //set opacity based on distance from camera
                return 0.0f;
        }
        default:
        {
            return value;
        }
    }
}

- (NSUInteger)numberOfPlaceholdersInCarousel:(iCarousel *)carousel
{
    //note: placeholder views are only displayed on some carousels if wrapping is disabled
    return NUMBER_OF_PLACEHOLDER_ITEMS;
}

- (UIView *)carousel:(iCarousel *)carousel placeholderViewAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    
    TPPageData* pageData = currentBrandData_.pages[[self placeHolderIndexToSwatchNumber:(int)index]];
    //create new view if no view is available for recycling
    if (view == nil)
    {
        view = [[TPSwatchView alloc] initWithPageData:pageData];
    }
    else
    {
        TPSwatchView* swatchView = (TPSwatchView*)view;
        swatchView.pageData = pageData;
    }
    
    view.tag = [self placeHolderIndexToSwatchNumber:(int)index];
    if (index < NUMBER_OF_INVISIBLE_ITEMS_TOP) {
        view.alpha = 0;
    } else {
        view.alpha = 1;
    }
    
    return view;
}

#pragma mark- iCarouselDelegate

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    UIView* view = [carousel_ itemViewAtIndex:index];
    NSLog(@"Item selected: %ld", (long)view.tag);
    [self animateSwatchSelection:(TPSwatchView*)view];
}

- (void)carouselDidScroll:(iCarousel *)carousel {
    if (caruouselBeingDragged_) {
        hueSlider_.value = [self sliderValueFromIndex:(int)carousel_.currentItemIndex];
    }
}

- (void)carouselWillBeginDragging:(iCarousel *)carousel {
    caruouselBeingDragged_ = true;
}

- (void)carouselDidEndDecelerating:(iCarousel *)carousel {
    if (caruouselBeingDragged_) {
        hueSlider_.value = [self sliderValueFromIndex:(int)carousel_.currentItemIndex];
    }
    caruouselBeingDragged_ = false;
}

#pragma mark- Other Methods

- (void)animateSwatchSelection:(TPSwatchView*)swatchView {
    [self hideCodePanel];
    brandNameView_.hidden = YES;
    codeButton_.hidden = YES;
    
    selectedSwatch_ = [self cloneSwatch:swatchView];
    selectedSwatch_.pageData.selectedSwatch = 0;
    UIView* superview = selectedSwatch_.superview;
    viewForSingleSwatch_.frame = carousel_.frame;
    CGPoint center = [viewForSingleSwatch_.superview convertPoint:carousel_.center fromView:carousel_.superview];
    viewForSingleSwatch_.center = center;
    [viewForSingleSwatch_ addSubview:superview];
    
    // Now let's see where the the swatch view will end up after we revert the transofrms. We will move the super view in the opposite direction so that the swatch always remains in place
    UIView* view = [[UIView alloc] initWithFrame:superview.frame];
    CGRect frameBeforeTransform = view.frame;
    view.layer.transform = superview.layer.transform;
    CGRect frameAfterTransform = view.frame;
    
    // We will need to move the container in the opposite direction to keep the swatch view  steady in place
    CGRect frame = viewForSingleSwatch_.frame;
    frame.origin.y += frameAfterTransform.origin.y - frameBeforeTransform.origin.y;
    frame.origin.x += frameAfterTransform.origin.x - frameBeforeTransform.origin.x;

    // We also want to scale the swatch to fill up the screen
    CGRect swatchPlaceHolderFrame = singleSwatchPlaceHolderView_.frame;
    swatchPlaceHolderFrame.origin.y -= frameAfterTransform.origin.y - frameBeforeTransform.origin.y;
    swatchPlaceHolderFrame.origin.x -= frameAfterTransform.origin.x - frameBeforeTransform.origin.x;
    
    viewForSingleSwatch_.hidden = NO;
    selectedSwatch_.transformInCarousel = superview.layer.transform; // Save transform to get animate it back later
    selectedSwatch_.frameInCarousel = superview.frame;
    hueSlider_.hidden = YES;
    [UIView animateWithDuration:1 animations:^{
        carousel_.alpha = 0;
        superview.layer.transform = CATransform3DIdentity;
        superview.frame = swatchPlaceHolderFrame;
        viewForSingleSwatch_.frame = frame;
    } completion:^(BOOL finished) {
        backButton_.hidden = NO;
        selectedSwatch_.colorMarker = self.colorMarker;
        [selectedSwatch_ enableSelection:YES];
        selectedSwatch_.delegate = self;
        viewForSingleSwatch_.userInteractionEnabled = YES;
        carousel_.userInteractionEnabled = NO;
    }];
}

- (TPSwatchView*)cloneSwatch:(TPSwatchView*)swatchView {
    UIView* container = [[UIView alloc] initWithFrame:swatchView.originalFrame];
    container.center = carousel_.centerOfInsertion;
//    TPSwatchView* cloneSwatch = [[TPSwatchView alloc] initWithHue:swatchView.hue andNumberOfColors:swatchView.numberOfColors];
    TPSwatchView* cloneSwatch = [[TPSwatchView alloc] initWithPageData:swatchView.pageData];
    [container addSubview:cloneSwatch];
    [carousel_ addSubview:container];
    container.layer.transform = swatchView.superview.layer.transform;
    return cloneSwatch;
}

- (float)sliderValueFromIndex:(int)index {
    return (float)(index - TOP_SCROLL_OFFSET)/(float)(currentBrandData_.pages.count-TOP_SCROLL_OFFSET+BOTTOM_SCROLL_OFFSET);
}

- (int)indexFromSliderValue:(float)value {
    return TOP_SCROLL_OFFSET+floor(value/1.0*(currentBrandData_.pages.count-TOP_SCROLL_OFFSET+BOTTOM_SCROLL_OFFSET));
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    id value = [change objectForKey:NSKeyValueChangeNewKey];
    if ([value integerValue] == ktpBrandDataStatusInitialized) {
        [self reloadCarousel];
    }
}

- (void)reloadCarousel {
    currentBrandData_ = [TPBrandsManager currentBrandData];
    if (currentBrandData_) {
        numberOfItems_ = (int)currentBrandData_.pages.count + NUMBER_OF_INVISIBLE_ITEMS_BOTTOM - (NUMBER_OF_PLACEHOLDER_ITEMS/2 -NUMBER_OF_INVISIBLE_ITEMS_TOP);
        [carousel_ reloadData];
        [carousel_ scrollToItemAtIndex:currentBrandData_.pages.count/2 animated:NO];
        if (currentBrandData_.pages.count) {
            [hueSlider_ setGradientFromBrandData:currentBrandData_];
            hueSlider_.value = 0.5;
            hueSlider_.hidden = selectedSwatch_ != nil;
            throbberView_.hidden = YES;
            carousel_.hidden = NO;
        } else {
            [currentBrandData_ addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        }
        //    else {
        //        downloadingSwatchesLabel_.text = @"Selecting from swatches library is not available for that brand";
        //        throbberView_.hidden = NO;
        //        hueSlider_.hidden = YES;
        //    }
    }
}

- (void)openCodePanel {
    if ( enterCodeView_.frame.origin.y < brandNameView_.frame.origin.y+brandNameView_.frame.size.height) {
        [codeButton_ setTitle:@"Cancel" forState:UIControlStateNormal];
        if ([TPBrandsManager currentBrandData].codePrefix) {
            codePrefix_ = [TPBrandsManager currentBrandData].codePrefix;
            codeTextField_.text = codePrefix_;
        } else {
            codePrefix_ = nil;
            codeTextField_.text = @"";
        }
        [UIView animateWithDuration:0.5 animations:^{
            [enterCodeView_ moveVerticallyTo:brandNameView_.frame.origin.y+brandNameView_.frame.size.height];
        }];
    }
}

- (void)hideCodePanel {
    if ( enterCodeView_.frame.origin.y == brandNameView_.frame.origin.y+brandNameView_.frame.size.height) {
        [self.searchDisplayController setActive:NO animated:YES];
        [codeButton_ setTitle:@"Search" forState:UIControlStateNormal];
        codeMatches_ = nil;
        [self.searchDisplayController.searchResultsTableView reloadData];
        [UIView animateWithDuration:0.5 animations:^{
            [enterCodeView_ moveVerticallyTo:brandNameView_.frame.origin.y-enterCodeView_.frame.size.height];
        }];
    }
}

- (void)setColorMarker:(TPPin *)colorMarker {
    [super setColorMarker:colorMarker];
    if (selectedSwatch_) {
        selectedSwatch_.colorMarker = colorMarker;
    }
}

#pragma mark- TPSwatchViewDelegate

- (void)colorUsed:(TPColor *)tpColor {
    [[NSNotificationCenter defaultCenter] postNotificationName:SLIDING_PANEL_SHOULD_CLOSE object:nil];
    [self.navigationController popToRootViewControllerAnimated:NO];
}


#pragma mark- Actions

- (IBAction)backAction:(id)sender {
    
    //Animate sliding of the swatch back to the deck
    
    [selectedSwatch_ enableSelection:NO];
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = carousel_.perspective;
    selectedSwatch_.superview.layer.transform = transform;
    
    CGPoint center = carousel_.centerOfInsertion;
    center.y -= 200; // Move the swatch initially a bit higher to make it look as if it jumps up and decends back to the deck
    CGRect __block frame = selectedSwatch_.originalFrame;
    frame.origin.x = center.x - frame.size.width/2;
    frame.origin.y = center.y - frame.size.height/2;
    CGRect viewForSwatchFrame = carousel_.frame;
    viewForSwatchFrame.origin = [viewForSingleSwatch_.superview convertPoint:viewForSwatchFrame.origin fromView:carousel_.superview];
    [UIView animateWithDuration:1 animations:^{
        selectedSwatch_.superview.frame = frame;
        viewForSingleSwatch_.frame = viewForSwatchFrame;
        selectedSwatch_.superview.layer.transform = selectedSwatch_.transformInCarousel;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            selectedSwatch_.superview.center = carousel_.centerOfInsertion;
            selectedSwatch_.alpha = 0;
            carousel_.alpha = 1;
        }completion:^(BOOL finished) {
            [viewForSingleSwatch_.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            viewForSingleSwatch_.hidden = YES;
            [self.colorMarker restoreColor];
            backButton_.hidden = YES;
            carousel_.userInteractionEnabled = YES;
            hueSlider_.hidden = NO;
            brandNameView_.hidden = NO;
            codeButton_.hidden = NO;
            selectedSwatch_ = nil;
        }];
    }];
}

- (IBAction)hueSliderValueChangedAction:(id)sender {
    UISlider* slider = (UISlider*)sender;
    int index = [self indexFromSliderValue:slider.value];
    [carousel_ scrollToItemAtIndex:index duration:0.001];
//    [carousel_ scrollToItemAtIndex:index animated:NO];
}

- (IBAction)hueSliderValueJumpedAction:(id)sender {
    UISlider* slider = (UISlider*)sender;
    int index = [self indexFromSliderValue:slider.value];
    [carousel_ scrollToItemAtIndex:index animated:YES];
}

- (IBAction)codeAction:(id)sender {
    if ( enterCodeView_.frame.origin.y < brandNameView_.frame.origin.y+brandNameView_.frame.size.height) {
        [self openCodePanel];
    } else {
        [self hideCodePanel];
        [codeTextField_ resignFirstResponder];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [self hideCodePanel];
    [codeTextField_ resignFirstResponder];
}


#pragma mark- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return codeMatches_.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TPCodeSearchCell* cell = [tableView dequeueReusableCellWithIdentifier:@"codeSearchCell"];
    cell.nameLabel.text = [codeMatches_ objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark- UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TPCodeSearchCell* cell = (TPCodeSearchCell*)[tableView cellForRowAtIndexPath:indexPath];
    [TPBrandsManager lookUpCode:cell.nameLabel.text withCompletionBlock:^(TPPageData *pageData, NSString *error) {
        if (!pageData || error) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Color Not Found" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        } else {
            [self hideCodePanel];
            TPSingleSwatchViewController* controller = (TPSingleSwatchViewController*)[UIStoryboard instantiateControllerWithId:@"singleSwatch"];
            controller.colorMarker = self.colorMarker;
            controller.delegate = self;
            controller.pageData = pageData;
            controller.launchedFromSearch = YES;
            [self.navigationController pushViewController:controller animated:YES];
        }
    }];
    
}

NSString* lastSearchTerm;
id block;

#pragma mark- UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    lastSearchTerm = searchText;
    if (block) {
        NSLog(@"Cancelling block");
        [NSObject cancelBlock:block];
    }
    [TPBrandsManager currentBrandData].abortSearch = YES;
    block = [NSObject performBlockInBackground:^{
        [[NSThread currentThread] setThreadPriority:0.9];
        if ([searchText isEmptyString]) {
            codeMatches_ = nil;
        } else {
            if (!activityIndicator_.superview ) {
                [NSObject performBlock:^{
                    CGPoint center = CGPointMake(self.view.bounds.size.width/2, 50);
                    activityIndicator_.center = center; //[keyWindow convertPoint:center fromView:self.view];
                    [self.searchDisplayController.searchResultsTableView addSubview:activityIndicator_];
                } afterDelay:0];
            }
            [activityIndicator_ performSelectorOnMainThread:@selector(startAnimating) withObject:nil waitUntilDone:NO];
            [TPBrandsManager currentBrandData].abortSearch = NO;
            codeMatches_ = [[TPBrandsManager currentBrandData] matchingNames:searchText];
            [activityIndicator_ performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:NO];
        }
        block = nil;
        if ([searchText isEqualToString:lastSearchTerm]) {
            [self.searchDisplayController.searchResultsTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
    } afterDelay:0.1];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
}

#pragma mark- UISearchDisplayControllerDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    return NO; // Asynchroneous search
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView {
}



@end
