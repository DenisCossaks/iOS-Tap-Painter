//
//  TPBrandSelectionViewController.m
//  Tappainter
//
//  Created by Vadim on 11/10/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import "TPBrandSelectionViewController.h"
#import "TPBrandsManager.h"
#import "TPBrandListCell.h"
#import "TPBrandListHeaderView.h"
#import "TPSingleSwatchViewController.h"
#import "TPAppDefs.h"
#import "Flurry.h"
#import "TPBrandData.h"
#import "UpgradeProductEngine.h"
#import "TPTutorialController.h"
#import "TPAdsManager.h"

static NSString* cellID = @"brandListCell";
static NSString* headerID = @"brandListHeader";

#define ALERT_TO_UNLOCK 1
#define ALERT_TO_BUY 2
#define ALERT_CONFIRMATION 3

@interface TPBrandSelectionViewController () {
    __weak IBOutlet UIButton *nextButton_;
    __weak IBOutlet UIButton *backButton_;
    NSInteger currentBrandID_;
    __weak IBOutlet UIView *tableHeaderView_;
    NSInteger brandIdToUnlock_;
    NSIndexPath* previousSelection_;
}

@end

@implementation TPBrandSelectionViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    currentBrandID_ = [TPBrandsManager currentBrand];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.tableView registerNib:[UINib nibWithNibName:@"BrandListCell" bundle:Nil] forCellReuseIdentifier:cellID];
    [self.tableView registerNib:[UINib nibWithNibName:@"BrandListHeaderView" bundle:nil] forHeaderFooterViewReuseIdentifier:headerID];
    if (!_tpColor) {
        // This is when Brands selection is pushed from Swatches controller, in which case we are not selecting Brads to convert a color but for
        // displaying their pallete of swatches
        [nextButton_ setTitle:@"Select" forState:UIControlStateNormal];
    } else {
        [nextButton_ setTitle:@"Convert" forState:UIControlStateNormal];
    }
    
    [[NSNotificationCenter defaultCenter] addObserverForName:SLIDING_PANEL_WILL_OPEN object:nil queue:nil usingBlock:^(NSNotification *note) {
        if ([self isPresented]) {
            currentBrandID_ = [TPBrandsManager currentBrand];
            [self.tableView reloadData];
        }
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:SLIDING_PANEL_WILL_CLOSE object:nil queue:nil usingBlock:^(NSNotification *note) {
        if ([self isPresented]) {
            [TPBrandsManager setCurrentBrand:currentBrandID_];
            [self.tableView reloadData];
        }
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:BRAND_SELECTED object:nil queue:nil usingBlock:^(NSNotification *note) {
        currentBrandID_ = [TPBrandsManager currentBrand];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView.superview addSubview:tableHeaderView_];
    [self.tableView reloadData];
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
//    NSLog(@"Table view: %@", self.tableView);
//    NSLog(@"Tableview Superview :%@", self.tableView.superview);
}

- (void)setTpColor:(TPColor *)tpColor {
    _tpColor = tpColor;
    if (tpColor) {
        // This means that Brands selection is pushed to convert the color, so it has to have the Next button to go to the next step
        [nextButton_ setTitle:@"Convert" forState:UIControlStateNormal];
    }
}

- (bool)isPresented {
    NSArray* controllers = self.navigationController.viewControllers;
    return [controllers lastObject] == self && self.navigationController.parentViewController;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if ([TPBrandsManager brandsUnlocked]) return 2;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{   if (![TPBrandsManager brandsUnlocked]) return [TPBrandsManager allBrands].count;
    if (section == 0) return [TPBrandsManager unlockedBrands].count;
    return [TPBrandsManager lockedBrands].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TPBrandListCell *cell = (TPBrandListCell*)[tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    TPBrandData* brandData;
    if ([TPBrandsManager brandsUnlocked]) {
        if (indexPath.section == 0) {
            brandData = [TPBrandsManager unlockedBrands][indexPath.row];
        } else {
            brandData = [TPBrandsManager lockedBrands][indexPath.row];
        }
        
    } else {
        brandData = [TPBrandsManager allBrands][indexPath.row];
    }
    
    cell.nameLabel.text = brandData.name;
    cell.tag = brandData.brandId;
    cell.locked = !brandData.unlocked;
    if (brandData.brandId == [TPBrandsManager currentBrand]) {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        [cell markSelected:YES];
    } else {
        [cell markSelected:NO];
    }
    
    
//    NSIndexPath* selectedCellPath = [[tableView indexPathsForSelectedRows] firstObject];
//    if (selectedCellPath.row == indexPath.row && selectedCellPath.section == indexPath.section && brandData.unlocked) {
//        [cell markSelected:YES];
//    } else {
//        [cell markSelected:NO];
//    }
//    
    return cell;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    TPBrandListHeaderView* headerView = (TPBrandListHeaderView*)[tableView dequeueReusableHeaderFooterViewWithIdentifier:headerID];
    if (![TPBrandsManager brandsUnlocked]) return nil;
    
    if (section == 0) {
        headerView.titleLabel.text = @"Favorite Color Fan Decks";
    } else {
        headerView.titleLabel.text = @"Color Fan Deck List";
    }
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (![TPBrandsManager brandsUnlocked]) return 0;
    TPBrandListHeaderView* headerView = (TPBrandListHeaderView*)[tableView dequeueReusableHeaderFooterViewWithIdentifier:headerID];
    return headerView.frame.size.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    TPBrandListCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    return cell.frame.size.height;
}

#pragma mark- UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TPBrandListCell* cell = (TPBrandListCell*)[tableView cellForRowAtIndexPath:indexPath];
    TPBrandData* brandData = [TPBrandsManager brandDataForId:cell.tag];
    if (!brandData.unlocked) {
        brandIdToUnlock_ = brandData.brandId;
        int numberOfFreeBrands = [UpgradeProductEngine upgradeEngineSingleton].numberOfCredits;
        NSString* message;
        int tag = ALERT_TO_UNLOCK;
        NSString* price = [[UpgradeProductEngine upgradeEngineSingleton] localizedPriceStringForProductAtIndex:0];
        if (numberOfFreeBrands) {
            if ([TPBrandsManager brandsUnlocked] == 0) {
                
                message = [NSString stringWithFormat:@"You can select %d  Color Fan Decks for FREE", numberOfFreeBrands];
            } else {
                message = [NSString stringWithFormat:@"You can select %d more Color Fan Decks for FREE", numberOfFreeBrands];
                if (numberOfFreeBrands == 1) {
                    message =  [NSString stringWithFormat:@"You can select 1 more  Color Fan Deck for FREE. Additional Color Fan Decks may be selected for %@ per Fan Deck", price];
                }
            }
        } else {
            message = [NSString stringWithFormat:@"You can select a Color Fan Deck for %@. Do you want to select this Color Fan Deck?", price];
            tag = ALERT_TO_BUY;
        }
#ifdef TAPPAINTER_TRIAL
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Add to Selected Color Fan Decks?" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Select", @"Upgrade", nil];
#else
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Add to Selected Color Fan Decks?" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Select", nil];
#endif
        alert.tag = tag;
        [alert show];
    } else {
        [self selectAndUnlockBrand:cell.tag];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    TPBrandListCell* cell = (TPBrandListCell*)[tableView cellForRowAtIndexPath:indexPath];
    [cell markSelected:NO];
    previousSelection_ = indexPath;
}


#pragma mark- Segue related methods

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:BRAND_SELECTED object:nil];
    [Flurry logEvent:@"Brand Selected" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[TPBrandsManager currentBrandData].name, @"Name", nil]];
    if (!_tpColor) {
        // New brand selected by pressing Select button. Go up navigation stack
        [self.navigationController popViewControllerAnimated:YES];
        return NO;
    } else {
        // Convert button pressed, go to the next controller to convert the color
        return YES;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    TPSingleSwatchViewController* controller = segue.destinationViewController;
    controller.colorMarker = _colorMarker;
//    controller.tpColor = _tpColor;
    controller.pageData = nil;
}

