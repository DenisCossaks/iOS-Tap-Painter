//
//  TPEditedImagesController.m
//  Tappainter
//
//  Created by Vadim on 10/17/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import "TPEditedImagesController.h"
#import "TPEditedImageCell.h"
#import "TPAppDefs.h"
#import "TPImageAsset.h"
#import "UtilityCategories.h"
#import "TPSavedImagesManager.h"

@interface TPEditedImagesController () {
    NSIndexPath* selectedIndexPath_;
}

@end

@implementation TPEditedImagesController

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
    if ( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
        // For iOS 7 we need to shrink and shift all views down below the status bar,
        // Otherwise it will show on top of views. A bit of a hack, maybe will find a better solution later
        CGRect tempRect = self.view.frame;
        tempRect.origin.y += 20;
        tempRect.size.height -= 20;
        self.view.frame = tempRect;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    TPImageAsset* selectedImageAsset = [self selectedImageAsset];
    if (selectedImageAsset) {
        NSAssert(selectedIndexPath_, @"None of the cells correspond to selected image");
        [self.collectionView selectItemAtIndexPath:selectedIndexPath_ animated:NO scrollPosition:UICollectionViewScrollPositionTop];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setOriginalImageAsset:(TPImageAsset *)originalImageAsset {
    _originalImageAsset = originalImageAsset;
    if (!_originalImageAsset) {
        [self removeAllImages];
    } else {
        [self.collectionView reloadData];
        if (selectedIndexPath_) {
            [self.collectionView selectItemAtIndexPath:selectedIndexPath_ animated:YES scrollPosition:UICollectionViewScrollPositionNone];
        }
    }
}

- (TPImageAsset*)selectedImageAsset {
    TPImageAsset* selectedImageAsset;
    selectedImageAsset = _originalImageAsset.selectedImageAsset;
    if (!selectedImageAsset)
        selectedImageAsset = _originalImageAsset;
    return selectedImageAsset;
}

- (void)removeAllImages {
//    NSMutableArray* array = [NSMutableArray array];
//    for (int i = 0; i <= _originalImageAsset.editedAssets.count; i++) {
//        [array addObject:[NSIndexPath indexPathForRow:i inSection:0]];
//    }
    _originalImageAsset = nil;
    [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:0]];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"Touches Began: %@", [self class]);
    [[NSNotificationCenter defaultCenter] postNotificationName:SAVED_IMAGES_PANEL_SHOULD_CLOSE object:nil];
    
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _originalImageAsset ? 1 : 0;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    selectedIndexPath_ = nil;
    if (_originalImageAsset) {
            return _originalImageAsset.editedAssets.count+1;
    } else {
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    TPEditedImageCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"editedImage" forIndexPath:indexPath];
    
    TPImageAsset* imageAsset;
    if (indexPath.row == 0) {
        imageAsset = _originalImageAsset;
        cell.isOriginalImage = true;
    } else {
        imageAsset = _originalImageAsset.editedAssets[indexPath.row-1];
        cell.isOriginalImage = false;
    }
    cell.tag = indexPath.row;
    cell.imageAsset = imageAsset;
    TPImageAsset* selectedImageAsset = [self selectedImageAsset];
    if (selectedImageAsset) {
        if (selectedImageAsset == imageAsset) {
            selectedIndexPath_ = indexPath;
        }
    }
    cell.chosen = [imageAsset isMarked];
    cell.delegate = self;
    cell.deletable = indexPath.row != 0;
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    TPImageAsset* imageAsset;
    if (indexPath.row == 0) {
        imageAsset = _originalImageAsset;
    } else {
        imageAsset = _originalImageAsset.editedAssets[indexPath.row-1];
    }
    if (selectedIndexPath_ != indexPath) {
        [[NSNotificationCenter defaultCenter] postNotificationName:IMAGE_SELECTED_NOTIFICATION object:imageAsset];
        selectedIndexPath_  = indexPath;
        _originalImageAsset.selectedImageAsset = imageAsset;
    }
    if (/*indexPath.row != 0 && */_showCheckMark) {
        TPEditedImageCell* cell = (TPEditedImageCell*)[collectionView cellForItemAtIndexPath:indexPath];
        cell.chosen = !cell.chosen;
        cell.chosen ? [imageAsset markImageAsset:imageAsset] : [imageAsset unmarkImageAsset:imageAsset];
    }

}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    TPEditedImageCell* imageCell = (TPEditedImageCell*)cell;
    imageCell.imageAsset = nil; // Don't keep reference to an Image asset if it's not displayed
}

#pragma mark- TPImageCellDelegate

- (void)deleteWanted:(UICollectionViewCell *)cell {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Do You Want to Delete the Image?" message:Nil delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    [alert show];
}

#pragma mark- UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [TPSavedImagesManager deleteImageAsset:_originalImageAsset.selectedImageAsset];
        NSArray* paths = [self.collectionView indexPathsForSelectedItems];
        if (paths) {
            NSIndexPath* deletedIndexPath = [paths firstObject];
            [self.collectionView deleteItemsAtIndexPaths:paths];
            [self.collectionView reloadData];
            if (_originalImageAsset.editedAssets.count+1 > deletedIndexPath.row) {
                [self.collectionView selectItemAtIndexPath:deletedIndexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
                selectedIndexPath_ = deletedIndexPath;
                _originalImageAsset.selectedImageAsset = _originalImageAsset.editedAssets[selectedIndexPath_.row-1];
            } else if (_originalImageAsset.editedAssets.count) {
                NSIndexPath* newSelection = [NSIndexPath indexPathForRow:_originalImageAsset.editedAssets.count inSection:0];
                [self.collectionView selectItemAtIndexPath:newSelection animated:YES scrollPosition:UICollectionViewScrollPositionNone];
                selectedIndexPath_ = newSelection;
                _originalImageAsset.selectedImageAsset = _originalImageAsset.editedAssets[selectedIndexPath_.row-1];
            } else {
                NSIndexPath* newSelection = [NSIndexPath indexPathForRow:0 inSection:0];
                [self.collectionView selectItemAtIndexPath:newSelection animated:YES scrollPosition:UICollectionViewScrollPositionNone];
                selectedIndexPath_ = newSelection;
                selectedIndexPath_ = [NSIndexPath indexPathForRow:0 inSection:0];
                _originalImageAsset.selectedImageAsset = _originalImageAsset;
                [_delegate lastImageDeleted];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:IMAGE_SELECTED_NOTIFICATION object:_originalImageAsset.selectedImageAsset];
        }
   }
}

#pragma mark - UITapGestureRecognizer

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    NSArray* visibleCells = self.collectionView.visibleCells;
    for (UIView* cellView in visibleCells) {
        CGPoint point = [touch locationInView:cellView];
        if ([cellView hitTest:point withEvent:nil]) {
            NSLog(@"Don't handle Touch");
            return NO;
        }
    }
    return YES;
}

- (IBAction)tapAction:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:SAVED_IMAGES_PANEL_SHOULD_CLOSE object:nil];
}

@end
