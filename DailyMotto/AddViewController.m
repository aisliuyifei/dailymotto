//
//  AddViewController.m
//  便利记事贴
//
//  Created by 鹏 吴 on 4/11/12.
//  Copyright (c) 2012 galiumsoft. All rights reserved.
//

#import "AddViewController.h"

@interface AddViewController ()

@end

@implementation AddViewController

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
    bannerView = [[ADBannerView alloc]init];
    bannerView.delegate=self;
    [bannerView setHidden:YES];
    [self.view addSubview:bannerView];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated{
    [self.view addSubview:bannerView];
    [self.view bringSubviewToFront:bannerView];
    if ([bannerView isHidden]) {
        [self.view bringSubviewToFront:gAdBannerView];
    }
    [super viewWillAppear:animated];
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

- (void)layoutAnimated:(BOOL)animated
{
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
    } else {
        bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
    }
    
    CGRect contentFrame = self.view.bounds;
    CGRect bannerFrame = bannerView.frame;
    if (bannerView.bannerLoaded) {
        contentFrame.size.height -= bannerView.frame.size.height;
        bannerFrame.origin.y = contentFrame.size.height;
    } else {
        bannerFrame.origin.y = contentFrame.size.height;
    }
    [UIView animateWithDuration:animated ? 0.25 : 0.0 animations:^{
        bannerView.frame = bannerFrame;
    }];
}
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    [self layoutAnimated:YES];
    [banner setHidden:NO];
}

-(void)addAdMobBanner{
    if ([AppDelegate isRunningOniPad]) {
        gAdBannerView= [[GADBannerView alloc]
                        initWithFrame:CGRectMake(0.0,
                                                 self.view.frame.size.height -
                                                 GAD_SIZE_728x90.height,
                                                 768,
                                                 GAD_SIZE_728x90.height)];
        gAdBannerView.adUnitID = @"a14fb75ebdbb8a1";
    }else {
        gAdBannerView= [[GADBannerView alloc]
                        initWithFrame:CGRectMake(0.0,
                                                 self.view.frame.size.height -
                                                 GAD_SIZE_320x50.height,
                                                 GAD_SIZE_320x50.width,
                                                 GAD_SIZE_320x50.height)];

        gAdBannerView.adUnitID = @"a14fb75d91ceb9f";
    }
    
    // 告知运行时文件，在将用户转至广告的展示位置之后恢复哪个 UIViewController 
    // 并将其添加至视图层级结构。
    gAdBannerView.rootViewController = self;
    [self.view addSubview:gAdBannerView];
    
    // 启动一般性请求并在其中加载广告。
    [gAdBannerView loadRequest:[GADRequest request]];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    if (banner.hidden == NO)
    {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        // assumes the banner view is at the top of the screen.
        banner.frame = CGRectOffset(banner.frame, 0, -50);
        [UIView commitAnimations];
        banner.hidden = YES;
    }
    [self addAdMobBanner];
      
}


- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    [self layoutAnimated:YES];
    
}

@end
