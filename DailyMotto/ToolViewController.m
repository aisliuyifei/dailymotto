//
//  ToolViewController.m
//  每日金句
//
//  Created by 鹏 吴 on 6/15/12.
//  Copyright (c) 2012 galiumsoft. All rights reserved.
//

#import "ToolViewController.h"

@interface ToolViewController ()

@end

@implementation ToolViewController
@synthesize delegate;
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

-(IBAction)buttonSaveClicked:(id)sender{
    [delegate saveClicked];
}

-(IBAction)buttonMailClicked:(id)sender{
    [delegate mailClicked];
}

-(IBAction)buttonWeiboClicked:(id)sender{
    [delegate weiboClicked];
}

@end
