//
//  RecentViewPhoto.m
//  SpoT
//
//  Created by 李深龙 on 13-9-12.
//  Copyright (c) 2013年 李深龙. All rights reserved.
//

#import "RecentViewPhoto.h"

@implementation RecentViewPhoto

#define RECENT_VIEW_PHOTO_NUMBERS 20


+(NSArray *)getPhotos
{
    NSString *key = @"RECENT_VIEW_PHOTOS";
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

+(void)addPhoto:(NSDictionary *)photo
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *key = @"RECENT_VIEW_PHOTOS";
    NSMutableArray *recent = [[defaults objectForKey:key] mutableCopy];
    if (!recent) recent = [NSMutableArray array];
    [recent insertObject:photo atIndex:0];
    if ([recent count] > RECENT_VIEW_PHOTO_NUMBERS) [recent removeLastObject];
    
    [defaults setObject:recent forKey:key];
    [defaults synchronize];
}
@end
