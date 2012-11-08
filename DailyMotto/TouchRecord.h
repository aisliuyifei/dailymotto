//
//  TouchRecord.h
//  CloundClassRoomForStudent
//
//  Created by wupeng on 7/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TouchRecord : NSObject {
    UITouch* m_id;
    CGPoint m_point;
    CGPoint m_control_point;
    CGPoint m_orignal_point;
    UITouchPhase m_phase;
}

-(id)initWithTouch:(UITouch*)aTouch pointInView:(CGPoint)point;
@property (nonatomic,retain)UITouch * m_id;
@property (nonatomic)CGPoint m_point;
@property (nonatomic)CGPoint m_control_point;
@property (nonatomic)UITouchPhase  m_phase;
@property (nonatomic)CGPoint m_orignal_point;
@end
