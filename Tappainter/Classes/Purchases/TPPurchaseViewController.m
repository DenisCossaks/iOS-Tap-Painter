//
//  TPPurchaseViewController.m
//  Tappainter
//
//  Created by Vadim on 12/6/13.
//  Copyright (c) 2013 MDi Touch. All rights reserved.
//

#import "TPPurchaseViewController.h"
#import "UpgradeProductEngine.h"
#import "TPRoundedButton.h"
#import "UtilityCategories.h"
#import "Flurry.h"

@interface TPPurchaseViewController () {
    
    IBOutletCollection(UILabel) NSArray *descriptionLabels_;
    IBOutletCollection(UILabel) NSArray *titleLabels_;
    IBOutletCollection(UIButton) NSArray *buyButtons_;
}

@end


@implementation TPPurchaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UpgradeProductEngine* upgradeEngine = [UpgradeProductEngine upgradeEngineSingleton];
    for (UILabel* label in descriptionLabels_) {
        NSString* description = [upgradeEngine descriptionForProductAtIndex:label.tag];
        if (description) {
            label.text = description;
        }
    }
    for (UILabel* label in titleLabels_) {
        NSString* title = [upgradeEngine titleForProductAtIndex:label.tag];
        if (title) {
            // Trim last word first
            NSArray* components = [title componentsSeparatedByString:@" "];
            title = components[0];
            for (int i = 1; i < components.count-1; i++) {
                title = [title stringByAppendingString:@" "];
                title = [title stringByAppendingString:components[i]];
            }
            label.text = [title uppercaseString];
        }
    }
    for (UIButton* button in buyButtons_) {
        NSString* price = [upgradeEngine localizedPriceStringForProductAtIndex:button.tag];
        if (price) {
            [button setTitle:price forState:UIControlStateNormal];
            [button setTitle:price forState:UIControlStateHighlighted];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)buyAction:(id)sender {
    UIButton* button = (UIButton*)sender;
    UpgradeProductEngine* upgradeEngine = [UpgradeProductEngine upgradeEngineSingleton];
    upgradeEngine.showUI = YES;
    [Flurry logEvent:@"Purchase Attempted" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                                  [[UpgradeProductEngine upgradeEngineSingleton] productIdentifierForProductAtIndex:button.tag], @"Package",
                                                  nil]];
    [[UpgradeProductEngine upgradeEngineSingleton] purchaseUpgradeProductAtIndex:button.tag forDelegate:self];
}

- (void)purchaseDidFailWithError:(NSString*)error {
    [self showAlertWithTitle:@"iTunes Error" andMessage:error];
    [Flurry logError:@"Purchase Failed" message:error error:nil];
}

- (void)purchaseWasCancelled {
    [Flurry logEvent:@"Purchase Cancelled"];
    [self showAlertWithTitle:@"" andMessage:@"Purchase cancelled"];
}

- (void)purchaseDidSucceedForProduct: (NSString*) productTitle {
    [Flurry logEvent:@"Purchased" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                                  productTitle, @"Package",
                                                  nil]];
    NSString* message = [NSString stringWithFormat:@"You have purchased %@ package", productTitle];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Purchase Successfull!" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
