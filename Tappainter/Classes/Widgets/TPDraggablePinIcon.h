//
//  TPDraggablePinIcon.h
//  Tappainter
//
//  Created by Vadim on 10/15/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPDraggableView.h"

@class TPPin;
@protocol TPDraggablePinIconDelegate <NSObject>

- (void)startedDragging;
- (TPPin*)placePinAtLocation:(CGPoint)location;
- (void)pinAdded:(TPPin*)pin;

@end

@interface TPDraggablePinIcon : TPDraggableView {
    
}
@property __weak IBOutlet id<TPDraggablePinIconDelegate> delegate;
@property __weak IBOutlet UIImageView* imageViewForPin;
@property __weak IBOutlet UIImageView* imageView;

@end
