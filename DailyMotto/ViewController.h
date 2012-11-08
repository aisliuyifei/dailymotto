//
//  ViewController.h
//  DailyMotto
//
//  Created by 鹏 吴 on 3/20/12.
//  Copyright (c) 2012 galiumsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDatabase.h"
#import "FXLabel.h"
#import "ScrachViewController.h"
#import "ToolViewController.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "WBEngine.h"
#import "WBSendView.h"
#import "WBLogInAlertView.h"
#import "AddViewController.h"

@interface ViewController : AddViewController<ToolDelegate,MFMailComposeViewControllerDelegate,WBEngineDelegate, UIAlertViewDelegate, WBLogInAlertViewDelegate,WBSendViewDelegate>
{
    IBOutlet FXLabel *labelTitle;
    IBOutlet FXLabel *labelTest;
    IBOutlet FXLabel *labelDate;
    WBEngine *weiBoEngine;
    UIActivityIndicatorView *indicatorView;

    ScrachViewController *scratchViewController;
    UIView* scratchView;
    ToolViewController *toolView;
    IBOutlet UIButton *buttonInfo;
}
@property (nonatomic, retain) WBEngine *weiBoEngine;
-(IBAction)infoSelected:(id)sender;
@end
