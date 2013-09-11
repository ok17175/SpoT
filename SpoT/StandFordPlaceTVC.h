//
//  StandFordPlaceTVC.h
//  SpoT
//
//  Created by 李深龙 on 13-9-10.
//  Copyright (c) 2013年 李深龙. All rights reserved.
//

#import "FlickrPhotoTVC.h"

@interface StandFordPlaceTVC : UITableViewController<UITableViewDelegate>

@property(nonatomic,strong) NSArray *photos;
@property(nonatomic,strong) NSDictionary *tags; // of array
@end
