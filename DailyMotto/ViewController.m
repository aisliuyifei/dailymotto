//
//  ViewController.m
//  DailyMotto
//
//  Created by 鹏 吴 on 3/20/12.
//  Copyright (c) 2012 galiumsoft. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "InfoViewController.h"
#define kWBSDKDemoAppKey @"1638447496"
#define kWBSDKDemoAppSecret @"4866007a20e88747b5ae101d6c796aaa"
#define kWBAlertViewLogOutTag 100
#define kWBAlertViewLogInTag  101
@interface ViewController ()

@end

@implementation ViewController
@synthesize weiBoEngine;

- (void)viewDidLoad
{
    [super viewDidLoad];
    labelTitle.shadowColor = [UIColor blackColor];
    labelTitle.shadowOffset = CGSizeZero;
    labelTitle.shadowBlur = 10.0f;
    labelTitle.innerShadowColor = [UIColor yellowColor];
    labelTitle.innerShadowOffset = CGSizeMake(1.0f, 2.0f);
    labelTitle.gradientStartColor = [UIColor yellowColor];
    labelTitle.gradientEndColor = [UIColor yellowColor];
    labelTitle.gradientStartPoint = CGPointMake(0.0f, 0.5f);
    labelTitle.gradientEndPoint = CGPointMake(1.0f, 0.5f);
    labelTitle.oversampling = 2;
    UIFont *tfont = [UIFont fontWithName:@"迷你简启体" size:24];  
    labelTitle.font = tfont;

	// Do any additional setup after loading the view, typically from a nib.
    scratchViewController =[[ScrachViewController alloc] initWithNibName:@"ScratchViewClear" bundle:nil];
    scratchView = scratchViewController.view;
    toolView = [[ToolViewController alloc] initWithNibName:@"ToolViewController" bundle:nil];
    [toolView.view setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height-toolView.view.frame.size.height/2)];
    toolView.delegate = self;
    WBEngine *engine = [[WBEngine alloc] initWithAppKey:kWBSDKDemoAppKey appSecret:kWBSDKDemoAppSecret];
    [engine setRootViewController:self];
    [engine setDelegate:self];
    [engine setRedirectURI:@"http://"];
    [engine setIsUserExclusive:NO];
    self.weiBoEngine = engine;
    [engine release];

}




-(void)viewWillAppear:(BOOL)animated{
    NSString *test = [self getFirstMotto];
    [labelTest setText:test];
    UIFont *tfont = [UIFont fontWithName:@"迷你简启体" size:17]; 
    labelTest.font = tfont;  
    
    
    NSDate * date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:(@"yyyy年MM月dd日")];
    NSMutableString *dateStr = [NSMutableString stringWithString: [formatter stringFromDate:date]];
    tfont = [UIFont fontWithName:@"迷你简启体" size:20];  
    labelDate.font = tfont;
    [labelDate setText:dateStr];
    [super viewWillAppear:animated];
}

-(NSString *)getFirstMotto{
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    FMDatabase *db = [FMDatabase databaseWithPath:[delegate dbPath]];
    db.logsErrors = YES;
    if (![db open]) {
        return @"今天你不再需要金句了。";
    }
    NSDate * date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:(@"yyyy-MM-dd")];
    NSMutableString *ds = [NSMutableString stringWithString: [formatter stringFromDate:date]];
    
    NSString *tmpStr = [NSString stringWithFormat:@"SELECT \"my_motto_dailies\".* FROM \"my_motto_dailies\" WHERE DATE(created_at)= '%@'",ds]; 
    FMResultSet *s_today = [db executeQuery: tmpStr];
    if ([s_today next]) {
        //今日已经抽取
        NSString * result = [s_today stringForColumn:@"motto"];
        [db close];
        
        //显示今日刮刮卡上次刮完的样子
        [scratchViewController loadScratchPaperWithPath:@"scratch_it"];
        [scratchView setFrame:self.view.frame];
        [self.view addSubview:scratchView];
        scratchView.center = CGPointMake(scratchView.center.x-5, scratchView.center.y+20);
        [self.view addSubview:toolView.view];
        [self.view addSubview:buttonInfo];

        return result;
    }
    
    FMResultSet *s = [db executeQuery:@"SELECT * FROM 'mottos' order by random() limit 1"];
    if ([s next]) {
        NSDate * date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        
        [formatter setDateFormat:(@"yyyy-MM-dd HH:mm:ss")];
        NSMutableString *dateStr = [NSMutableString stringWithString: [formatter stringFromDate:date]];
        
        NSString * result = [s stringForColumn:@"content"];
//        [db executeUpdate:[NSString stringWithFormat:@"INSERT INTO \"my_motto_dailies\" (\"created_at\", \"day\", \"motto\", \"updated_at\") VALUES (DATETIME('now'), DATETIME('now'), \"%@\", DATETIME('now'))",result]];
        [db executeUpdate:[NSString stringWithFormat:@"INSERT INTO \"my_motto_dailies\" (\"created_at\", \"day\", \"motto\", \"updated_at\") VALUES (\"%@\", \"%@\", \"%@\", \"%@\")",dateStr,dateStr,result,dateStr]];
        [db close];
        [scratchViewController setImageNamed:@"a.002.png"];
        [scratchView setFrame:self.view.frame];
        [self.view addSubview:scratchView];
        scratchView.center = CGPointMake(scratchView.center.x-5, scratchView.center.y+20);
        [self.view addSubview:toolView.view];
        [self.view addSubview:buttonInfo];

        return result;
    }
    
    [db close];
    return @"今天你不再需要金句了。";
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)mailClicked{
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:@"每日金句"];
    
    NSArray *bccRecipients = [NSArray arrayWithObject:@"wupeng_ios@foxmail.com"]; 
    [controller setBccRecipients:bccRecipients];
    
    CGSize a= CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height-100);
    UIGraphicsBeginImageContext(a);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *currentScreen = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    NSData *imageData = UIImagePNGRepresentation(currentScreen);
    [controller addAttachmentData:imageData mimeType:@"image/png" fileName:@"motto_today.png"];
    
    
    [controller setMessageBody:@"今天我的金句是：" isHTML:YES];
    
    [self presentModalViewController:controller animated:YES];
    
    [controller release];
}
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error{
    if (result == MFMailComposeResultSent) {
        [self showAlert:@"邮件已进入后台发送" withTitle:@"提醒"];
    }
    [self dismissModalViewControllerAnimated:YES];
}

