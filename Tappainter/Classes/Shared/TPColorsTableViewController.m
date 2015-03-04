//
//  TPColorsTableViewController.m
//  Tappainter
//
//  Created by Vadim on 11/30/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import "TPColorsTableViewController.h"
#import "TPColorCell.h"
#import "Defs.h"
#import "TPPin.h"
#import "TPColor.h"

static NSString* cellID = @"colorCell";

@interface TPColorsTableViewController ()

@end

@implementation TPColorsTableViewController

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

	// Do any additional setup after loading the view.
    [self.tableView registerNib:[UINib nibWithNibName:@"ColorCell" bundle:Nil] forCellReuseIdentifier:cellID];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setTpColors:(NSArray *)tpColors {
    _tpColors = tpColors;
    [self.tableView reloadData];
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
}

#pragma mark- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _tpColors.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TPColorCell* cell = (TPColorCell*)[tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
//    NSLog(@"cell %x", cell);
    cell.tpColor = _tpColors[indexPath.row];
    cell.colorMarker = self.colorMarker;
    if (cell.frame.size.height > self.view.frame.size.height) {
        cell.frame = CGRectInset(self.view.bounds, 0, (self.view.frame.size.height-cell.frame.size.height)/2);
    }
    cell.delegate = _colorCellDelegate;
    cell.selectable = tableView.allowsSelection;
    return  cell;
}

#pragma mark- UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    TPColorCell* cell = (TPColorCell*)[tableView dequeueReusableCellWithIdentifier:cellID];
    return MIN(cell.frame.size.height, self.view.frame.size.height);
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    TPColorCell* cell = (TPColorCell*)[tableView dequeueReusableCellWithIdentifier:cellID];
    return MIN(cell.frame.size.height, self.view.frame.size.height);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TPColorCell* cell = (TPColorCell*)[tableView cellForRowAtIndexPath:indexPath];
    cell.colorMarker = self.colorMarker;
    [self.colorMarker forceSetColor:cell.tpColor.color];
}


@end