#pragma mark- Actions

- (IBAction)backAction:(id)sender {
    [TPBrandsManager setCurrentBrand:currentBrandID_];
    NSArray* controllers = self.navigationController.viewControllers;
    if ([controllers firstObject] == self) {
        // WE are the root controller. Close the panel
        [[NSNotificationCenter defaultCenter] postNotificationName:SLIDING_PANEL_SHOULD_CLOSE object:nil];
        [self.tableView reloadData]; // Restore brand selection
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark- UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == ALERT_TO_UNLOCK) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            if (buttonIndex == 1) {
                [self selectAndUnlockBrand:brandIdToUnlock_];
                [UpgradeProductEngine creditsUsed:1];
                [Flurry logEvent:@"Free Brand Unlocked" withParameters:[NSDictionary dictionaryWithObject:[TPBrandsManager brandNameForId:brandIdToUnlock_] forKey:@"name"]];
            } else {
                [Flurry logEvent:@"Upgrade Tapped" withParameters:@{@"Prompt":@"Unlock"}];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:TAPPAINTER_STANDARD_URL]];
            }
        } else {
            [self restoreSelection];
        }
    } else if (alertView.tag == ALERT_TO_BUY) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            if (buttonIndex == 1) {
                [[UpgradeProductEngine upgradeEngineSingleton] purchaseUpgradeProductAtIndex:0 forDelegate:self];
            } else {
                [Flurry logEvent:@"Upgrade Tapped" withParameters:@{@"Prompt":@"Unlock"}];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:TAPPAINTER_STANDARD_URL]];
            }
        } else {
            [self restoreSelection];
        }
    } else if (alertView.tag == ALERT_CONFIRMATION) {
        [TPAdsManager showAdOnCreditUsed];
    }
}

