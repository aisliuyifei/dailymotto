//
//  ToolViewController.h
//  每日金句
//
//  Created by 鹏 吴 on 6/15/12.
//  Copyright (c) 2012 galiumsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ToolDelegate;
 
@interface ToolViewController : UIViewController{
    id<ToolDelegate> delegate;
}

-(IBAction)buttonSaveClicked:(id)sender;
-(IBAction)buttonMailClicked:(id)sender;
-(IBAction)buttonWeiboClicked:(id)sender;
@property(nonatomic,retain)id<ToolDelegate>delegate;
@end

@protocol ToolDelegate<NSObject>
-(void)saveClicked;
-(void)mailClicked;
-(void)weiboClicked;


@end
