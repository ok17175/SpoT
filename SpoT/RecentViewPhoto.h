//
//  RecentViewPhoto.h
//  SpoT
//
//  Created by 李深龙 on 13-9-12.
//  Copyright (c) 2013年 李深龙. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecentViewPhoto : NSObject

+(void)addPhoto:(NSDictionary *)photo;
+(NSArray *)getPhotos;

@end
