//
//  IAPHandler.h
//  IAPDemo
//
//  Created by luoyl on 12-3-24.
//  Copyright (c) 2012年 http://luoyl.info. All rights reserved.
//

#define IAPDidReceivedProducts                      @"IAPDidReceivedProducts"
#define IAPDidFailedTransaction                     @"IAPDidFailedTransaction"
#define IAPDidRestoreTransaction                    @"IAPDidRestoreTransaction"
#define IAPDidCompleteTransaction                   @"IAPDidCompleteTransaction"
#define IAPDidCompleteTransactionAndVerifySucceed   @"IAPDidCompleteTransactionAndVerifySucceed"
#define IAPDidCompleteTransactionAndVerifyFailed    @"IAPDidCompleteTransactionAndVerifyFailed"
#import <Foundation/Foundation.h>
#import "ECPurchase.h"

@interface IAPHandler : NSObject<ECPurchaseTransactionDelegate, ECPurchaseProductDelegate>

+ (void)initECPurchaseWithHandler;
@end
