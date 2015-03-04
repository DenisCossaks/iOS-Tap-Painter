//
//  TPUpgradeProductEngine.m
//  ThwartPokerHoldem
//
//  Created by Adam Talcott on 7/19/10.
//  Copyright ThwartPoker Inc. 2010. All rights reserved.
//

#import "UpgradeProductEngine.h"
#import "Defs.h"
#import "UtilityCategories.h"
#import "TPAppDefs.h"
#import "TPWallPaintService.h"

UpgradeProductEngine *upgradeEngine;

NSString * const UpgradeProductEngineErrorDomain = @"UpgradeProductEngineErrorDomain";
const NSInteger UpgradeProductEngineErrorCodeNothingRestored = 1;

#define INAPP_PURCHASE_ID @"aaa"
int numberOfCreditsArray[] = {4, 10, 50, 100, -1};
#define NUMBER_OF_CREDITS_KEY @"NumberOfCredits"
#define CREDITS_USED_KEY @"CreditsUsed"
#define STARTING_NUMBER_OF_CREDITS 10;

@interface UpgradeProductEngine() {
	__weak id<UpgradeProductEngineDelegate> delegate_;
	
	NSArray *productIndentifiers_;
	NSMutableDictionary *products_;
	
	BOOL isRestoringPurchases_;
	BOOL purchasesRestored_;
    UIAlertView* progressAlert_;
    SKPaymentTransaction* restoredTransation_;
}

@end

@implementation UpgradeProductEngine

@synthesize delegate;
@synthesize products=products_;

#pragma mark -
#pragma mark Class Methods

+ (BOOL)canMakePurchases
{
	return [SKPaymentQueue canMakePayments];
}

+ (UpgradeProductEngine*) upgradeEngineSingleton
{
    if ( !upgradeEngine )
    {
        upgradeEngine = [[UpgradeProductEngine alloc] init];
    }
    return upgradeEngine;
}

+ (void) upgrade {
    [[self upgradeEngineSingleton] upgradeToFullGame];
#if TARGET_IPHONE_SIMULATOR == 0
    //        purchaseProgressAlert_ = [self displayProgressAlertWithMessage:@"Requesting product list..."];
    //
    [[UpgradeProductEngine upgradeEngineSingleton] requestUpgradeProductDataForDelegate:nil];
    
#endif
}

+ (void) purchaseProduct: (NSString*) productID forDelegate: (id<UpgradeProductEngineDelegate>) theDelegate {
    [[UpgradeProductEngine upgradeEngineSingleton] purchaseProduct:productID forDelegate:theDelegate];
}

+ (bool)isEnoughCredits:(int)creditsNeeded {
    UpgradeProductEngine* engine = [UpgradeProductEngine upgradeEngineSingleton];
    return engine.numberOfCredits == -1 || engine.numberOfCredits >= creditsNeeded;
}

+ (void)creditsUsed:(NSInteger)numberOfCredits {
    UpgradeProductEngine* engine = [UpgradeProductEngine upgradeEngineSingleton];
    if (engine.numberOfCredits > 0) {
        engine.numberOfCredits -= (int)numberOfCredits;
    }
    [UpgradeProductEngine upgradeEngineSingleton].creditsUsed += numberOfCredits;
    [[NSUserDefaults standardUserDefaults] setInteger:[UpgradeProductEngine upgradeEngineSingleton].creditsUsed forKey:CREDITS_USED_KEY];
}

#pragma mark -
#pragma mark Object Lifecycle Methods

- (id)init
{
	if ( self = [super init] ) {
		
		self.delegate = nil;
		
		products_ = [[NSMutableDictionary alloc] init];
#ifdef TAPPAINTER_TRIAL
//        productIndentifiers_ = @[@"4pack_standard",@"10pack_standard",@"50pack_standard",@"100pack_standard",@"Unlimited_standard2"];
        productIndentifiers_ = @[@"brandUnlock_Trial"];
#else
        productIndentifiers_ = @[@"brandUnlock_standard"];
#endif
		isRestoringPurchases_ = NO;
		purchasesRestored_ = NO;
#ifdef TAPPAINTER_PRO
        _numberOfCredits = -1;
#else
        NSNumber* numberOfCreditsNumber = [[NSUserDefaults standardUserDefaults] valueForKey:NUMBER_OF_CREDITS_KEY];
        NSLog(@"Number of credits initialized: %@", numberOfCreditsNumber);
        bool firstRun = [self firstRunForV1_5];
        if (!numberOfCreditsNumber || firstRun) {
            [TPWallPaintService getNumberOfFreeFanDecksWithCompletionBlock:^(int number) {
                if (number != -1) {
                    self.numberOfCredits = number;
                } else {
                    self.numberOfCredits = STARTING_NUMBER_OF_CREDITS;
                }
            }];
        } else {
            _numberOfCredits = [numberOfCreditsNumber intValue];
        }
#endif
        _creditsUsed = [[NSUserDefaults standardUserDefaults] integerForKey:CREDITS_USED_KEY];
        _showUI = false;
        [self requestUpgradeProductDataForProductIdentifiers:productIndentifiers_ andDelegate:nil];
	}
	
	return self;
}

