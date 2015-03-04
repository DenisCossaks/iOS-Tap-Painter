//
//  TPBrandListCell.m
//  Tappainter
//
//  Created by Vadim on 11/10/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import "TPBrandListCell.h"

@interface TPBrandListCell() {
    
    __weak UIImageView *checkMark_;
    __weak IBOutlet UIImageView *lockedImage_;
    __weak IBOutlet UILabel *selectedLabel_;
    __weak IBOutlet UIView *selectedView_;
}
@end

@implementation TPBrandListCell

@synthesize checkMark=checkMark_;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

//    if (selected) {
////        checkMark_.hidden = NO;
//    } else {
//        checkMark_.hidden = YES;
//    }
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
//    if (selected) {
////        checkMark_.hidden = NO;
//    } else {
//        checkMark_.hidden = YES;
//    }
}

- (void)markSelected:(BOOL)selected {
    if (selected) {
        selectedLabel_.text = _nameLabel.text;
          selectedView_.hidden = NO;
    } else {
        selectedView_.hidden = YES;
    }
}

- (void)setLocked:(bool)locked {
    _locked = locked;
    lockedImage_.hidden = !locked;
    _nameLabel.alpha = locked ? 0.8 : 1;
}

@end
