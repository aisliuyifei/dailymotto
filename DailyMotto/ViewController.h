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
@interface ViewController : UIViewController<ToolDelegate>
{
    IBOutlet FXLabel *labelTitle;
    IBOutlet FXLabel *labelTest;
    IBOutlet FXLabel *labelDate;
    ScrachViewController *scratchViewController;
    UIView* scratchView;
    ToolViewController *toolView;
}
@end
