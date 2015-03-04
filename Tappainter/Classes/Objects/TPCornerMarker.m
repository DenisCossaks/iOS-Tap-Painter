//
//  TPCornerMarker.m
//  Tappainter
//
//  Created by Vadim on 1/30/14.
//  Copyright (c) 2014 MDi Touch. All rights reserved.
//

#import "TPCornerMarker.h"

@interface TPCornerMarker ()

@end

@implementation TPCornerMarker {
    
    IBOutlet UIImageView *selectedImage_;
    IBOutlet UIImageView *unselectedImage_;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        if (_cmDelegate) {
            self.delegate = _cmDelegate;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.marginToEdge = 0;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    [super touchesBegan:touches withEvent:event];
//    self.selected = YES;
//    if (_cmDelegate) {
//        [_cmDelegate cornerMarkerSelected:self];
//    }
//}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    if (_cmDelegate) {
        [_cmDelegate cornerMarkerMoved:self];
    }
}

//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    [super touchesEnded:touches withEvent:event];
//    if (_cmDelegate) {
//        [_cmDelegate cornerMarkerMoved:self];
//    }
//}

- (void)setCmDelegate:(id<TPCornerMarkerDelegate>)cmDelegate {
    _cmDelegate = cmDelegate;
    self.delegate = cmDelegate;
}

- (void)setSelected:(bool)selected {
    _selected = selected;
    selectedImage_.hidden = YES; //!selected;
    unselectedImage_.hidden = NO; //selected;
}

@end
