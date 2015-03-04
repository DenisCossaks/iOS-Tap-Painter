//
//  TPCornerMarker.h
//  Tappainter
//
//  Created by Vadim on 1/30/14.
//  Copyright (c) 2014 MDi Touch. All rights reserved.
//

#import "TPPin.h"

@class TPCornerMarker;
@protocol TPCornerMarkerDelegate <TPPinDelegate>

- (void)cornerMarkerMoved:(TPCornerMarker*)marker;
//- (void)cornerMarkerSelected:(TPCornerMarker*)marker;

@end

@interface TPCornerMarker : TPPin

@property (nonatomic) __weak id<TPCornerMarkerDelegate> cmDelegate;
@property (nonatomic) bool selected;

@end
