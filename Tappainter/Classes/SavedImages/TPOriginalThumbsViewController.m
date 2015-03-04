//
//  TPOriginalThumbsViewController.m
//  Tappainter
//
//  Created by Vadim on 10/16/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import "TPOriginalThumbsViewController.h"
#import "TPOriginalThumbCell.h"
#import "UtilityCategories.h"
#import "TPSavedImagesManager.h"
#import "TPPhoto.h"
#import "TPImageAsset.h"
#import "TPAppDefs.h"

@interface TPOriginalThumbsViewController () {
    __weak IBOutlet UICollectionView *collectionView_;
    UIViewController* parentViewcontroller_;
    UIView* parentView_;
    NSIndexPath* selectedIndexPath_;
    bool showEditedImagesOnAppearance_;
    __weak IBOutlet UILabel *numberLabel_;
    TPOriginalThumbCell* cellToDelete_;
}

@end

@implementation TPOriginalThumbsViewController

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
    [[TPSavedImagesManager sharedSavedImagesManager] addObserver:self forKeyPath:@"savedPhotos" options:NSKeyValueObservingOptionNew context:nil];
    [[TPSavedImagesManager sharedSavedImagesManager] addObserver:self forKeyPath:@"selectedImage" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    collectionView_.frame = self.view.bounds;
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (!parentViewcontroller_) {
        parentViewcontroller_ = parent;
        parentView_ = self.view.superview;
    }
}

- (void) setNotificaitonToWatchFor:(NSString *)notificaitonToWatchFor {
    _notificaitonToWatchFor = notificaitonToWatchFor;
    [[NSNotificationCenter defaultCenter] addObserverForName:_notificaitonToWatchFor object:nil
                                                       queue:nil usingBlock:^(NSNotification *note) {
                                                           [self showSelectedImage];
                                                       }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done:(UIStoryboardSegue *)segue {
    NSLog(@"Popping back to this view controller!");
    // reset UI elements etc here
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    selectedIndexPath_ = nil;
    return [TPSavedImagesManager sharedSavedImagesManager].savedPhotos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TPOriginalThumbCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"originalThumb" forIndexPath:indexPath];
    
    TPPhoto* photo = [TPSavedImagesManager sharedSavedImagesManager].savedPhotos[indexPath.row];
    cell.imageAsset = photo.originalAsset;
    cell.tag = indexPath.row;
    __block TPImageAsset* selectedImageAsset = [TPSavedImagesManager selectedImageAsset];
    if (selectedImageAsset.originalAsset == photo.originalAsset) {
        selectedIndexPath_ = indexPath;
    }
//    if (indexPath.row == [TPSavedImagesManager sharedSavedImagesManager].savedPhotos.count-1 && selectedImageAsset) {
//        [self performBlock:^{
//            [self.collectionView selectItemAtIndexPath:selectedIndexPath_ animated:YES scrollPosition:UICollectionViewScrollPositionNone];
//            [[NSNotificationCenter defaultCenter] postNotificationName:IMAGE_SELECTED_NOTIFICATION object:selectedImageAsset];
//        } afterDelay:0.1];
//    }
    cell.delegate = self;
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (selectedIndexPath_ != indexPath) {
        TPPhoto* photo = [TPSavedImagesManager sharedSavedImagesManager].savedPhotos[indexPath.row];
        [[NSNotificationCenter defaultCenter] postNotificationName:IMAGE_SELECTED_NOTIFICATION object:photo.originalAsset];
        
        [_delegate selectionChanged:photo.originalAsset];
        selectedIndexPath_ = indexPath;
    }
}

- (NSIndexPath*) indexPathForSelectedImage {
    TPImageAsset* selectedImageAsset = [TPSavedImagesManager selectedImageAsset];
    int index = 0;
    for (TPPhoto* photo in [TPSavedImagesManager sharedSavedImagesManager].savedPhotos) {
        if (selectedImageAsset.originalAsset == photo.originalAsset) {
            return [NSIndexPath indexPathForItem:index inSection:0];
        }
        index++;
    }
    return  selectedIndexPath_;
}

- (void)showSelectedImage {
    selectedIndexPath_ = [self indexPathForSelectedImage];
    if (selectedIndexPath_) {
        NSArray* visibleIndexPaths = [self.collectionView indexPathsForVisibleItems];
        UICollectionViewScrollPosition scrollPosition;
        if ([visibleIndexPaths containsObject:selectedIndexPath_])
            scrollPosition = UICollectionViewScrollPositionNone;
        else
            scrollPosition = UICollectionViewScrollPositionRight;
        [self.collectionView selectItemAtIndexPath:selectedIndexPath_ animated:NO scrollPosition:scrollPosition];
        TPOriginalThumbCell* cell = (TPOriginalThumbCell*)[self collectionView:self.collectionView cellForItemAtIndexPath:selectedIndexPath_];
        TPImageAsset* selectedImageAsset = [TPSavedImagesManager selectedImageAsset];
        NSAssert(cell.imageAsset.originalAsset == selectedImageAsset.originalAsset, @"Selected cell in collection view doesn't corespond to selected image");
        if ([cell.imageAsset.editedAssets count]) {
            [_delegate selectionChanged:cell.imageAsset];
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    TPOriginalThumbCell* thumbCell = (TPOriginalThumbCell*)cell;
    thumbCell.imageAsset = nil; // Don't keep reference to an Image asset if it's not displayed
}

#pragma mark- Observers

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"savedPhotos"]) {
        [collectionView_ reloadData];
    } else if ([keyPath isEqualToString:@"selectedImage"]) {
        [collectionView_ reloadData];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark- TPImageCellDelegate

- (void)deleteWanted:(UICollectionViewCell *)cell {
    NSString* messageBody;
    cellToDelete_ = (TPOriginalThumbCell*)cell;
    if (cellToDelete_.imageAsset.editedAssets.count) {
        messageBody = @"Delete this image and all painted images?";
    }
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Do You Want to Delete the Image?" message:messageBody delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    [alert show];
}

#pragma mark- UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        NSIndexPath* deletedIndexPath = [self.collectionView indexPathForCell:cellToDelete_];
        [TPSavedImagesManager deleteImageAsset:cellToDelete_.imageAsset];
        [_delegate originalAssetDeleted];
        cellToDelete_ = nil;
        if ([TPSavedImagesManager sharedSavedImagesManager].savedPhotos.count) {
            if ([TPSavedImagesManager sharedSavedImagesManager].savedPhotos.count > deletedIndexPath.row) {
                [self.collectionView selectItemAtIndexPath:deletedIndexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
                selectedIndexPath_ = deletedIndexPath;
            } else  {
                NSIndexPath* newSelection = [NSIndexPath indexPathForRow:[TPSavedImagesManager sharedSavedImagesManager].savedPhotos.count-1 inSection:0];
                [self.collectionView selectItemAtIndexPath:newSelection animated:YES scrollPosition:UICollectionViewScrollPositionNone];
                selectedIndexPath_ = newSelection;
            }
            TPPhoto* photo = [TPSavedImagesManager sharedSavedImagesManager].savedPhotos[selectedIndexPath_.row];
            [[NSNotificationCenter defaultCenter] postNotificationName:IMAGE_SELECTED_NOTIFICATION object:photo.originalAsset];
            [_delegate selectionChanged:photo.originalAsset];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:IMAGE_SELECTED_NOTIFICATION object:nil];
        }
    }
}

@end