-(void)saveClicked{
    CGSize a= CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height-100);
    UIGraphicsBeginImageContext(a);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *currentScreen = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    UIImageWriteToSavedPhotosAlbum(currentScreen, self,nil,nil);
    [self showAlert:@"已保存到相册" withTitle:@"已保存"];

}
-(void)weiboClicked{
    if ([self.weiBoEngine isLoggedIn] && ![self.weiBoEngine isAuthorizeExpired]){
        NSLog(@"a");
        [self performSelector:@selector(onAuthedAndPrepareToSend) withObject:nil afterDelay:0.0];
    }else {
        NSLog(@"b");
        [weiBoEngine logIn];

    }
}

- (void)onAuthedAndPrepareToSend
{
    CGSize a= CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height-100);
    UIGraphicsBeginImageContext(a);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *currentScreen = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    WBSendView *sendView = [[WBSendView alloc] initWithAppKey:kWBSDKDemoAppKey appSecret:kWBSDKDemoAppSecret text:@"我今天的金句是：" image:currentScreen];
    [sendView setDelegate:self];
    
    [sendView show:YES];
    [sendView release];
}

#pragma mark - WBSendViewDelegate Methods

- (void)sendViewDidFinishSending:(WBSendView *)view
{
    [view hide:YES];
    UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:nil 
													   message:@"微博发送成功！" 
													  delegate:nil
											 cancelButtonTitle:@"确定" 
											 otherButtonTitles:nil];
	[alertView show];
	[alertView release];
}

- (void)engineDidLogIn:(WBEngine *)engine
{
    [self performSelector:@selector(onAuthedAndPrepareToSend) withObject:nil afterDelay:0.0];
}

- (void)engine:(WBEngine *)engine didFailToLogInWithError:(NSError *)error
{
    NSLog(@"didFailToLogInWithError: %@", error);
    UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:nil 
													   message:@"登录失败！" 
													  delegate:nil
											 cancelButtonTitle:@"确定" 
											 otherButtonTitles:nil];
	[alertView show];
	[alertView release];
}


- (void)sendView:(WBSendView *)view didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    [view hide:YES];
    UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:nil 
													   message:@"微博发送失败！" 
													  delegate:nil
											 cancelButtonTitle:@"确定" 
											 otherButtonTitles:nil];
	[alertView show];
	[alertView release];
}

- (void)sendViewNotAuthorized:(WBSendView *)view
{
    [view hide:YES];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)sendViewAuthorizeExpired:(WBSendView *)view
{
    [view hide:YES];
    [self dismissModalViewControllerAnimated:YES];
}



-(IBAction)infoClicked:(id)sender{
    InfoViewController *infoViewController = [[InfoViewController alloc] initWithNibName:@"InfoViewController" bundle:nil];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:1.0];
    [self.navigationController pushViewController:infoViewController animated:NO];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
    
    [UIView commitAnimations];

    
}
-(void)showAlert:(NSString *)message withTitle:(NSString*)title{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
}


@end
