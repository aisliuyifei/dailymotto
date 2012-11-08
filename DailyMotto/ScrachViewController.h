//
//  ScrachViewController.h
//  CloundClassRoomForStudent
//
//  Created by wupeng on 6/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
//#import "RulerView.h"
#import "TouchRecord.h"
#import "math.h"

#define PENCILE_SIZE 40
@protocol ScrachDelegate;

@interface ScrachViewController:UIViewController{
    CGPoint lastPoint;
	IBOutlet UIImageView *drawImage;
	Boolean mouseSwiped;	
	int mouseMoved;
    UIImageView *eraserImage;
    Boolean eraserBlured;
    Boolean moveButtonBlured;
    int spotTouches;
    NSMutableArray *m_arrayTouch;
    UITouch *leftTopTouch;
}


-(void)saveScratchPaperWithPath:(NSString *)path;
-(void)loadScratchPaperWithPath:(NSString *)path;
-(void)loadScratchPaperWithUrl:(NSString *)url;
-(void)setImageNamed:(NSString *)imageName;

@end
