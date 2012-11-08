//
//  GetNickName.h
//  每日金句
//
//  Created by 鹏 吴 on 6/26/12.
//  Copyright (c) 2012 galiumsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WBEngine.h"
@interface GetNickName : NSObject<WBEngineDelegate>
{
    NSString *nickName;
}
@property (nonatomic,retain)NSString * nickName;
@end

@protocol NickNameDelegate <NSObject>
    - (void)nickNameGot:(GetNickName *)getNickName;
@end

