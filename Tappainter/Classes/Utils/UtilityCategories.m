//
//  UtilityCategories.m
//  Roshambo
//
//  Created by Vadim Dagman on 6/21/12.
//  Copyright (c) 2012 Digital Prunes, Inc. All rights reserved.
//

#import <objc/runtime.h>
#import "UtilityCategories.h"
#import "QuartzCore/QuartzCore.h"
//#import "MyRand.h"
#import "mach/mach.h"
#import "Defs.h"

static inline  float roundWithPrecision(float f,float pres)
{
    return (float) (floor(f*(1.0f/pres) + 0.5)/(1.0f/pres));
}

#pragma mark- NSObject Utility Category

@interface NSObject(Private)
+ (id)performBlock:(void (^)(void))block inQueue: (dispatch_queue_t) queue afterDelay:(NSTimeInterval)delay;
+ (id)performBlock:(void (^)(id arg))block inQueue: (dispatch_queue_t) queue withObject:(id)anObject afterDelay:(NSTimeInterval)delay; 
@end

@implementation NSObject (Utilities)


// returns mutable copy of the given object. Conversion is done through serialization/deserialization to JSON
-(id) convertToMutable: (id) object {
    
    NSError* error;
    NSData* JSONobject = [NSJSONSerialization dataWithJSONObject: object options: 0 error: &error];
    //    NSLog(@"Serializaion Error :%@", [error localizedDescription]);
    id mutableObject = [NSJSONSerialization 
                        JSONObjectWithData:JSONobject //1
                        
                        options:NSJSONReadingMutableContainers 
                        error:&error];
    //    NSLog(@"Deserialization Error :%@", [error localizedDescription]);
//    NSLog(@"JSON parsed :%@", mutableObject);
    return mutableObject;
}


// returns mutable copy of itselft. Conversion is done through serialization/deserialization to JSON
-(id) convertToMutable {
    
    NSError* error;
    NSData* JSONobject = [NSJSONSerialization dataWithJSONObject: self options: 0 error: &error];
    //    NSLog(@"Serializaion Error :%@", [error localizedDescription]);
    id mutableObject = [NSJSONSerialization 
                        JSONObjectWithData:JSONobject //1
                        
                        options:NSJSONReadingMutableContainers 
                        error:&error];
    //    NSLog(@"Deserialization Error :%@", [error localizedDescription]);
//    NSLog(@"JSON parsed :%@", mutableObject);
    return mutableObject;
}

-(NSString*) generateGUID {
    // Create universally unique identifier (object)
//    CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
    // Get the string representation of CFUUID object.
//    NSString *uuidString = (__bridge NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidObject);
//    CFRelease(uuidObject);
//    return uuidString;
    
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    NSString *uuid = [[NSString alloc] initWithString:(__bridge NSString *) uuidStringRef];
    CFRelease(uuidStringRef);
    return uuid;
}

