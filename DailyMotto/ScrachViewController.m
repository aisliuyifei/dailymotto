//
//  ScrachViewController.m
//  CloundClassRoomForStudent
//
//  Created by wupeng on 6/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ScrachViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ImageSaverAndLoader.h"
@implementation ScrachViewController
CGPoint moveButtonTouchPoint;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        mouseMoved = 0;
        eraserBlured=NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    m_arrayTouch=[[NSMutableArray alloc]init];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    spotTouches=[m_arrayTouch count]+[touches count];
    leftTopTouch =[touches anyObject];
    
    lastPoint = [leftTopTouch locationInView:drawImage];
    TouchRecord * record=[[TouchRecord alloc]initWithTouch:leftTopTouch pointInView:lastPoint];
    [m_arrayTouch addObject:record];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {

    double x=0.0f,last_x=1024.0f,control_x=0.0f;
    double y=0.0f,last_y=1024.0f,control_y=0.0f;

    UITouch *topMovedTouch=[touches anyObject];
    CGPoint topedPoint=[topMovedTouch locationInView:drawImage];
    
    for (TouchRecord *record in m_arrayTouch) {
        if(record.m_id==topMovedTouch)
        {
//          topMovedTouchRecord=record;
            last_x=record.m_control_point.x;
            last_y=record.m_control_point.y;//起点为上一次控制点（控制点非标准贝塞尔曲线的控制点，该控制点在曲线上）
            control_x=record.m_point.x;
            control_y=record.m_point.y;//控制点为上次终点
            record.m_control_point=record.m_point;//纪录本次控制点
            record.m_point=topedPoint;
            record.m_phase=topMovedTouch.phase;//纪录本次终点
            x=record.m_point.x;
            y=record.m_point.y;
        }
    }
    UIGraphicsBeginImageContext(drawImage.frame.size);
    [drawImage.image drawInRect:CGRectMake(0, 0, drawImage.frame.size.width, drawImage.frame.size.height)];
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 4.0);

    CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), [[UIColor clearColor] CGColor]);
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), [[UIColor clearColor] CGColor]);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeClear);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 35.0);
    CGContextClosePath(UIGraphicsGetCurrentContext());
    CGContextDrawPath(UIGraphicsGetCurrentContext(), kCGPathFillStroke);


    double a1=last_x;
    double b1=last_y;
    double a2=x;
    double b2=y;
    double a3=control_x;
    double b3=control_y;
    
    double x0;double y0;//垂足
    if(a1==a2){
        x0=a1;
        y0=b3;
    }else if (b1==b2){
        x0=a3;
        y0=b1;
    }
    else
    {
        double k=(b2-b1)/(a2-a1);// 切线斜率
        double t=-1.0/k;    //法线斜率
        x0=(b3-b1+a1*k-a3*t)/(k-t);
        y0=k*(x0-a1)+b1;
    }
    
    double cx1,cy1/*,cx2,cy2*/;//两个真正意义的控制点
    
    cx1=(a3+a1+a3-x0)/2;
    cy1=(b3+b1+b3-y0)/2;
    
    CGContextBeginPath(UIGraphicsGetCurrentContext());
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), last_x,last_y);
    CGContextAddQuadCurveToPoint(UIGraphicsGetCurrentContext(), cx1, cy1, control_x, control_y);

    CGContextStrokePath(UIGraphicsGetCurrentContext());
    drawImage.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self performSelector:@selector(saveScratchPaperInBackground)];
    for (UITouch * touch in touches) {
        for (TouchRecord * record in m_arrayTouch) {
            if (touch==record.m_id) {
                [m_arrayTouch removeObject:record];
                break;
            }
        }
    }
}


-(void)saveScratchPaperInBackground{
    [self saveScratchPaperWithPath:@"scratch_it"];
}

-(void)saveScratchPaperWithPath:(NSString *)path{
    [ImageSaverAndLoader saveImage:[drawImage image] :path];
}

-(void)loadScratchPaperWithPath:(NSString *)path{
    drawImage.image=[ImageSaverAndLoader loadImage:path];
}

-(void)setImageNamed:(NSString *)imageName{
    drawImage.image =[UIImage imageNamed:imageName];
    [self performSelector:@selector(saveScratchPaperInBackground)];
}

-(void)loadScratchPaperWithUrl:(NSString *)url{
    NSURL* aURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",url]];
//    NSLog(@"URLForImage:%@",aURL);
    NSData* data = [[NSData alloc] initWithContentsOfURL:aURL];
    [drawImage setImage:[UIImage imageWithData:data]];
}

@end
