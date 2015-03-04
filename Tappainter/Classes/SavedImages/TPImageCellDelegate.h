//
//  TPImageCellDelegate.h
//  Tappainter
//
//  Created by Vadim on 12/14/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TPImageAsset;
@protocol TPImageCellDelegate <NSObject>

- (void)deleteWanted:(UICollectionViewCell*)cell;

@end
