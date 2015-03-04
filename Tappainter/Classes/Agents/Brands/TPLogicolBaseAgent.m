//
//  TPLogicolBaseAgent.m
//  Tappainter
//
//  Created by Vadim on 1/8/14.
//  Copyright (c) 2014 MDi Touch. All rights reserved.
//

#import "TPLogicolBaseAgent.h"
#import "TPBrandData.h"

@implementation TPLogicolBaseAgent

+ (void)downloadBrandDataWithCompletionBlock:(void (^)(NSArray *))block {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString* urlString = [self attachBrandParameterToURL:@"http://fastrgb.com/api_page/?P=ALL"];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            NSLog(@"SherwinWilliamsAgent: dowload error: %@", connectionError.description);
        } else {
            NSString* JSONString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            JSONString = [JSONString stringByReplacingOccurrencesOfString:@"<pre>" withString:@""];
            JSONString = [JSONString stringByReplacingOccurrencesOfString:@"</pre>" withString:@""];
            NSArray* allPagesArray = [NSJSONSerialization JSONObjectWithData:[JSONString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
            NSMutableArray* structuredPagesArray = [NSMutableArray array];
            int currentPageNumber = 1;
            NSMutableArray* colorsArray = [NSMutableArray array];
            for (NSDictionary* dict in allPagesArray) {
                int pageNamber = [[dict valueForKey:@"page"] integerValue];
                if (pageNamber != currentPageNumber) {
                    [structuredPagesArray addObject:colorsArray];
                    currentPageNumber = pageNamber;
                    colorsArray = [NSMutableArray array];
                }
                [colorsArray addObject:dict];
            }
            [structuredPagesArray addObject:colorsArray];
            block(structuredPagesArray);
            
        }
    }];
}

+ (void)getColorsForPage:(int)pageNumber intArray:(NSMutableArray*)array andCompetionBlock:(void(^)(void))block{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString* urlString = [NSString stringWithFormat:@"http://fastrgb.com/api_page/?P=%d", pageNumber];
    urlString = [self attachBrandParameterToURL:urlString];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            NSLog(@"SherwinWilliamsAgent: page %d dowload error: %@", pageNumber, connectionError.description);
        } else {
            NSString* JSONString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            JSONString = [JSONString stringByReplacingOccurrencesOfString:@"<pre>" withString:@""];
            JSONString = [JSONString stringByReplacingOccurrencesOfString:@"</pre>" withString:@""];
            NSArray* colorsArray = [NSJSONSerialization JSONObjectWithData:[JSONString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
            [array setArray:colorsArray];
            block();
        }
    }];
}

+ (void)loadBrandData:(TPBrandData *)brandData fromPagesArrays:(NSArray *)pagesArray {
    NSMutableArray* pages = [NSMutableArray array];
    for (NSArray* pageData in pagesArray) {
        [pages addObject:[self pageDataFromPageDataArray:pageData]];
    }
    
    brandData.pages = pages;
}

+ (void)convertColor:(UIColor *)color withCompletionBlock:(void (^)(TPPageData *, NSString*))block {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString* urlString = [NSString stringWithFormat:@"http://fastrgb.com/api_page/?R=%d&G=%d&B=%d&H=", (int)(color.red*255), (int)(color.green*255), (int)(color.blue*255)];
    urlString = [self attachBrandParameterToURL:urlString];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            NSLog(@"SherwinWilliamsAgent: color matching error: %@", connectionError.description);
        } else {
            NSString* JSONString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            JSONString = [JSONString stringByReplacingOccurrencesOfString:@"<pre>" withString:@""];
            JSONString = [JSONString stringByReplacingOccurrencesOfString:@"</pre>" withString:@""];
            NSArray* colorsArray = [NSJSONSerialization JSONObjectWithData:[JSONString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
            //            NSLog(@"Colors array: %@", colorsArray);
            TPPageData* pageData = [self pageDataFromPageDataArray:colorsArray];
            block(pageData, nil);
        }
    }];
}

+ (NSString*)attachBrandParameterToURL:(NSString*)urlString {
    return [NSString stringWithFormat:@"%@&L=%@", urlString, [[self brandName] stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
}

+ (NSString*)brandName {
    return nil;
}

+ (void)getBrandsListwithCompletionBlock:(void (^)(NSArray *))block {
    NSMutableArray* brandsList = [NSMutableArray array];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString* urlString = @"http://fastrgb.com/api_page/?L=LIST";
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            NSLog(@"Error getting brands list: %@", connectionError.description);
            BLOCK(nil)
        } else {
            NSString* JSONString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            JSONString = [JSONString stringByReplacingOccurrencesOfString:@"<pre>" withString:@""];
            JSONString = [JSONString stringByReplacingOccurrencesOfString:@"</pre>" withString:@""];
            NSArray* responseArray = [NSJSONSerialization JSONObjectWithData:[JSONString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
            for (NSDictionary* brndDict in responseArray) {
                [brandsList addObject:[brndDict objectForKey:@"name"]];
            }
            BLOCK(brandsList);
        }
    }];
}

@end
