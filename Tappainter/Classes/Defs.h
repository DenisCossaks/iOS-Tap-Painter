//
//  Defs.h
//  NewGamePrototype
//
//  Created by Oleg on 23.08.12.
//  Copyright (c) 2012 Oleg. All rights reserved.
//
#import <sys/utsname.h>

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

#define FRAME_TO_STRING(frame)  [NSString stringWithFormat:@"[%f, %f, %f, %f]", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height]
#define POINT_TO_STRING(point)  [NSString stringWithFormat:@"(%f, %f)", point.x, point.y]
#define SIZE_TO_STRING(size)  [NSString stringWithFormat:@"(%f, %f)", size.width, size.height]
#define RECT_CENTER(rect)   CGPointMake(rect.origin.x+rect.size.width/2, rect.origin.y+rect.size.height/2)

static inline NSString* machineName()
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

static inline float randomFloat()
{
    return (float)rand()/(float)RAND_MAX;
}

// iOS Version Checking
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define BLOCK(...) {if (block) block(__VA_ARGS__);}

#define HEIGHT_IPHONE_5 568
#define IS_IPHONE   ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)

#define IS_IPHONE_5 ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == HEIGHT_IPHONE_5)
#define IS_IPAD ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

#define iPhone568ImageNamed(image) (IS_IPHONE_5 ? [NSString stringWithFormat:@"%@-568h.%@", [image stringByDeletingPathExtension], [image pathExtension]] : image)
#define iPhone568Image(image) ([UIImage imageNamed:iPhone568ImageNamed(image)])

#define IS_RETINA ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && [UIScreen mainScreen].scale == 2.0)

