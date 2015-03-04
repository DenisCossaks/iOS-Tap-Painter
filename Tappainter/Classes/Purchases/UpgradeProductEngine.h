//
//  TPUpgradeProductEngine.h
//  ThwartPokerHoldem
//
//  Created by Adam Talcott on 7/19/10.
//  Copyright ThwartPoker Inc. 2010. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

typedef enum {
    kTPProductIdentifier4Pack,
    kTPProductIdentifier10Pack,
    kTPProductIdentifier50Pack,
    kTPProductIdentifier100Pack,
    kTPProductIdentifierUnlimited
} tTPProductIdentifier;

@protocol UpgradeProductEngineDelegate

@optional
- (void)requestForProductDataDidFailWithError:(NSError *)error;
- (void)requestForProductDataDidSucceed:(NSArray*)productsData;

- (void)purchaseDidFailWithError:(NSString *)error;
- (void)purchaseWasCancelled;
- (void)purchaseDidSucceedForProduct: (NSString*) productTitle;

- (void)restorePurchasesDidFailWithErrors:(NSArray *)errors;
- (void)restorePurchasesWasCancelled;
- (void)restorePurchasesDidSucceed;

@end



@interface UpgradeProductEngine : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver> {
}

@property (nonatomic, retain) id<UpgradeProductEngineDelegate> delegate;
@property bool showUI;
@property NSDictionary* products;
@property (nonatomic) int numberOfCredits;
@property NSInteger creditsUsed;

+ (UpgradeProductEngine*) upgradeEngineSingleton;
+ (void) upgrade;
+ (BOOL) canMakePurchases;
+ (void) purchaseProduct: (NSString*) productID forDelegate: (id<UpgradeProductEngineDelegate>) theDelegate;

+ (bool)isEnoughCredits:(int)creditsNeeded;
+ (void)creditsUsed:(NSInteger)numberOfCredits;

- (NSInteger)numberOfProducts;
- (NSString *)productIdentifierForProductAtIndex:(NSInteger)index;
- (SKProduct *)productAtIndex:(NSInteger)index;
- (NSString *)descriptionForProductAtIndex:(NSInteger)index;
- (NSString *)titleForProductAtIndex:(NSInteger)index;
- (NSString *)localizedPriceStringForProductAtIndex:(NSInteger)index;

- (void)requestUpgradeProductDataForDelegate:(id<UpgradeProductEngineDelegate>)theDelegate;
- (void)requestUpgradeProductDataForProductIdentifiers:(NSArray*)identifiers andDelegate:(id<UpgradeProductEngineDelegate>)theDelegate;
- (void)purchaseUpgradeProductAtIndex:(NSInteger)index forDelegate:(id<UpgradeProductEngineDelegate>)theDelegate;
- (void)restorePurchases;

- (void)completeTransaction:(SKPaymentTransaction *)transaction;
- (void)recordTransaction:(SKPaymentTransaction *)transaction;
- (void)restoreTransaction:(SKPaymentTransaction *)transaction;
- (void)failedTransaction:(SKPaymentTransaction *)transaction;
- (void)provideContent:(NSString *)productIdentifier;

- (BOOL)isTransactionCancelledError:(NSError *)error;

- (void)upgradeToFullGame;

@end
