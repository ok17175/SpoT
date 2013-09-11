//
//  StandFordPlaceTVC.m
//  SpoT
//
//  Created by 李深龙 on 13-9-10.
//  Copyright (c) 2013年 李深龙. All rights reserved.
//

#import "StandFordPlaceTVC.h"
#import "FlickrFetcher.h"

@interface StandFordPlaceTVC ()


@end

@implementation StandFordPlaceTVC

-(void)loadStandFordPhotoFromFlickr
{
    [self.refreshControl beginRefreshing];
    dispatch_queue_t loaderQ = dispatch_queue_create("loader", NULL);
    dispatch_async(loaderQ, ^{
        NSArray *standPhoto = [FlickrFetcher stanfordPhotos];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.photos = standPhoto;
            [self.refreshControl endRefreshing];
        });
    });
}

-(void)setPhotos:(NSArray *)photos
{
    _photos = photos;
    [self updateTable];
    [self.tableView reloadData];
}

-(void)updateTable
{
    NSMutableDictionary *tagsLists = [[NSMutableDictionary alloc] init];
    NSMutableArray *photoId = [[NSMutableArray alloc] init];
    for (NSDictionary *photo in self.photos){
        NSArray *tags = [[photo valueForKey:FLICKR_TAGS] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        for (NSString *tag in tags){
            if ([tag isEqualToString:@"cs193pspot"]) continue;
            if ([tag isEqualToString:@"portrait"]) continue;
            if ([tag isEqualToString:@"landscape"]) continue;
            
            photoId = [tagsLists valueForKey:tag];
            
            if (![tagsLists valueForKey:tag]) {
                photoId = [NSMutableArray array];
            }
            [photoId addObject:photo];
            [tagsLists setValue:photoId forKey:tag];
        }
    }
    
    self.tags = tagsLists;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self loadStandFordPhotoFromFlickr];
    [self updateTable];
    self.title = @"SPoT";
    [self.refreshControl addTarget:self
                            action:@selector(loadStandFordPhotoFromFlickr)
                  forControlEvents:UIControlEventValueChanged];
}



#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Show Photos"]) {
                if ([segue.destinationViewController respondsToSelector:@selector(setPhotosInplace:)]) {
                    
                    NSString *tag = [self.tags allKeys][indexPath.row];
                    [segue.destinationViewController performSelector:@selector(setPhotosInplace:)
                                                          withObject:[self.tags valueForKey:tag]];
                    [segue.destinationViewController setTitle:tag];
                }
            }
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tags count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"StandFord";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSString *tag = [self.tags allKeys][indexPath.row];
    
    cell.textLabel.text = tag;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d photo%@",[self.tags[tag] count],[self.tags[tag] count]>1 ? @"s":@""];
    
    return cell;
}

@end
