//
//  ECPurchase.m
//  myPurchase
//
//  Created by ris on 10-4-23.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ECPurchase.h"
#import "SBJSON.h"
#import "GTMBase64.h"

/******************************
 SKProduct extend
 *****************************/
@implementation SKProduct (LocalizedPrice)

- (NSString *)localizedPrice{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:self.priceLocale];
    NSString *formattedString = [numberFormatter stringFromNumber:self.price];
    [numberFormatter release];
    return formattedString;
}

@end

/***********************************
 ECPurchaseHTTPRequest
 ***********************************/
@implementation ECPurchaseHTTPRequest
@synthesize productIdentifier = _productIdentifier;

@end

/******************************
 ECPurchase
 ******************************/
@implementation ECPurchase
@synthesize productDelegate = _productDelegate;
@synthesize transactionDelegate =_transactionDelegate;
@synthesize verifyRecepitMode = _verifyRecepitMode;

SINGLETON_IMPLEMENTATION(ECPurchase);

//you can init the object here as the object init is in SINGLETON_IMPLEMENTATION
-(void)postInit
{
	_verifyRecepitMode = ECVerifyRecepitModeNone;
	[self registerNotifications];
}

- (void)requestProductData:(NSArray *)proIdentifiers{
	NSSet *sets = [NSSet setWithArray:proIdentifiers];
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:sets];
    _productsRequest.delegate = self;
    [_productsRequest start];
}

#pragma mark -
#pragma mark SKProductsRequestDelegate methods
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    NSArray *products = response.products;
#ifdef ECPURCHASE_TEST_MODE	
	NSMutableString *result = [[NSMutableString alloc] init];
	for (int i = 0; i < [products count]; ++i) {
		SKProduct *proUpgradeProduct = [products objectAtIndex:i];
		[result appendFormat:@"%@,%@,%@,%@\n",
		 proUpgradeProduct.localizedTitle,proUpgradeProduct.localizedDescription,proUpgradeProduct.price,proUpgradeProduct.productIdentifier];
	}
    
    for (NSString *invalidProductId in response.invalidProductIdentifiers)
    {
		[result appendFormat:@"Invalid product id: %@",invalidProductId];
    }
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iap" message:result
										delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
	[_productDelegate didReceivedProducts:products];
#else
	[_productDelegate didReceivedProducts:products];

#endif   
	[_productsRequest release];
}

-(void)addTransactionObserver{
	_storeObserver = [[ECStoreObserver alloc] init];
	[[SKPaymentQueue defaultQueue] addTransactionObserver:_storeObserver];
}

-(void)removeTransactionObserver{
	[[SKPaymentQueue defaultQueue] removeTransactionObserver:_storeObserver];
}

-(void)addPayment:(NSString *)productIdentifier{
	SKPayment *payment = [SKPayment paymentWithProductIdentifier:productIdentifier];
	[[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma mark -
#pragma mark NSNotificationCenter Methods
-(void)completeTransaction:(NSNotification *)note{
	SKPaymentTransaction *trans = [[note userInfo] objectForKey:@"transaction"];
	if (_verifyRecepitMode == ECVerifyRecepitModeNone) {
		[_transactionDelegate didCompleteTransaction:trans.payment.productIdentifier];
	}
	else if(_verifyRecepitMode == ECVerifyRecepitModeiPhone){
		[self verifyReceipt:trans];
	}
	else if(_verifyRecepitMode == ECVerifyRecepitModeServer){
		[self verifyReceipt:trans];
	}
	
}

-(void)failedTransaction:(NSNotification *)note{
	SKPaymentTransaction *trans = [[note userInfo] objectForKey:@"transaction"];
	[_transactionDelegate didFailedTransaction:trans.payment.productIdentifier];
}

-(void)restoreTransaction:(NSNotification *)note{
	SKPaymentTransaction *trans = [[note userInfo] objectForKey:@"transaction"];
	[_transactionDelegate didRestoreTransaction:trans.payment.productIdentifier];
}

-(void)registerNotifications{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completeTransaction:) name:@"completeTransaction" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failedTransaction:) name:@"failedTransaction" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restoreTransaction:) name:@"restoreTransaction" object:nil];
}

-(void)verifyReceipt:(SKPaymentTransaction *)transaction
{
	_networkQueue = [ASINetworkQueue queue];
	[_networkQueue retain];
	NSURL *verifyURL = [NSURL URLWithString:VAILDATING_RECEIPTS_URL];
	ECPurchaseHTTPRequest *request = [[ECPurchaseHTTPRequest alloc] initWithURL:verifyURL];
	[request setProductIdentifier:transaction.payment.productIdentifier];
	[request setRequestMethod: @"POST"];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(didFinishVerify:)];
	//[request setShouldRedirect: NO];
	[request addRequestHeader: @"Content-Type" value: @"application/json"];
	
	//NSString *recepit = [[NSString alloc] initWithData:transaction.transactionReceipt encoding:NSUTF8StringEncoding];
	NSString *recepit = [GTMBase64 stringByEncodingData:transaction.transactionReceipt];
	//NSString * encodedString = (NSString *)CFURLCreateStringByAddingPercentEscapes(
//																				   NULL,
//																				   (CFStringRef)recepit,
//																				   NULL,
//																				   (CFStringRef)@"!*'();:@&=+$,/?%#[]",
//																				   kCFStringEncodingUTF8 );
//	NSString * encodedString =  [recepit stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];  
	NSDictionary* data = [NSDictionary dictionaryWithObjectsAndKeys:recepit, @"receipt-data", nil];
	SBJsonWriter *writer = [SBJsonWriter new];
	[request appendPostData: [[writer stringWithObject:data] dataUsingEncoding: NSUTF8StringEncoding]];
	[writer release];
	[_networkQueue addOperation: request];
	[_networkQueue go];
}

-(void)didFinishVerify:(ECPurchaseHTTPRequest *)request
{
	NSString *response = [request responseString];
	SBJsonParser *parser = [SBJsonParser new];
	NSDictionary* jsonData = [parser objectWithString: response];
	[parser release];
	NSString *status = [jsonData objectForKey: @"status"];
	if ([status intValue] == 0) {
		NSDictionary *receipt = [jsonData objectForKey: @"receipt"];
		NSString *productIdentifier = [receipt objectForKey: @"product_id"];
		[_transactionDelegate didCompleteTransactionAndVerifySucceed:productIdentifier];
	}
	else {
		NSString *exception = [jsonData objectForKey: @"exception"];
		[_transactionDelegate didCompleteTransactionAndVerifyFailed:request.productIdentifier withError:exception];
	}

}

#pragma mark -
#pragma mark Get Property From ECStoreObserver
-(NSMutableArray *)getCompleteTrans{
	return _storeObserver.completeTrans;
}

-(NSMutableArray *)getRestoreTrans{
	return _storeObserver.restoreTrans;
}

-(NSMutableArray *)getFailedTrans{
	return _storeObserver.failedTrans;
}

-(void)dealloc
{
	RELEASE_SAFELY(_networkQueue);
	RELEASE_SAFELY(_storeObserver);
	[super dealloc];
}

@end