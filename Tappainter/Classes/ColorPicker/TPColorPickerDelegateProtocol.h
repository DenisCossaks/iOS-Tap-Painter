//
//  TPColorPickerDelegateProtocol.h
//  Tappainter
//
//  Created by Vadim on 11/2/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TPColorPickerDelegate <NSObject>
- (void)colorChanged:(UIColor*)color;
@end
