//
//  IAPHandler.m
//  IAPDemo
//
//  Created by luoyl on 12-3-24.
//  Copyright (c) 2012年 http://luoyl.info. All rights reserved.
//

#import "IAPHandler.h"

@interface IAPHandler()
-(void)afterProductBuyed:(NSString*)proIdentifier;
@end
@implementation IAPHandler

static IAPHandler *DefaultHandle_ = nil;

+ (void)initECPurchaseWithHandler
{
	@synchronized(self)     {
        if (!DefaultHandle_) {
            DefaultHandle_ = [[IAPHandler alloc]init];
        }
    }    
}

- (id)init
{
    if (self = [super init]) {
        [[ECPurchase shared] addTransactionObserver];
        [[ECPurchase shared] setProductDelegate:self];
        [[ECPurchase shared] setTransactionDelegate:self];
        [[ECPurchase shared] setVerifyRecepitMode:ECVerifyRecepitModeiPhone];
    }
    return self;
}

#pragma mark - ECPurchaseProductDelegate
//从App Store请求产品列表后返回的产品列表
- (void)didReceivedProducts:(NSArray *)products
{
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPDidReceivedProducts object:products];
}

#pragma mark - ECPurchaseTransactionDelegate
// 如果不需要收据认证, 则实现以下3个代理函数
// 即 ECVerifyRecepitModeNone 模式下
-(void)didFailedTransaction:(NSString *)proIdentifier
{
//   NSLog(@"交易取消");
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPDidFailedTransaction object:proIdentifier];
}

-(void)didRestoreTransaction:(NSString *)proIdentifier
{
    //NSLog(@" 交易恢复 ");
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPDidRestoreTransaction object:proIdentifier];
}

-(void)didCompleteTransaction:(NSString *)proIdentifier
{
//  NSLog(@" 交易成功 ");
    [self afterProductBuyed:proIdentifier];
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPDidCompleteTransaction object:proIdentifier];
}

// 否则, 需要收据认证, 实现以下2个代理函数
// ECVerifyRecepitModeiPhone 和 ECVerifyRecepitModeServer模式下
-(void)didCompleteTransactionAndVerifySucceed:(NSString *)proIdentifier
{
    [self afterProductBuyed:proIdentifier];
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPDidCompleteTransactionAndVerifySucceed object:proIdentifier];
}

-(void)didCompleteTransactionAndVerifyFailed:(NSString *)proIdentifier withError:(NSString *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPDidCompleteTransactionAndVerifyFailed object:proIdentifier];

}

//用户购买某件商品成功后的处理逻辑
-(void)afterProductBuyed:(NSString*)proIdentifier
{
    //写下你的逻辑， 加金币 or 解锁 or ...
}
@end
