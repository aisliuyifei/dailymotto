//
//  ECPurchase.h
//  myPurchase
//
//  Created by ris on 10-4-23.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "ECStoreObserver.h"
#import "ASINetworkQueue.h"
#import "ASIHTTPRequest.h"

#define ECLOG NSLogb

#ifndef RELEASE_SAFELY(__POINTER)
#define RELEASE_SAFELY(__POINTER) { [__POINTER release]; __POINTER = nil; }
#endif

#ifdef ECPURCHASE_TEST_SERVER
#define VAILDATING_RECEIPTS_URL @"https://sandbox.itunes.apple.com/verifyReceipt"
#else
#define VAILDATING_RECEIPTS_URL @"https://sandbox.itunes.apple.com/verifyReceipt"
//#define VAILDATING_RECEIPTS_URL @"https://buy.itunes.apple.com/verifyReceipt"
#endif

#ifndef SINGLETON_INTERFACE(CLASSNAME)
#define SINGLETON_INTERFACE(CLASSNAME)  \
+ (CLASSNAME*)shared;
#endif

#ifndef SINGLETON_IMPLEMENTATION(CLASSNAME)			
#define SINGLETON_IMPLEMENTATION(CLASSNAME)         \
\
static CLASSNAME* g_shared##CLASSNAME = nil;        \
\
+ (CLASSNAME*)shared                                \
{                                                   \
if (g_shared##CLASSNAME != nil) {                   \
return g_shared##CLASSNAME;                         \
}                                                   \
\
@synchronized(self) {                               \
if (g_shared##CLASSNAME == nil) {                    \
g_shared##CLASSNAME = [[self alloc]  init];      \
[g_shared##CLASSNAME postInit];	\
\
}                                                   \
}                                                   \
\
return g_shared##CLASSNAME;                         \
}                                                   \
\
+ (id)allocWithZone:(NSZone*)zone                   \
{                                                   \
@synchronized(self) {                               \
if (g_shared##CLASSNAME == nil) {                   \
g_shared##CLASSNAME = [super allocWithZone:zone];	\
return g_shared##CLASSNAME;                         \
}                                                   \
}                                                   \
NSAssert(NO, @ "[" #CLASSNAME                       \
" alloc] explicitly called on singleton class.");   \
return nil;                                         \
}                                                   \
\
- (id)copyWithZone:(NSZone*)zone                    \
{                                                   \
return self;                                        \
}                                                   \
\
- (id)retain                                        \
{                                                   \
return self;                                        \
}                                                   \
\
- (unsigned)retainCount                             \
{                                                   \
return UINT_MAX;                                    \
}                                                   \
\
- (void)release                                     \
{                                                   \
}                                                   \
\
- (id)autorelease                                   \
{                                                   \
return self;                                        \
}
#endif

/**************************************
 ECPurchaseTransactionDelegate
 **************************************/
@protocol ECPurchaseTransactionDelegate
@required
-(void)didFailedTransaction:(NSString *)proIdentifier;
-(void)didRestoreTransaction:(NSString *)proIdentifier;
@optional
//if you do not need to verify receipt,plz implement this function
-(void)didCompleteTransaction:(NSString *)proIdentifier;
//if you want to verify receipt via iphone or server,plz implement the follow functions
-(void)didCompleteTransactionAndVerifySucceed:(NSString *)proIdentifier;
-(void)didCompleteTransactionAndVerifyFailed:(NSString *)proIdentifier withError:(NSString *)error;
@end

/***********************************
 ECPurchaseProductDelegate
 ***********************************/
@protocol ECPurchaseProductDelegate
@required
-(void)didReceivedProducts:(NSArray *)products;
@end

typedef enum  {
	ECTransactionStatusComplete,
	ECTransactionStatusRestore,
	ECTransactionStatusFailed
}ECTransactionStatus;

typedef enum {
	ECVerifyRecepitModeiPhone,
	ECVerifyRecepitModeServer,
	ECVerifyRecepitModeNone
}ECVerifyRecepitMode;

/******************************
 SKProduct extend
 *****************************/
@interface SKProduct (LocalizedPrice)

@property (nonatomic, readonly) NSString *localizedPrice;

@end

/***********************************
 ECPurchaseHTTPRequest
 ***********************************/
@interface ECPurchaseHTTPRequest:ASIHTTPRequest{
	NSString *_productIdentifier;
}
@property(nonatomic,retain) NSString *productIdentifier;
@end

/******************************
 ECPurchase
 ******************************/
@interface ECPurchase : NSObject <SKProductsRequestDelegate>{
    SKProductsRequest		*_productsRequest;
	id<ECPurchaseProductDelegate>	_productDelegate;
	id<ECPurchaseTransactionDelegate>	_transactionDelegate;
	ECStoreObserver			*_storeObserver;
	ASINetworkQueue			*_networkQueue;
	ECVerifyRecepitMode		_verifyRecepitMode;
}
SINGLETON_INTERFACE(ECPurchase);
@property(assign) id<ECPurchaseProductDelegate> productDelegate;
@property(assign) id<ECPurchaseTransactionDelegate> transactionDelegate;
//verify recepit mode,enum ECVerifyRecepitMode,default is ECVerifyRecepitModeNone
@property(assign) ECVerifyRecepitMode verifyRecepitMode;
-(void)postInit;
-(void)requestProductData:(NSArray *)proIdentifiers;
-(void)addTransactionObserver;
-(void)removeTransactionObserver;
- (void)addPaymentWithProduct:(SKProduct *)product;
-(void)addPayment:(NSString *)productIdentifier;
-(void)registerNotifications;
-(void)verifyReceipt:(SKPaymentTransaction *)transaction;

-(NSMutableArray *)getCompleteTrans;
-(NSMutableArray *)getRestoreTrans;
-(NSMutableArray *)getFailedTrans;

/*
 NSNotificationCenter method*/
-(void)completeTransaction:(NSNotification *)note;
-(void)failedTransaction:(NSNotification *)note;
-(void)restoreTransaction:(NSNotification *)note;
@end