- (void)setNumberOfCredits:(int)numberOfCredits {
    _numberOfCredits = numberOfCredits;
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:_numberOfCredits] forKey:NUMBER_OF_CREDITS_KEY];
    NSLog(@"Number of credits saved: %d", _numberOfCredits);
}

- (void) purchaseProduct: (NSString*) productID forDelegate: (id<UpgradeProductEngineDelegate>) theDelegate {
    productIndentifiers_ = [[NSArray alloc] initWithObjects:productID, nil];
    [self requestUpgradeProductDataForDelegate:theDelegate];
}


- (void)dealloc
{
	self.delegate = nil;
}

#pragma mark -
#pragma mark Product-related Methods

- (NSInteger)numberOfProducts
{
	return [products_ count];
}


- (NSString *)productIdentifierForProductAtIndex:(NSInteger)index
{
	return [productIndentifiers_ objectAtIndex:index];
}

- (SKProduct *)productAtIndex:(NSInteger)index
{
    NSString* identifier = [self productIdentifierForProductAtIndex:index];
    return [products_ objectForKey:identifier];
}


- (NSString *)descriptionForProductAtIndex:(NSInteger)index
{
    SKProduct* product = [self productAtIndex:index];
    return product.localizedDescription;
}


- (NSString *)titleForProductAtIndex:(NSInteger)index
{
    SKProduct* product = [self productAtIndex:index];
    return product.localizedTitle;
}


- (NSString *)localizedPriceStringForProductAtIndex:(NSInteger)index
{
    SKProduct* product = [self productAtIndex:index];
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    return [numberFormatter stringFromNumber:product.price];
}

- (void)requestUpgradeProductDataForProductIdentifiers:(NSArray*)identifiers andDelegate:(id<UpgradeProductEngineDelegate>)theDelegate
{
	self.delegate = theDelegate;
    [products_ removeAllObjects];
	
	SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:identifiers]];
	request.delegate = self;
    if (_showUI) {
        progressAlert_ = [self displayProgressAlertWithMessage:@"Contacting iTunes App Store..."];
    }
    
    NSLog(@"SKProductsRequest start");
	[request start];
}




- (void)requestUpgradeProductDataForDelegate:(id<UpgradeProductEngineDelegate>)theDelegate
{
	self.delegate = theDelegate;
    [products_ removeAllObjects];
	
	SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:productIndentifiers_]];
	request.delegate = self;
    if (_showUI) {
        progressAlert_ = [self displayProgressAlertWithMessage:@"Contacting iTunes App Store..."];
    }
    
    NSLog(@"SKProductsRequest start");
	[request start];
}


- (void)purchaseUpgradeProductAtIndex:(NSInteger)index forDelegate:(NSObject<UpgradeProductEngineDelegate> *)theDelegate
{
	if ( [UpgradeProductEngine canMakePurchases] && [self productAtIndex:index] ) {
		
		self.delegate = theDelegate;
        
		SKPayment *payment = [SKPayment paymentWithProduct:[self productAtIndex:index]];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:[UpgradeProductEngine upgradeEngineSingleton]];
        NSLog(@"SKPayment addPayment");
		[[SKPaymentQueue defaultQueue] addPayment:payment];
		
	} else {
		
        if (!theDelegate) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Payments not authorized", @"")
                                                                message:NSLocalizedString(@"You are not authorized to make payments for in-app purchases on this device.", @"")
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                      otherButtonTitles:nil];
            [alertView show];
        }
        if (![UpgradeProductEngine canMakePurchases]) {
            [theDelegate purchaseDidFailWithError:@"Can't make purchases on that device"];
            
        } else {
            [theDelegate purchaseDidFailWithError:@"Couldn't get product information from iTunes store"];
        }
	}
}


