//
//  ImageSaverAndLoader.h
//  CloundClassRoomForStudent
//
//  Created by 鹏 吴 on 11/2/11.
//  Copyright (c) 2011 galiumsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageSaverAndLoader : NSObject


//saving an image

+ (void)saveImage:(UIImage*)image:(NSString*)imageName; 
//removing an image

+ (void)removeImage:(NSString*)fileName;
//loading an image

+ (UIImage*)loadImage:(NSString*)imageName;
@end
