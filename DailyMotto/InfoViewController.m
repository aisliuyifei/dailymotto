//
//  InfoViewController.m
//  每日金句
//
//  Created by 鹏 吴 on 6/21/12.
//  Copyright (c) 2012 galiumsoft. All rights reserved.
//

#import "InfoViewController.h"
#import "IAPHandler.h"
@interface InfoViewController ()

@end

@implementation InfoViewController

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
    [self registIapObservers];
    [IAPHandler initECPurchaseWithHandler];
    NSArray *productIds = [NSArray arrayWithObjects:@"com.galiumsoft.iap.remove_ad_dailymotto", nil];
    [[ECPurchase shared]requestProductData:productIds];

    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)closeButtonClicked:(id)sender{
    [UIView  beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.75];

    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:NO];
    [UIView commitAnimations];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelay:0.375];
    [self.navigationController popViewControllerAnimated:NO];
    [UIView commitAnimations];}

//接收从app store抓取回来的产品，显示在表格上
-(void) receivedProducts:(NSNotification*)notification
{
    NSArray *products_ = [[NSArray alloc]initWithArray:[notification object]];
    if (!products_ || [products_ count] == 0) {
        NSLog(@"No IAP found");
        
    }
}


// 注册IapHander的监听器，并不是所有监听器都需要注册，
// 这里可以根据业务需求和收据认证模式有选择的注册需要
- (void)registIapObservers
{
    [[NSNotificationCenter defaultCenter]addObserver:self 
                                            selector:@selector(receivedProducts:) 
                                                name:IAPDidReceivedProducts 
                                              object:nil];

    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(failedTransaction:)
                                                name:IAPDidFailedTransaction 
                                              object:nil];

    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(restoreTransaction:) 
                                                name:IAPDidRestoreTransaction 
                                              object:nil];

    [[NSNotificationCenter defaultCenter]addObserver:self 
                                            selector:@selector(completeTransaction:)
                                                name:IAPDidCompleteTransaction object:nil];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(completeTransactionAndVerifySucceed:) 
                                                name:IAPDidCompleteTransactionAndVerifySucceed 
                                              object:nil];

    [[NSNotificationCenter defaultCenter]addObserver:self 
                                            selector:@selector(completeTransactionAndVerifyFailed:) 
                                                name:IAPDidCompleteTransactionAndVerifyFailed 
                                              object:nil];
}

-(void)showAlertWithMsg:(NSString*)message
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"IAP反馈" 
                                                   message:message 
                                                  delegate:nil 
                                         cancelButtonTitle:@"OK" 
                                         otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
}

-(void) failedTransaction:(NSNotification*)notification
{
    [self showAlertWithMsg:[NSString stringWithFormat:@"交易取消(%@)",[notification name]]]; 
}

-(void) restoreTransaction:(NSNotification*)notification
{
    [self showAlertWithMsg:[NSString stringWithFormat:@"交易恢复(%@)",[notification name]]]; 
}

-(void )completeTransaction:(NSNotification*)notification
{
    [self showAlertWithMsg:[NSString stringWithFormat:@"交易成功(%@)",[notification name]]]; 
}

-(void) completeTransactionAndVerifySucceed:(NSNotification*)notification
{
    NSString *proIdentifier = [notification object];
    [self showAlertWithMsg:[NSString stringWithFormat:@"交易成功"]];
}

-(void) completeTransactionAndVerifyFailed:(NSNotification*)notification
{
    NSString *proIdentifier = [notification object];
    [self showAlertWithMsg:[NSString stringWithFormat:@"交易失败",proIdentifier]];
}

@end


