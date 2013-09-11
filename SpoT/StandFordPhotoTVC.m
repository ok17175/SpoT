//
//  StandFordPhotoTVC.m
//  Shutterbug
//
//  Created by 李深龙 on 13-9-10.
//  Copyright (c) 2013年 m2m server software gmbh. All rights reserved.
//

#import "StandFordPhotoTVC.h"
#import "FlickrFetcher.h"

@interface StandFordPhotoTVC ()

@end

@implementation StandFordPhotoTVC

-(void)setPhotosInplace:(NSArray *)photosInplace
{
    _photosInPlace  = photosInplace;
    [self.tableView reloadData];
}
-(void)viewDidLoad
{
    [super viewDidLoad];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.photosInPlace count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flickr Photo";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    cell.textLabel.text = [self.photosInPlace[indexPath.row] valueForKey:FLICKR_PHOTO_TITLE];
    cell.detailTextLabel.text = [self.photosInPlace[indexPath.row] valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Show Image"]) {
                if ([segue.destinationViewController respondsToSelector:@selector(setImageURL:)]) {
                    
                    NSURL *url = [FlickrFetcher urlForPhoto:self.photosInPlace[indexPath.row]
                                                     format:FlickrPhotoFormatSquare];
                    [segue.destinationViewController performSelector:@selector(setImageURL:)
                                                          withObject:url];
                    [segue.destinationViewController setTitle:[self.photosInPlace[indexPath.row] valueForKey:FLICKR_PHOTO_TITLE]];
                }
            }
        }
    }
}


@end
