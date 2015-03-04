//
//  TPBrandListCell.h
//  Tappainter
//
//  Created by Vadim on 11/10/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPBrandListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak) IBOutlet UIImageView *checkMark;
@property (nonatomic) bool locked;

- (void)markSelected:(BOOL)selected;

@end
