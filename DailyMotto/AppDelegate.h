//
//  AppDelegate.h
//  DailyMotto
//
//  Created by 鹏 吴 on 6/15/12.
//  Copyright (c) 2012 galiumsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECPurchase.h"
@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;

-(NSString*)dbPath;
@end