-(bool) findStringInArray: (NSArray*) stringArray  equalTo: (NSString*) string {
    if ( stringArray == nil || [stringArray count] == 0 )
        return NO;
    
    return [stringArray indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if ( [string isEqualToString: obj] ) {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
}

-(id) findObjectInAarray: (NSArray*) array byKey: (NSString*) key andStringValue: (NSString*) string {
    
    if ( array == nil || [array count] == 0 )
        return nil;
    
    NSUInteger idx = [array indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if ( [string isEqualToString: [obj valueForKey:key] ] ) {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    
    if ( idx != NSNotFound )
        return [array objectAtIndex: idx];
    else {
        return nil;
    }
}

static char associativeObjectsKey;

- (id)associativeObjectForKey: (NSString *)key {
    NSMutableDictionary *dict = objc_getAssociatedObject(self, &associativeObjectsKey);
    return [dict objectForKey: key];
}

- (id)associativeObjectForKey: (NSString *)key release: (BOOL) release {
    NSMutableDictionary *dict = objc_getAssociatedObject(self, &associativeObjectsKey);
    id objectToReturn =  [dict objectForKey: key];
    if ( release )
        [dict removeObjectForKey:key];
    return objectToReturn;
}


- (void)removeAssociativeObjectForKey: (NSString *)key {
    NSMutableDictionary *dict = objc_getAssociatedObject(self, &associativeObjectsKey);
    [dict removeObjectForKey:key];
}

- (void)setAssociativeObject: (id)object forKey: (NSString *)key {
    NSMutableDictionary *dict = objc_getAssociatedObject(self, &associativeObjectsKey);
    if (!dict) {
        dict = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(self, &associativeObjectsKey, dict, OBJC_ASSOCIATION_RETAIN);
    }
    [dict setObject: object forKey: key];
}

- (UIAlertView*)displayProgressAlertWithMessage: (NSString *)message {
    UIAlertView* alert = [[UIAlertView alloc ]initWithTitle:@"" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    alert.delegate = self;
//    alert.tag = PROGRESS_ALERT_TAG;
    [alert setAssociativeObject:@"anyString" forKey:@"spinningIndicator"];
    [alert show];
    
    return alert;
}

- (UIAlertView*)displayProgressAlertWithMessage: (NSString *)message cancelButton: (NSString *) cancelButtonName{
    UIAlertView* alert = [[UIAlertView alloc ]initWithTitle:@"" message:message delegate:nil cancelButtonTitle:cancelButtonName otherButtonTitles:nil];
    alert.delegate = self;
//    alert.tag = FRIENDS_LIST_PROGRESS_ALERT_TAG;
    [alert setAssociativeObject:@"anyString" forKey:@"spinningIndicator"];
    [alert show];
    
    return alert;
}

- (void) displayAlertView: (UIAlertView *) alertView withCenter: (CGPoint) point{
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.center = point;
    [indicator startAnimating];
    [alertView addSubview:indicator];
}

- (void) willPresentAlertView:(UIAlertView *)alertView {
//    NSLog(@"Cancel Button Index: %d", alertView.cancelButtonIndex)
    NSString* string = [alertView associativeObjectForKey:@"spinningIndicator"];
    if ( string ) {
        if ( alertView.cancelButtonIndex == -1 ) {
            [self displayAlertView:alertView withCenter:CGPointMake(alertView.bounds.size.width/2, alertView.bounds.size.height-45)];
            /*UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
             indicator.center = CGPointMake(alertView.bounds.size.width/2, alertView.bounds.size.height-45);
             [indicator startAnimating];
             [alertView addSubview:indicator];*/
        }
        else if (alertView.cancelButtonIndex == 0) {
            [self displayAlertView:alertView withCenter:CGPointMake(alertView.bounds.size.width/2, alertView.bounds.size.height-90)];
            /*UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
             indicator.center = CGPointMake(alertView.bounds.size.width/2, alertView.bounds.size.height-90);
             [indicator startAnimating];
             [alertView addSubview:indicator];*/
        }
    }
}

- (void)dismissProgressAlert:(UIAlertView *)alertView {
    [alertView dismissWithClickedButtonIndex:0 animated:TRUE];   
}


- (void) showAlertWithTitle: (NSString*) title andMessage: (NSString*) message {
    [NSObject showAlertWithTitle:title andMessage:message];
}

+ (void) showAlertWithTitle: (NSString*) title andMessage: (NSString*) message {
    UIAlertView* alert = [[UIAlertView alloc ]initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (bool) coinFlip {
    return rand()%2 == 1;
}

- (void)addAndTrackObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context {
//    NSLog(@"Setting observer: %@ %x for \"%@\" on %@ %x", [[observer class] description], (__bridge void*)observer, keyPath, [[self class] description], (__bridge void*)self);
    [self addObserver:observer forKeyPath:keyPath options:options context:context];
}

- (void)removeAndTrackObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath {
//    NSLog(@"Removing observer: %@ %x for \"%@\" on %@ %x", [[observer class] description], (__bridge void*)observer, keyPath, [[self class] description], (__bridge void*)self);
    [self removeObserver:observer forKeyPath:keyPath];
}

- (BOOL)checkInternetConnectionWithErrorAlert:(bool)errorAlert {
    NSURL *url=[NSURL URLWithString:@"http://199.231.56.176:8080/tap_painter_server/picture/api_test"];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"HEAD"];
    NSHTTPURLResponse *response;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error: NULL];
    
    if (errorAlert && [response statusCode] != 200) {
        [self showAlertWithTitle:@"No Interent Connection" andMessage:@"Please try again once you have connected to the internet."];
    }
    
    return ([response statusCode]==200)?YES:NO;
}

+ (bool)isNullObject:(id)object {
    return object == nil || [object isKindOfClass:[NSNull class]];
}

-(void) report_memory {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(),
                                   TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    if( kerr == KERN_SUCCESS ) {
        NSLog(@"Memory in use (in bytes): %u", info.resident_size);
    } else {
        NSLog(@"Error with task_info(): %s", mach_error_string(kerr));
    }
}


- (void) report_memory: (NSString*) location {
#ifndef TEST_BUILD
    return;
#endif
    static NSString* filter;
    
    if ( !filter || [location hasPrefix:filter] ) {
        struct task_basic_info info;
        mach_msg_type_number_t size = sizeof(info);
        kern_return_t kerr = task_info(mach_task_self(),
                                       TASK_BASIC_INFO,
                                       (task_info_t)&info,
                                       &size);
        static unsigned int lastSize;
        if( kerr == KERN_SUCCESS ) {
            NSLog(@"%@: Memory in use (in bytes): %u Increase: %d", location, info.resident_size, info.resident_size-lastSize);
            lastSize = info.resident_size;
        } else {
            NSLog(@"%@: Error with task_info(): %s", location, mach_error_string(kerr));
        }
    }
}


@end

static inline dispatch_time_t dTimeDelay(NSTimeInterval time) {
    int64_t delta = (int64_t)(NSEC_PER_SEC * time);
    return dispatch_time(DISPATCH_TIME_NOW, delta);
}

#pragma mark- NSObect (BLocks)


@implementation NSObject (Blocks)

- (void)runBlock:(void (^)())block {
    block();
}


+ (id)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay {
//    if (!block) return nil;
//    
//    __block BOOL cancelled = NO;
//    
//    void (^wrappingBlock)(BOOL) = ^(BOOL cancel) {
//        if (cancel) {
//            cancelled = YES;
//            return;
//        }
//        if (!cancelled)block();
//    };
//    
//    wrappingBlock = [wrappingBlock copy];
//    
//	dispatch_after(dTimeDelay(delay), dispatch_get_main_queue(), ^{  wrappingBlock(NO); });
//    
//    return wrappingBlock;
    return [NSObject performBlock:block inQueue:dispatch_get_main_queue() afterDelay:delay];
}

+ (id)performBlockInBackground:(void (^)(void))block afterDelay:(NSTimeInterval)delay {
    return [NSObject performBlock:block inQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0) afterDelay:delay];
//    if (!block) return nil;
//    
//    __block BOOL cancelled = NO;
//    
//    void (^wrappingBlock)(BOOL) = ^(BOOL cancel) {
//        if (cancel) {
//            cancelled = YES;
//            return;
//        }
//        if (!cancelled)block();
//    };
//    
//    wrappingBlock = [wrappingBlock copy];
//    
//	dispatch_after(dTimeDelay(delay), dispatch_get_main_queue(), ^{  wrappingBlock(NO); });
//    
//    return wrappingBlock;
}



+ (id)performBlock:(void (^)(id arg))block withObject:(id)anObject afterDelay:(NSTimeInterval)delay {
//    if (!block) return nil;
//    
//    __block BOOL cancelled = NO;
//    
//    void (^wrappingBlock)(BOOL, id) = ^(BOOL cancel, id arg) {
//        if (cancel) {
//            cancelled = YES;
//            return;
//        }
//        if (!cancelled) block(arg);
//    };
//    
//    wrappingBlock = [wrappingBlock copy];
//    
//	dispatch_after(dTimeDelay(delay), dispatch_get_main_queue(), ^{  wrappingBlock(NO, anObject); });
//    
//    return wrappingBlock;
    return [NSObject performBlock:block inQueue: dispatch_get_main_queue() withObject:anObject afterDelay:delay];
}

+ (id)performBlockInBackground:(void (^)(id))block withObject:(id)anObject afterDelay:(NSTimeInterval)delay {
    return [NSObject performBlock:block inQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0) withObject:anObject afterDelay:delay];
}


+ (id)performBlock:(void (^)(void))block inQueue: (dispatch_queue_t)queue afterDelay:(NSTimeInterval)delay {
    if (!block) return nil;
    
    __block BOOL cancelled = NO;
    
    void (^wrappingBlock)(BOOL) = ^(BOOL cancel) {
        if (cancel) {
            cancelled = YES;
            return;
        }
        if (!cancelled)block();
    };
    
    wrappingBlock = [wrappingBlock copy];
    
	dispatch_after(dTimeDelay(delay), queue, ^{  wrappingBlock(NO); });
    
    return wrappingBlock;
}

+ (id)performBlock:(void (^)(id arg))block inQueue: (dispatch_queue_t)queue withObject:(id)anObject afterDelay:(NSTimeInterval)delay {
    if (!block) return nil;
    
    __block BOOL cancelled = NO;
    
    void (^wrappingBlock)(BOOL, id) = ^(BOOL cancel, id arg) {
        if (cancel) {
            cancelled = YES;
            return;
        }
        if (!cancelled) block(arg);
    };
    
    wrappingBlock = [wrappingBlock copy];
    
	dispatch_after(dTimeDelay(delay), dispatch_get_main_queue(), ^{  wrappingBlock(NO, anObject); });
    
    return wrappingBlock;
}


- (id)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay {
    
    if (!block) return nil;
    
    __block BOOL cancelled = NO;
    
    void (^wrappingBlock)(BOOL) = ^(BOOL cancel) {
        if (cancel) {
            cancelled = YES;
            return;
        }
        if (!cancelled) block();
    };
    
    wrappingBlock = [wrappingBlock copy];
    
	dispatch_after(dTimeDelay(delay), dispatch_get_main_queue(), ^{  wrappingBlock(NO); });
    
    return wrappingBlock;
}

- (id)performBlock:(void (^)(id arg))block withObject:(id)anObject afterDelay:(NSTimeInterval)delay {
    if (!block) return nil;
    
    __block BOOL cancelled = NO;
    
    void (^wrappingBlock)(BOOL, id) = ^(BOOL cancel, id arg) {
        if (cancel) {
            cancelled = YES;
            return;
        }
        if (!cancelled) block(arg);
    };
    
    wrappingBlock = [wrappingBlock copy];
    
	dispatch_after(dTimeDelay(delay), dispatch_get_main_queue(), ^{  wrappingBlock(NO, anObject); });
    
    return wrappingBlock;
}

+ (void) cancelBlock:(id)block {
    if (!block) return;
    void (^aWrappingBlock)(BOOL) = (void(^)(BOOL))block;
    aWrappingBlock(YES);
}


@end

#pragma mark- NSString Utility Category

@implementation NSString (Utilities)

+ (Boolean)isEmptyString:(NSString*)string
{
    return ([string isEqualToString:@""]);
}

- (Boolean)isEmptyString
{
    return self == nil || [self isEqualToString:@""];
}

- (Boolean)isValidPhoneNumber
{
    
    NSString* phone = [self leaveDigitsOnly];
    if ([phone length] < 10 || [phone length] > 11)
        return NO;
    
    if ([phone length] == 11 && [phone hasPrefix:@"1"] == NO)
        return NO;
    
    if ( [phone length] == 10 ) {
        if ( [phone hasPrefix:@"0"] || [phone hasPrefix:@"1"] )
            return NO;
    }
    
    if (![phone isOnlyNumbers])
        return NO;
    
    return YES;
}

- (Boolean)isValidZipCode {
    
    if (self.length != 5) {
        return NO;
    }
    if (![self isOnlyNumbers]) {
        return NO;
    }
    return YES;
}

- (Boolean) isValidEmailAddress
{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}

- (NSString*)normalizePhoneNumber
{
    NSString* phone = [self leaveDigitsOnly];
    
    if ([phone length] == 11 ) {
        if ( [phone hasPrefix:@"1"] == YES)
            phone = [phone substringFromIndex:1];
    }
    
    return phone;
}

-(NSString*)formatPhoneNumber {
    NSString* phone = [self normalizePhoneNumber];
    if ( !phone )
        return  nil;
    
    NSRange range;
    range.location = 0;
    range.length = 3;
    NSString* formattedPhone = [@"(" stringByAppendingString:[phone substringWithRange:range]];
    formattedPhone = [formattedPhone stringByAppendingString:@")"];
    range.location = 3;
    range.length = 3;
    formattedPhone = [formattedPhone stringByAppendingString:[phone substringWithRange:range]];
    formattedPhone = [formattedPhone stringByAppendingString:@"-"];
    range.location = 6;
    range.length = 4;
    formattedPhone = [formattedPhone stringByAppendingString:[phone substringWithRange:range]];
    return formattedPhone;
}

- (NSString*)leaveDigitsOnly {
    NSString* string = @"";
    
    for ( int idx = 0; idx < [self length]; idx ++ ) {
        unichar chr = [self characterAtIndex:idx];
        if ( chr >= '0' && chr <= '9' ) {
            NSRange range;
            range.location = idx;
            range.length = 1;
            string  = [string stringByAppendingString:[self substringWithRange:range]];
        }
    }
    
    return string;
}

- (NSString*)urlEncode {
    NSString* encoded = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes( NULL,
                                                                                              (__bridge CFStringRef)self,
                                                                                              NULL,
                                                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                              kCFStringEncodingUTF8 );
    return encoded;
}


- (NSString*)urlDecode 
{
    NSString* decoded = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapes(NULL, (__bridge CFStringRef)self, CFSTR(""));
    return decoded;
    
}

- (Boolean) isOnlyNumbers {
    NSCharacterSet *_NumericOnly = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *myStringSet = [NSCharacterSet characterSetWithCharactersInString:self];
    
    return ([_NumericOnly isSupersetOfSet: myStringSet]);
}

-(NSString*) firstWord {
    NSString* stringToReturn = self;
    NSRange range = [self rangeOfString:(NSString *)@" "];
    if ( range.location != NSNotFound ) {
        stringToReturn = [self substringToIndex:range.location];
    }
    return stringToReturn;
}

- (NSString*) stringByTrimmingFirstWord {
    NSString* stringToReturn = @"";
    NSRange range = [self rangeOfString:(NSString *)@" "];
    if ( range.location != NSNotFound ) {
        stringToReturn = [self substringFromIndex:range.location+1];
    }
    return stringToReturn;
}


-(NSInteger) findInArray: (NSArray*) stringArray {
    if ( stringArray == nil || [stringArray count] == 0 )
        return NSNotFound;
    
    return [stringArray indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if ( [self isEqualToString: obj] ) {
            *stop = TRUE;
            return YES;
        }
        else
            return NO;
    }];
}

- (CGSize) sizeWithFontiOs7:(UIFont *)fontToUse
{
    if ([self respondsToSelector:@selector(sizeWithAttributes:)])
    {
        NSDictionary* attribs = @{NSFontAttributeName:fontToUse};
        return ([self sizeWithAttributes:attribs]);
    }
    return ([self sizeWithFont:fontToUse]);
}

- (bool)containsString:(NSString *)subString {
    NSRange range = [self rangeOfString:subString];
    return range.location != NSNotFound;
}

+ (NSString*) stringWithInt: (int) number {
    return [NSString stringWithFormat:@"%d", number];
}

+ (NSString*) stringWithFloat: (float) number {
//    if (roundf(number) == number) {
//        return [self stringWithInt:number];
//    }
//    NSString* floatString = [NSString stringWithFormat:@"%.1f", number];
//    if ([floatString floatValue] == roundf(number))
//        return [self stringWithInt:roundf(number)];
//    return floatString;
    return [self stringWithFloat:number maxPresision:1];
}

+ (NSString*)stringWithFloat:(float)number maxPresision:(int)precision {
    if (roundf(number) == number) {
        return [self stringWithInt:number];
    }
    NSString* floatString;
    float floatPrecision = 0.1;
    for (int i = 1; i <= precision; i++) {
        NSString* formatString = [NSString stringWithFormat:@"%%.%df", i];
        floatString = [NSString stringWithFormat:formatString, roundWithPrecision(number, floatPrecision)];
        if ([floatString floatValue] == number)
            return floatString;
        floatPrecision /= 10.0;
    }
    return floatString;
}

- (NSString*) initWithInt: (int) number {
    self = [self initWithFormat:@"%d", number];
    if (self) {
        
    }
    
    return self;
}

+ (NSString*) timeStringFromSeconds: (int) sec {
    int hours = sec/3600;
    int minutes = sec/60;
    int seconds = sec - hours*3600 - minutes*60;
    NSString* string = @"";
    if ( hours )
        string = [string stringByAppendingString:[NSString stringWithFormat:@"%d hours ", hours]];
    if ( minutes )
        string = [string stringByAppendingString:[NSString stringWithFormat:@"%d min ", minutes]];
    string = [string stringByAppendingString:[NSString stringWithFormat:@"%d sec", seconds]];
    
    return string;
}

#ifdef TRACK_ALLOCATIONS
static int stringsAllocted;

+ (id) alloc {
    stringsAllocted++;
    return [super alloc];
}

- (void) dealloc {
    stringsAllocted--;
}

+ (int) totalAllocated {
    return stringsAllocted;
}
#endif

@end

#pragma mark- NSArray Utility Category

@implementation NSArray (Utilities)

-(NSMutableDictionary*) convertToDictionaryForPropertyKey: (NSString*) propKey {
    NSMutableDictionary* dictToReturn = [[NSMutableDictionary alloc] initWithCapacity:1];
    for ( id object in self ) {
        if ( [object valueForKey:propKey] )
            [dictToReturn setValue:object forKey:[object valueForKey:propKey]];
    }
    
    return dictToReturn;
}

-(NSMutableDictionary*) convertToDictionaryForPropertyKey:(NSString *)propKey1 andKey:(NSString *)propKey2 {
    NSMutableDictionary* dictToReturn = [[NSMutableDictionary alloc] initWithCapacity:1];
    for ( id object in self ) {
        NSString* key = @"";
        if ( [object valueForKey:propKey1] )
            key = [object valueForKey:propKey1];
        if ( [object valueForKey:propKey2]) 
            key = [key stringByAppendingString:[object valueForKey:propKey2]];
        if ( key && ![key isEmptyString] )
            [dictToReturn setValue:object forKey:key];
    }
    
    return dictToReturn;
}

- (NSMutableArray*)convertToMutableIfNeeded {
    if ([self isKindOfClass:[NSMutableArray class]]) {
        // It's allready mutable, return itself
        return (NSMutableArray*)self;
    }
    return [NSMutableArray arrayWithArray:self];
}

@end

#pragma mark- NSMutableArray Utility Category

@implementation NSMutableArray (Utilities)

-(void) mergeWithArray: (NSArray*) array {
    NSMutableArray* arrayToMergeWith = [[NSMutableArray alloc] initWithArray:array];
    [arrayToMergeWith removeObjectsInArray:self];
    [self addObjectsFromArray:arrayToMergeWith];
}

#ifdef TRACK_ALLOCATIONS
static int arraysAllocated;

+ (id) alloc {
    arraysAllocated++;
    return [super alloc];
}

- (void) dealloc {
    arraysAllocated--;
}

+ (int) totalAllocated {
    return arraysAllocated;
}
#endif

@end

#pragma mark- UILabel Utility Category

@implementation UILabel (Utilities)

-(float) sizeThatFitsMultilineWithMaxFontSize: (float) maxFontSize {
    float i;
    for(i = maxFontSize; i > 0; i=i-2) 
    {
        // Set the new font size.
        UIFont* font = [self.font fontWithSize:i];
        // You can log the size you're trying: NSLog(@"Trying size: %u", i);
        
        /* This step is important: We make a constraint box 
         using only the fixed WIDTH of the UILabel. The height will
         be checked later. */ 
        CGSize constraintSize = CGSizeMake(self.frame.size.width, MAXFLOAT);
        
        // This step checks how tall the label would be with the desired font.
        CGSize labelSize = [self.text sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
        
        /* Here is where you use the height requirement!
         Set the value in the if statement to the height of your UILabel
         If the label fits into your required height, it will break the loop
         and use that font size. */
        if(labelSize.height <= self.frame.size.height)
            return i;
    }
    
    return 0;
}

@end

#pragma mark- NSDate Utility Category

@implementation NSDate (Utilities)

-(int) minutesSinceDate: (NSDate*) date {
    float secsInMin = 60;
    NSTimeInterval secsSince = [self timeIntervalSinceDate:date];   
    return floorf(secsSince/secsInMin);
}

-(int) hoursSinceDate: (NSDate*) date  {
    float secsInHour = 60*60;
    NSTimeInterval secsSince = [self timeIntervalSinceDate:date];   
    return floorf(secsSince/secsInHour);
}

-(int) daysSinceDate: (NSDate*) date  {
    float secsInDay = 60*60*24;
    NSTimeInterval secsSince = [self timeIntervalSinceDate:date];   
    return floorf(secsSince/secsInDay);
}

-(int) weeksSinceDate: (NSDate*) date  {
    float secsInWeek = 60*60*24*7;
    NSTimeInterval secsSince = [self timeIntervalSinceDate:date];   
    return floorf(secsSince/secsInWeek);
}

-(int) monthsSinceDate: (NSDate*) date {
    float secsInMonth = 60*60*24*7*30;
    NSTimeInterval secsSince = [[NSDate date] timeIntervalSinceDate:date];   
    return floorf(secsSince/secsInMonth);
}

-(int) yearsSinceDate: (NSDate*) date  {
    float secsInYear = 60*60*24*7*365;
    NSTimeInterval secsSince = [self timeIntervalSinceDate:date];   
    return floorf(secsSince/secsInYear);
}

- (bool)sameDateAs:(NSDate *)date {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy zzz"];
    NSString* yearString = [dateFormatter stringFromDate:self];
    NSDate* yearDate = [dateFormatter dateFromString:yearString];
//    NSLog(@"Same date: %@/%@ %d/%d ref date:%@", self, date, [self daysSinceDate:yearDate], [date daysSinceDate:yearDate], yearDate);
    return [self daysSinceDate:yearDate] == [date daysSinceDate:yearDate];
}

@end

#pragma mark- UIView Utility Category

#ifdef UIView
#undef UIView
#define REDEFINE_UIVIEW
#endif

@implementation UIView (Utilities)

-(void) moveVerticallyTo: (int) y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

-(void) moveHorizontallyTo:(int)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

-(void) shiftHorizontallyBy: (int) offset {
    CGRect frame = self.frame;
    frame.origin.x += offset;
    self.frame = frame;
}

- (void)shiftVerticallyBy:(int)offset {
    CGRect frame = self.frame;
    frame.origin.y += offset;
    self.frame = frame;
}

-(void) moveToOrigin: (CGPoint) origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (float)offsetFromRightEdgeToSuperView {
    return self.superview.frame.size.width - self.frame.origin.x - self.frame.size.width;
}

+ (void) hideViews:(NSArray *)viewsArray {
    for ( UIView* view in viewsArray )
        view.hidden = YES;
}

+ (bool) isAnyViewVisible:(NSArray *)viewsArray {
    for ( UIView* view in viewsArray )
        if ( view.hidden == NO )
            return YES;
    return NO;
}

- (void)logSubViews {
    NSLog(@"%@", self);
    for (UIView* view in self.subviews) {
        [view logSubViews];
    }
}

- (void)logSubViewsForView:(UIView*)view {
    NSLog(@"%@", view);
    view.backgroundColor = [UIColor clearColor];
    for (UIView* subview in view.subviews) {
        [subview logSubViewsForView:subview];
    }
}

+ (id)loadViewFromNib:(NSString*)nibName {
    return [[[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil] objectAtIndex:0];
}

- (UIImage*)render {
    // Create a graphics context with the target size
    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
    CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(imageSize, YES, 0);
    else
        UIGraphicsBeginImageContext(imageSize);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Render the layer hierarchy to the current context
    [[self layer] renderInContext:context];
    // Retrieve the screenshot image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

@end

#pragma mark- UIViewController Utility Category
@implementation UIViewController(Utilities)

- (id)childControllerOfClass:(id)controllerClass {
    NSArray* childControllers = self.childViewControllers;
    for (UIViewController* childController in childControllers) {
        if ([childController isKindOfClass:controllerClass]) {
            return childController;
        } else if ([childController isKindOfClass:[UINavigationController class]]) {
            UINavigationController* navController = (UINavigationController*)childController;
            if ([navController.topViewController isKindOfClass:controllerClass])
                return navController.topViewController;
        }
    }
    return nil;
}

@end

#pragma mark- UIStoryboard Utility Category
static NSString* mainStoryBoardID;
@implementation UIStoryboard(Utilities)

+ (id)instantiateControllerWithId:(NSString*)controllerID {
    if (!mainStoryBoardID) {
        mainStoryBoardID = @"Main";
    }
    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:mainStoryBoardID bundle:nil];
    return [storyBoard instantiateViewControllerWithIdentifier:controllerID];
}

+ (void)setMainStoryBoardID:(NSString*)storyBoardID {
    mainStoryBoardID = storyBoardID;
}

+ (id)instantiateControllerromStoryBoard:(NSString*)storyBoardID withId:(NSString*)controllerID {
    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:storyBoardID bundle:nil];
    return [storyBoard instantiateViewControllerWithIdentifier:controllerID];
}

@end

#pragma mark- UIImageView Unitilty Category

@implementation UIImageView(Utilities)

// Translates position in imageView to original image coordinates (image is scaled in view)
- (CGPoint) positionInImage:(CGPoint) viewPosition {
    CGPoint imagePosition = viewPosition;
    imagePosition.x *= self.image.size.width/self.frame.size.width;
    imagePosition.y *= self.image.size.height/self.frame.size.height;
    NSLog(@"PositionInImage View size: %@ Imge Size: %@ Position: %@", SIZE_TO_STRING(self.frame.size), SIZE_TO_STRING(self.image.size), POINT_TO_STRING(imagePosition));
    
    return imagePosition;
}

@end

#pragma mark- UIColor Unitilty Category

@implementation UIColor(Utilities)

- (NSString *)getHexRGBString {
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    NSString *hexString=[NSString stringWithFormat:@"%02X%02X%02X", (int)(r * 255), (int)(g * 255), (int)(b * 255)];
    return hexString;
}

@end

//
//  UIImage-Extensions.m
//
//  Created by Hardy Macia on 7/1/09.
//  Copyright 2009 Catamount Software. All rights reserved.
//

static inline CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};
static inline CGFloat RadiansToDegrees(CGFloat radians) {return radians * 180/M_PI;};

#pragma mark- UIImage Utility Category

@implementation UIImage (CS_Extensions)

-(UIImage *)imageAtRect:(CGRect)rect
{
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
    UIImage* subImage = [UIImage imageWithCGImage: imageRef];
    CGImageRelease(imageRef);
    
    return subImage;
    
}

- (UIImage *)imageByScalingProportionallyToMinimumSize:(CGSize)targetSize {
    
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor;
        else
            scaleFactor = heightFactor;
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        
        if (widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        } else if (widthFactor < heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    
    // this is actually the interesting part:
    
    UIGraphicsBeginImageContext(targetSize);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(newImage == nil) NSLog(@"could not scale image");
    
    
    return newImage ;
}


- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize {
    
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor < heightFactor)
            scaleFactor = widthFactor;
        else
            scaleFactor = heightFactor;
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        
        if (widthFactor < heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        } else if (widthFactor > heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    
    // this is actually the interesting part:
    
    UIGraphicsBeginImageContext(targetSize);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(newImage == nil) NSLog(@"could not scale image");
    
    
    return newImage ;
}


- (UIImage *)imageByScalingToSize:(CGSize)targetSize {
    
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    
    //   CGSize imageSize = sourceImage.size;
    //   CGFloat width = imageSize.width;
    //   CGFloat height = imageSize.height;
    
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    //   CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    // this is actually the interesting part:
    
    UIGraphicsBeginImageContext(targetSize);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(newImage == nil) NSLog(@"could not scale image");
    
    
    return newImage ;
}

- (UIImage *)imageByScalingAspectFitToSize:(CGSize)targetSize {

    UIImage *newImage = nil;
    
    CGFloat scaleFactor = fmin(targetSize.width/self.size.width, targetSize.height/self.size.height);
    targetSize = CGSizeMake(self.size.width * scaleFactor, self.size.height * scaleFactor);
    
    UIGraphicsBeginImageContextWithOptions(targetSize, YES, 0.0);
    [self drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(newImage == nil) NSLog(@"could not scale image");
    return newImage ;
}

- (UIImage*)cgImageByScalingAspectFitToSize:(CGSize)targetSize {
    NSLog(@"Target Size: %@ Image Size: %@", SIZE_TO_STRING(targetSize), SIZE_TO_STRING(self.size));
    CGFloat scaleFactor = fmin(targetSize.width/self.size.width, targetSize.height/self.size.height);
    targetSize = CGSizeMake(self.size.width * scaleFactor, self.size.height * scaleFactor);
    
    CGContextRef cgctx = CGBitmapContextCreate(NULL, targetSize.width, targetSize.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                       CGImageGetBitmapInfo(self.CGImage));
    CGContextDrawImage(cgctx, CGRectMake(0, 0, targetSize.width, targetSize.height), self.CGImage);
    CGImageRef  ref = CGBitmapContextCreateImage(cgctx);
    UIImage* image = [UIImage imageWithCGImage:ref];
    CGImageRelease(ref);
    CGContextRelease(cgctx);
    
    NSLog(@"Scaled Image Size: %@", SIZE_TO_STRING(image.size));
    return image;
}

- (UIImage *)imageByCopyingImage {

    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    
//    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0);
    CGContextRef cgctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                               CGImageGetBitsPerComponent(self.CGImage), 0,
                                               CGImageGetColorSpace(self.CGImage),
                                               CGImageGetBitmapInfo(self.CGImage));
    CGContextDrawImage(cgctx, CGRectMake(0, 0, self.size.width, self.size.height), sourceImage.CGImage);
//    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    CGImageRef  ref = CGBitmapContextCreateImage(cgctx);
    
//    newImage = [GBImage imageWithCGImage:ref];
    newImage = [UIImage imageWithCGImage:ref];
//    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not copy image");
    CGImageRelease(ref);
    CGContextRelease(cgctx);
//
    sourceImage = nil;
    return newImage ;
}



- (UIImage *)imageRotatedByRadians:(CGFloat)radians
{
    return [self imageRotatedByDegrees:RadiansToDegrees(radians)];
}

- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees
{
    
    float newSide = MAX(self.size.width, self.size.height);
    CGSize rotatedSize =  CGSizeMake(newSide, newSide);
    
    // Create the bitmap context
    UIGraphicsBeginImageContextWithOptions(rotatedSize, NO, 0.0);  // This will make sure the image doesn't get pixelated on Retina after CGContextDrawImage
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //   // Rotate the image context
    CGContextRotateCTM(bitmap, DegreesToRadians(degrees));
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}

#define PIXEL_DATA_KEY @"PixelData"

- (UIColor*) getPixelColorAtLocation:(CGPoint)point
{
    
    UIColor* color = nil;
    
    NSData* pixelData = [self associativeObjectForKey:PIXEL_DATA_KEY];
    point.x *= self.scale;
    point.y *= self.scale;
    CGImageRef inImage = self.CGImage;

    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    
    if (!CGRectContainsPoint(CGRectMake(0, 0, w, h), point))
        return nil;
    
    unsigned char* data;
    
    if (!pixelData) {
    
        
        // Create off screen bitmap context to draw the image into. Format ARGB is 4 bytes for each pixel: Alpa, Red, Green, Blue
        CGContextRef cgctx = [self createARGBBitmapContextFromImage:inImage];
        if (cgctx == NULL) { return nil; /* error */ }
        
        CGRect rect = {{0,0},{w,h}};
        // Draw the image to the bitmap context. Once we draw, the memory
        // allocated for the context for rendering will then contain the
        // raw image data in the specified color space.
        CGContextDrawImage(cgctx, rect, inImage);
        
        // Now we can get a pointer to the image data associated with the bitmap
        // context.
        data = CGBitmapContextGetData (cgctx);
        pixelData = [NSData dataWithBytes:data length:w*h*4];
        [self setAssociativeObject:pixelData forKey:PIXEL_DATA_KEY];
        // When finished, release the context
        CGContextRelease(cgctx);
        // Free image data memory for the context
        if (data) { free(data); }
    }

    data = (unsigned char*)[pixelData bytes];
    if (data != NULL) {
        //offset locates the pixel in the data from x,y.
        //4 for 4 bytes of data per pixel, w is width of one row of data.
        int offset = 4*((w*round(point.y))+round(point.x));
        int alpha =  data[offset];
        int red = data[offset+1];
        int green = data[offset+2];
        int blue = data[offset+3];
        color = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
    }
    
    
    return color;
}

- (CIImage*)createCIImageWithColor: (UIColor*) color {
    UIGraphicsBeginImageContext(self.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, [color CGColor]);
    CGContextFillRect(ctx, CGRectMake(0, 0, self.size.width, self.size.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [[CIImage alloc] initWithCGImage:image.CGImage options:nil];
}

- (CGContextRef) createARGBBitmapContextFromImage:(CGImageRef)inImage
{
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    // Get image width, height. We'll use the entire image.
    size_t pixelsWide = CGImageGetWidth(inImage);
    size_t pixelsHigh = CGImageGetHeight(inImage);
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (int)(pixelsWide * 4);
    bitmapByteCount     = (int)(bitmapBytesPerRow * pixelsHigh);
    
    // Use the generic RGB color space.
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
    
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL)
    {
        fprintf (stderr, "Memory not allocated!");
        CGColorSpaceRelease( colorSpace );
        return NULL;
    }
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    context = CGBitmapContextCreate (bitmapData,
                                     pixelsWide,
                                     pixelsHigh,
                                     8,      // bits per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedFirst);
    if (context == NULL)
    {
        free (bitmapData);
        fprintf (stderr, "Context not created!");
    }
    
    // Make sure and release colorspace before returning
    CGColorSpaceRelease( colorSpace );
    
    return context;
}

- (UIImage *)fixOrientation {
    return self; 
    CGImageRef cgRef = self.CGImage;
    UIImage* image = [[UIImage alloc] initWithCGImage:cgRef scale:self.scale orientation:self.imageOrientation];
    return image;
}

/*
- (UIImage *)fixOrientation {
    
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    NSData *data = UIImagePNGRepresentation(self);
    UIImage *tmp = [UIImage imageWithData:data];
    UIImage *fixed = [UIImage imageWithCGImage:tmp.CGImage
                                         scale:self.scale
                                   orientation:self.imageOrientation];
    data = nil;
    tmp = nil;
    return fixed;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
//    // Now we draw the underlying CGImage into a new context, applying the transform
//    // calculated above.
//    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
//                                             CGImageGetBitsPerComponent(self.CGImage), 0,
//                                             CGImageGetColorSpace(self.CGImage),
//                                             CGImageGetBitmapInfo(self.CGImage));
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(self.size, NO, 0);
    else
        UIGraphicsBeginImageContext(self.size);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
//    // And now we just create a new UIImage from the drawing context
//    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
////    UIImage *img = [GBImage imageWithCGImage:cgimg];
//    UIImage *img = [UIImage imageWithCGImage:cgimg];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    CGContextRelease(ctx);
//    CGImageRelease(cgimg);
    return img;
}
*/

- (UIImage*)scaleWithAspectFitAndFixOrinetationToSize:(CGSize)targetSize {
    CGFloat scaleRatio = fmin(targetSize.width/self.size.width, targetSize.height/self.size.height);
    CGImageRef imgRef = self.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width*scaleRatio, height*scaleRatio);
    
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = self.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();  
    return imageCopy;  
}

- (UIImage*)cgScaleWithAspectFitAndFixOrinetationToSize:(CGSize)targetSize {
    CGFloat scaleRatio = fmin(targetSize.width/self.size.width, targetSize.height/self.size.height);
    CGImageRef imgRef = self.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width*scaleRatio, height*scaleRatio);
    
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = self.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    CGContextRef context = CGBitmapContextCreate(NULL, bounds.size.width, bounds.size.height,
                                               CGImageGetBitsPerComponent(imgRef), 0,
                                               CGImageGetColorSpace(imgRef),
                                               CGImageGetBitmapInfo(imgRef));
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imgRef);
    CGImageRef  ref = CGBitmapContextCreateImage(context);
    UIImage* imageCopy = [UIImage imageWithCGImage:ref];
    CGImageRelease(ref);
    CGContextRelease(context);
    return imageCopy;
}

- (void)releaseCGImage {
//    if (CFGetRetainCount((__bridge CFTypeRef)(self)) > 1) {
    NSLog(@"CGRefCount %d image ref Count %d",  CFGetRetainCount(self.CGImage), CFGetRetainCount((__bridge CFTypeRef)(self)));
        while (CFGetRetainCount(self.CGImage) >= CFGetRetainCount((__bridge CFTypeRef)(self))) {
            CGImageRelease(self.CGImage);
        }
//        CGImageRelease(self.CGImage);
//    }
//    else {
//        CGImageRelease(self.CGImage);
//    }
}

+ (UIImage*)screenShot
{
#ifdef APPSTORE
    return nil;
#endif
    NSLog(@"Shot");
    
    // Create a graphics context with the target size
    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
    CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(imageSize, YES, 0);
    else
        UIGraphicsBeginImageContext(imageSize);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Iterate over every window from back to front
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen])
        {
            // -renderInContext: renders in the coordinate space of the layer,
            // so we must first apply the layer's geometry to the graphics context
            CGContextSaveGState(context);
            // Center the context around the window's anchor point
            CGContextTranslateCTM(context, [window center].x, [window center].y);
            // Apply the window's transform about the anchor point
            CGContextConcatCTM(context, [window transform]);
            // Offset by the portion of the bounds left of and above the anchor point
            CGContextTranslateCTM(context,
                                  -[window bounds].size.width * [[window layer] anchorPoint].x,
                                  -[window bounds].size.height * [[window layer] anchorPoint].y);
            
            // Render the layer hierarchy to the current context
            [[window layer] renderInContext:context];
            
            // Restore the context
            CGContextRestoreGState(context);
        }
    }
    
    // Retrieve the screenshot image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

