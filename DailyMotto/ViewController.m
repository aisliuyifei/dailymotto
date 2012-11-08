//
//  ViewController.m
//  DailyMotto
//
//  Created by 鹏 吴 on 3/20/12.
//  Copyright (c) 2012 galiumsoft. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
@interface ViewController ()

@end

@implementation ViewController

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
    toolView.delegate = self;
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
        [self.view addSubview:toolView.view];

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
        [self.view addSubview:toolView.view];

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



@end
