//
//  TPCodeSearchCell.m
//  Tappainter
//
//  Created by Vadim on 2/4/14.
//  Copyright (c) 2014 MDi Touch. All rights reserved.
//

#import "TPCodeSearchCell.h"

@implementation TPCodeSearchCell

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
    
    if (selected) {
        _nameLabel.textColor = [UIColor yellowColor];
    } else {
        _nameLabel.textColor = [UIColor whiteColor];
    }
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (selected) {
        _nameLabel.textColor = [UIColor yellowColor];
    } else {
        _nameLabel.textColor = [UIColor whiteColor];
    }
}
@end
