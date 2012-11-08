//
//  TouchRecord.m
//  CloundClassRoomForStudent
//
//  Created by wupeng on 7/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TouchRecord.h"


@implementation TouchRecord
@synthesize m_id;
@synthesize m_phase;
@synthesize m_point;
@synthesize m_orignal_point;
@synthesize m_control_point;
//@synthesize flag_point_control;
-(id)init{
    return [self initWithTouch:nil pointInView:CGPointMake(0, 0)];
}

-(id)initWithTouch:(UITouch*)aTouch pointInView:(CGPoint)point{
    self=[super init];
    if (self) {
        m_id=aTouch;
        m_phase=[aTouch phase];
        m_orignal_point=point;
        m_point=point;
        m_control_point=point;
    }
    return self;
}


@end