#pragma mark- UpgradeProductEngineDelegate

- (void)purchaseDidFailWithError:(NSString *)error {
    [self restoreSelection];
}

- (void)purchaseWasCancelled {
    [self restoreSelection];
}

- (void)purchaseDidSucceedForProduct:(NSString *)productTitle {
    NSString* message = [NSString stringWithFormat:@"You just unlocked %@ Color Fan Deck", [TPBrandsManager brandNameForId:brandIdToUnlock_]];
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Color Fan Deck Unlocked" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    alertView.delegate = self;
    alertView.tag = ALERT_CONFIRMATION;
    [alertView show];
    [self selectAndUnlockBrand:brandIdToUnlock_];
    [UpgradeProductEngine creditsUsed:1];
    [Flurry logEvent:@"Brand Purchased" withParameters:[NSDictionary dictionaryWithObject:[TPBrandsManager brandNameForId:brandIdToUnlock_] forKey:@"name"]];
}

#pragma mark- Service Methods

- (NSIndexPath*)indexPathForBrandId:(NSInteger)brandId {
    TPBrandData* brandData = [TPBrandsManager brandDataForId:brandId];
    NSInteger index;
    NSInteger section;
    if (![TPBrandsManager brandsUnlocked]) {
        index = [[TPBrandsManager allBrands] indexOfObject:brandData];
        section = 0;
    } else {
        if (brandData.unlocked) {
            index = [[TPBrandsManager unlockedBrands] indexOfObject:brandData];
            section = 0;
        } else {
            index = [[TPBrandsManager lockedBrands] indexOfObject:brandData];
            section = 1;
        }
    }
    return [NSIndexPath indexPathForRow:index inSection:section];
}

- (void)selectAndUnlockBrand:(NSInteger)brandId {
    TPBrandListCell* cell = (TPBrandListCell*)[self.tableView cellForRowAtIndexPath:[self indexPathForBrandId:brandId]];
    [cell markSelected:YES];
    cell.locked = NO;
    
    [TPBrandsManager unlockBrand:brandId];
    [TPBrandsManager setCurrentBrand:brandId];
    [[NSNotificationCenter defaultCenter] postNotificationName:BRAND_SELECTED object:nil];
    [Flurry logEvent:@"Brand Selected" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[TPBrandsManager currentBrandData].name, @"Name", nil]];
    if (_tpColor) {
        TPSingleSwatchViewController* controller = [self.storyboard instantiateViewControllerWithIdentifier:@"singleSwatch"];
        controller.colorMarker = _colorMarker;
        controller.pageData = nil;
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
        [tutorialController showSwatchTutorial];
    }
}

- (void)restoreSelection {
    TPBrandListCell* cell = (TPBrandListCell*)[self.tableView cellForRowAtIndexPath:previousSelection_];
    if (!cell.locked) {
        [self.tableView selectRowAtIndexPath:previousSelection_ animated:NO scrollPosition:UITableViewScrollPositionNone];
        [cell markSelected:YES];
    }
}

@end