- (void)restorePurchases
{
	isRestoringPurchases_ = YES;
	purchasesRestored_ = NO;
    [[SKPaymentQueue defaultQueue] addTransactionObserver:[UpgradeProductEngine upgradeEngineSingleton]];
    NSLog(@"SKPayment restoreTransations");
	[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

#pragma mark -
#pragma mark SKProductsRequestDelegate Methods

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"didReceiveResponse");
	// Add the products in the response to the products array
	for ( SKProduct *product in response.products ) {
		[products_ setObject:product forKey:product.productIdentifier];
        NSLog(@"didReceiveResponse: Product ID: %@", product.productIdentifier);
        NSLog(@"Title: %@", product.localizedTitle);
        NSLog(@"Description: %@", product.localizedDescription);
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [numberFormatter setLocale:product.priceLocale];
        NSString *formattedString = [numberFormatter stringFromNumber:product.price];
        NSLog(@"Price: %@", formattedString);
	}
	
//    if ( [products_ count] ) {
//        [self purchaseUpgradeProductAtIndex:0 forDelegate:delegate];
//    } else {
//        [self dismissProgressAlert:progressAlert_];
//        [self showAlertWithTitle:@"No Upgrades Available for Purchase" andMessage:nil];
//    }
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError");
    [self dismissProgressAlert:progressAlert_];
    if (_showUI) {
        [self showAlertWithTitle:@"Product list request failed" andMessage:[error description]];
    }
	[self.delegate requestForProductDataDidFailWithError:error];
}

#pragma mark -
#pragma mark Transaction-related Methods

- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{
    NSLog(@"removedTransactions");
	if ( [transactions count] == 1 ) {
		
		SKPaymentTransaction *transaction = [transactions objectAtIndex:0];
		
		// Did the user cancel a purchase?
		if ( !isRestoringPurchases_ && [self isTransactionCancelledError:transaction.error] ) {
            
			[self.delegate purchaseWasCancelled];
		}
	}
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    NSLog(@"updatedTransactions for %lu transactions", (unsigned long)[transactions count]);
	for (SKPaymentTransaction *transaction in transactions) {
				
        [self dismissProgressAlert:progressAlert_];
		switch (transaction.transactionState) {
			case SKPaymentTransactionStatePurchasing:
			{
                NSLog(@"SKPaymentTransactionStatePurchasing");
                NSError* error = transaction.error;
                NSLog(@"%@",[error description]);
				break;
			}
			case SKPaymentTransactionStatePurchased:
			{
                NSLog(@"SKPaymentTransactionStatePurchased");
				[self completeTransaction:transaction];
				break;
			}
			case SKPaymentTransactionStateFailed:
			{
                NSLog(@"SKPaymentTransactionStateFailed");
				[self failedTransaction:transaction];
				break;
			}
			case SKPaymentTransactionStateRestored:
			{
                NSLog(@"SKPaymentTransactionStateRestored");
				[self restoreTransaction:transaction];
				break;
			}
			default:
			{
				break;
			}
		}
	}
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
	if ( isRestoringPurchases_ ) {
		
        [self showAlertWithTitle:@"You Have Purchased this Upgrade Before" andMessage:@"Your purchase was restored."];
		
	} else {
		
//        [self showAlertWithTitle:@"Upgrade successful" andMessage:@"Thank you for upgradng!"];
	}
	
	// Remove the transaction from the payment queue.
    NSLog(@"completeTransaction: SKPaymentQueue finishTransaction");
	[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
	
//	// Inform the delegate
//	if ( isRestoringPurchases_ ) {
//		
//		[self.delegate restorePurchasesDidSucceed];
//		
//	} else {
//		
//		[self.delegate purchaseDidSucceed];
//	}
    SKProduct* product = [products_ objectForKey:transaction.payment.productIdentifier];
//    if (_numberOfCredits != -1) {
//        NSInteger index = [productIndentifiers_ indexOfObject:transaction.payment.productIdentifier];
//        int numberOfCreditsPurchased = numberOfCreditsArray[index];
//        if (numberOfCreditsPurchased == -1) {
//            self.numberOfCredits = -1;
//        } else {
//            self.numberOfCredits += numberOfCreditsPurchased;
//        }
//    }
   [self.delegate purchaseDidSucceedForProduct:product.localizedTitle];
}

- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
	restoredTransation_ = transaction;
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
	
	// Remove the transaction from the payment queue.
    NSLog(@"restoreTransaction: product ID: %@", transaction.originalTransaction.payment.productIdentifier);
	[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    if ( [transaction.originalTransaction.payment.productIdentifier isEqualToString:INAPP_PURCHASE_ID]) {
        [self recordTransaction:transaction];
        [self provideContent:transaction.originalTransaction.payment.productIdentifier];
        purchasesRestored_ = YES;
    }
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
	// Inform the delegate of the error unless the error is the user cancelling the transaction
	// at any point in the process
    NSLog(@"failedTransaction: error %@", [transaction.error description]);
    NSLog(@"failedTransaction: payment.productidentifier %@", transaction.payment.productIdentifier);
    NSLog(@"failedTransaction: transaction.transactionIdentifier: %@", transaction.transactionIdentifier);
    NSLog(@"failedTransaction: date: %@", transaction.transactionDate);
    [self dismissProgressAlert:progressAlert_];
	if ( [self isTransactionCancelledError:transaction.error] ) {
		
		if ( isRestoringPurchases_ ) {
            [self showAlertWithTitle:@"" andMessage:@"Purchase cancelled"];
			
		} else {
			
		}
		
	} else  {
        
		if ( isRestoringPurchases_ ) {
			if (!self.delegate) {
                [self showAlertWithTitle:@"Purchase failed" andMessage:[transaction.error debugDescription]];
            }
			
		} else {
			if (!self.delegate) {
                [self showAlertWithTitle:@"Purchase failed" andMessage:[transaction.error localizedDescription]];
            } else {
                [self.delegate purchaseDidFailWithError:[transaction.error localizedDescription]];
            }
		}
	}
	
	// Remove the transaction from the payment queue.
    NSLog(@"failedTransaction: SKPaymentQueue finishTransaction");
	[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)provideContent:(NSString *)productIdentifier
{
	if ( [productIdentifier isEqualToString:INAPP_PURCHASE_ID] ) {
	}
	
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
	// Remove the transaction from the payment queue.
    NSLog(@"paymentQueueRestoreCompletedTransactionsFinished: Restored Transactions are once again in Queue for purchasing %@",[queue transactions]);
    NSLog(@"restoreCompletedTransactionsFailedWithError: received restored transactions: %lu", (unsigned long)queue.transactions.count);
	for (SKPaymentTransaction *transaction in queue.transactions) {
        NSLog(@"paymentQueueRestoreCompletedTransactionsFinished: restored transaction: %@", transaction.originalTransaction.payment.productIdentifier );
    }
	if ( purchasesRestored_ ) {
		if (_showUI) {
            [self showAlertWithTitle:@"You Have Purchased this Upgrade Before" andMessage:@"Your purchase was restored."];
        }
		[self.delegate restorePurchasesDidSucceed];
		
	}
    else {
        // Nothign to restore. This is a new purchase. Initiate a new transation
        SKPayment *payment = [SKPayment paymentWithProduct:[self productAtIndex:0]];
        NSLog(@"SKPayment addPayment");
        [[SKPaymentQueue defaultQueue] addPayment:payment];
	}
	
	isRestoringPurchases_ = NO;
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    NSLog(@"restoreCompletedTransactionsFailedWithError: Restored Transactions are once again in Queue for purchasing %@",[queue transactions]);
    NSLog(@"restoreCompletedTransactionsFailedWithError: received restored transactions: %lu", (unsigned long)queue.transactions.count);
    [self dismissProgressAlert:progressAlert_];
    if ( error.code == SKErrorUnknown && purchasesRestored_ ) {
        // This is probably a sandbox bug - it calls this callbak with error=0 even though the purchase seemed to have been succesfully restored
        // (updatedTransactions callback with SKPaymentTransactionStateRestored was called)
        [self showAlertWithTitle:@"You Have Purchased this Upgrade Before" andMessage:@"Your purchase was restored."];
    }
	else if ( [self isTransactionCancelledError:error] ) {
		
        if (!self.delegate) {
            [self showAlertWithTitle:@"" andMessage:@"Purchase cancelled"];
        }
		[self.delegate restorePurchasesWasCancelled];
		
	} else  {
		
        if (!self.delegate) {
            [self showAlertWithTitle:@"" andMessage:[error description]];
        }
		[self.delegate restorePurchasesDidFailWithErrors:[NSArray arrayWithObject:error]];
	}
	
	isRestoringPurchases_ = NO;
}

#pragma mark -
#pragma mark Helper Methods

- (BOOL)isTransactionCancelledError:(NSError *)error
{
	return ( [[error domain] isEqualToString:SKErrorDomain] &&
			( ( error.code == SKErrorPaymentCancelled ) /*|| ( error.code == 0 )*/ ) );
}

- (void)upgradeToFullGame
{
#if TARGET_IPHONE_SIMULATOR
	[self provideContent:INAPP_PURCHASE_ID];
#endif
}

#define V_1_5_KEY @"UpgradeEngine_Update1.5"

- (bool)firstRunForV1_5 {
    id value = [[NSUserDefaults standardUserDefaults] objectForKey:V_1_5_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:V_1_5_KEY];
    return value == nil;
}

@end
