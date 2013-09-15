//
//  RecentViewPhotoTVC.m
//  SpoT
//
//  Created by 李深龙 on 13-9-12.
//  Copyright (c) 2013年 李深龙. All rights reserved.
//

#import "RecentViewPhotoTVC.h"
#import "RecentViewPhoto.h"

@interface RecentViewPhotoTVC ()

@end

@implementation RecentViewPhotoTVC

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.photosInPlace = [RecentViewPhoto getPhotos];
    self.title = @"Recent";
}

@end