- (void) dealloc {
    [self removeAssociativeObjectForKey:PIXEL_DATA_KEY];
}


@end;

#pragma mark- UIImage(Cache)



static NSMutableDictionary *_cache = nil;
//static BOOL autoReleaseImages = FALSE;

@implementation UIImage(Cache)


//+(void)setShouldAutorelease:(BOOL)value {
//    
//    autoReleaseImages = value;
//}
//
+(void)freeCache {
    
    
    if (_cache != nil) {
        NSLog(@"Cache Freed %@", _cache);
        _cache = nil;
    }
    
}

+ (NSDictionary*) cache {
    return _cache;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

+(UIImage*)imageNamed:(NSString*)name cached: (bool) cached {
    
    if ( cached ) {
        if(_cache == nil)
            _cache = [[NSMutableDictionary alloc] init];
        
        if([_cache objectForKey:[name lastPathComponent]] != nil)
            return (UIImage*)[_cache objectForKey:[name lastPathComponent]];
    }
    
    NSString *filePath = nil;
    NSString *filePathForRetina = nil;
    NSString *filePathForiPhone5 = nil;
    NSString *filePathForiPad = nil;
    
    if([name hasPrefix:@"/"]) {
        
        // NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        // NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
        
        filePath = [name copy];
        name = [name lastPathComponent];
        
    } else {
        
        NSArray *comps = [name componentsSeparatedByString:@"."];
        NSString* ext;
        NSString* fileBaseName = name;
        if ( [comps count] > 1 ) {
            ext = [comps lastObject];
            fileBaseName = [name substringToIndex:[name length]-[ext length]-1];
        }
        else
            ext = @"png";
        
        filePath = [[NSBundle mainBundle] pathForResource:fileBaseName
                                                   ofType:ext];
        NSString* baseNameForRetina = [NSString stringWithFormat:@"%@@2x", fileBaseName];
        filePathForRetina = [[NSBundle mainBundle] pathForResource:baseNameForRetina
                                                            ofType:ext];
        NSString* baseNameForiPad = [NSString stringWithFormat:@"%@_iPad", fileBaseName];
        filePathForiPad = [[NSBundle mainBundle] pathForResource:baseNameForiPad
                                                            ofType:ext];
        NSString* baseNameForiPhone5 = [NSString stringWithFormat:@"%@-568h", fileBaseName];
        filePathForiPhone5 = [[NSBundle mainBundle] pathForResource:baseNameForiPhone5
                                                          ofType:ext];
   }
    
    UIImage *image = nil;
    
//    if(autoReleaseImages)
//        image = [[UIImage imageWithContentsOfFile:filePath] autorelease];
//    else
    if ( IS_RETINA && !IS_IPAD ) {
        if ( IS_IPHONE_5 )
            image = [[UIImage alloc] initWithContentsOfFile:filePathForiPhone5];
        if ( !image ) {
            image = [[UIImage alloc] initWithContentsOfFile:filePathForRetina];
            if ( !image )
                image = [[UIImage alloc] initWithContentsOfFile:filePath];
        }
    } else if ( IS_IPAD  ) {
        image = [[UIImage alloc] initWithContentsOfFile:filePathForiPad];
        if ( !image ) {
            image = [[UIImage alloc] initWithContentsOfFile:filePath];
            if ( !image ) {
                image = [[UIImage alloc] initWithContentsOfFile:filePathForRetina];
                if (image) {
                    image = [[UIImage alloc] initWithCGImage:image.CGImage scale:2.0 orientation:UIImageOrientationUp];
                }
            }
        }
    } else {
        image = [[UIImage alloc] initWithContentsOfFile:filePath];
        if ( !image )
            image = [[UIImage alloc] initWithContentsOfFile:filePathForRetina];
    }
    NSString* assertMessage = [NSString stringWithFormat:@"Image Not Found %@",name];
//    NSAssert(image, assertMessage);
    
    if ( cached && image) {
        [_cache setObject:image forKey:[name lastPathComponent]];
    }
    
    return image;
}

//+(UIImage*)imageNamed:(NSString*)name {
//    
//    return [UIImage imageNamed:name cached:YES];
//}
//
#ifdef TRACK_ALLOCATIONS
static int imagesAllocated;
+ (id) alloc {
    imagesAllocated++;
    return [super alloc];
}

- (void) dealloc {
    imagesAllocated--;
}

+ (int) totalAllocated {
    return imagesAllocated;
}
#endif
#pragma clang diagnostic pop

@end

