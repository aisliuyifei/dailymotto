//
//  GetNickName.m
//  每日金句
//
//  Created by 鹏 吴 on 6/26/12.
//  Copyright (c) 2012 galiumsoft. All rights reserved.
//

#import "GetNickName.h"

@implementation GetNickName
@synthesize nickName;


+(id) init{
    if (self = [super init]) {
        
    }
    return self;
}


#pragma mark - WBEngineDelegate Methods

- (void)engine:(WBEngine *)engine requestDidSucceedWithResult:(id)result
{
    
}

- (void)engine:(WBEngine *)engine requestDidFailWithError:(NSError *)error
{

}

@end
