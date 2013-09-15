//
//  ImageViewController.m
//  Shutterbug
//
//  Created by Martin Mandl on 02.03.13.
//  Copyright (c) 2013 m2m server software gmbh. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *titleBarButtonItem;
@property (strong, nonatomic) UIPopoverController *urlPopover;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation ImageViewController

- (void)setTitle:(NSString *)title
{
    super.title = title;
    self.titleBarButtonItem.title = title;
}

- (void)setImageURL:(NSURL *)imageURL
{
    _imageURL = imageURL;
    [self resetImage];
}

- (void)resetImage
{
    if (self.scrollView) {
        self.scrollView.contentSize = CGSizeZero;
        self.imageView.image = 0;
        
        [self.spinner startAnimating];
        NSURL *imageURL = self.imageURL;
                    
        dispatch_queue_t imageFetchQ = dispatch_queue_create("image fetcher", NULL);
        dispatch_async(imageFetchQ, ^{
            //[NSThread sleepForTimeInterval:2.0];

            NSData *imageData = [self getImageData:imageURL];
            UIImage *image = [[UIImage alloc] initWithData:imageData];
            
            if (self.imageURL == imageURL) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (image) {
                        self.scrollView.zoomScale = 1.0;
                        self.scrollView.contentSize = image.size;
                        self.imageView.image = image;
                        self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
                    }
                    [self.spinner stopAnimating];
                });
            }
        });
    }
}


-(NSData *)getImageData:(NSURL *)imageURL
{
    
    
    NSData *imageData = [[NSData alloc] init];
    
    if ([self isCache:imageURL]){
        imageData = [NSData dataWithContentsOfURL:[self cacheURL:imageURL]];
        NSLog(@"retrive from cache");
        
    }else{
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES; 
        imageData = [NSData dataWithContentsOfURL:imageURL];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        //cache
        [self cacheImageData:imageData];
        NSLog(@"download from internet && cahce");
        
    }
    
    return imageData;
}

-(BOOL)isCache:(NSURL *)imageURL
{
    NSFileManager *cache = [NSFileManager defaultManager];
    NSArray *urls = [cache URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
    NSURL *cacheDir = [urls lastObject];
    cacheDir = [cacheDir URLByAppendingPathComponent:@"spot"];
    NSString *cacheFileName = [imageURL lastPathComponent];
    NSURL *cacheFileURL = [cacheDir URLByAppendingPathComponent:cacheFileName];
    
    return ([cache fileExistsAtPath:cacheFileURL.path]) ? YES : NO;
}

-(NSURL *)cacheURL:(NSURL *)imageURL
{
    NSFileManager *cache = [NSFileManager defaultManager];
    NSArray *urls = [cache URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
    NSURL *cacheDir = [urls lastObject];
    cacheDir = [cacheDir URLByAppendingPathComponent:@"spot"];
    NSString *cacheFileName = [imageURL lastPathComponent];
    NSURL *cacheFileURL = [cacheDir URLByAppendingPathComponent:cacheFileName];
    
    return cacheFileURL;
}

-(void)cacheImageData:(NSData *)imageData 
{
    NSFileManager *cache = [NSFileManager defaultManager];
    NSArray *urls = [cache URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
    NSURL *cacheDir = [urls lastObject];
    
    // create folder
    cacheDir = [cacheDir URLByAppendingPathComponent:@"spot"];
    if (![cache fileExistsAtPath:cacheDir.path])
        [cache createDirectoryAtPath:cacheDir.path withIntermediateDirectories:YES attributes:Nil error:Nil];
    
    NSString *cacheFileName = [self.imageURL lastPathComponent];
    NSURL *cacheFileURL = [cacheDir URLByAppendingPathComponent:cacheFileName];
    
    [imageData writeToURL:cacheFileURL atomically:YES];
    NSURL *cacheDirURL = [cacheFileURL URLByDeletingLastPathComponent];
    
    //clear cache
    [self clearCache:cacheDirURL];
}

-(void)clearCache:(NSURL *)cacheDirURL
{
    long long maxCacheSize = 10 *1024 *1024;  //10MB
    
    NSLog(@"cacheDirURL %@",cacheDirURL);
    long long curentSize = [self cacheFolderSize:cacheDirURL];
    NSLog(@"curentSize:%lld",curentSize);
    NSLog(@"maxCacheSize:%lld",maxCacheSize);
    while ([self cacheFolderSize:cacheDirURL] > maxCacheSize){
        NSFileManager *filemanager = [NSFileManager defaultManager];
        NSLog(@"%@",cacheDirURL);
        NSArray *files = [filemanager subpathsOfDirectoryAtPath:cacheDirURL.path error:Nil];
        NSURL *oldestFile = nil;
        NSDictionary *oldestFileDic = Nil;
        
        for (NSString *file in files){
            NSDictionary *fileDictionary = [filemanager attributesOfItemAtPath:cacheDirURL.path error:Nil];
            if (oldestFile == Nil) {
                oldestFile = [NSURL URLWithString:file];
                oldestFileDic = fileDictionary;
            }else if ([oldestFileDic valueForKey:NSFileModificationDate] < [fileDictionary valueForKey:NSFileModificationDate]){
                oldestFile = [NSURL URLWithString:file];
            }
        }
        if (oldestFile){
            NSError *error = [[NSError alloc] init];
            NSLog(@"oldestFile %@",oldestFile);
            BOOL flag = [filemanager removeItemAtURL:[cacheDirURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@",oldestFile]] error:&error];
            if (flag)
                NSLog(@"delete cache file: %@",oldestFile.path);
            else
                NSLog(@"error %@",error);
            curentSize = [self cacheFolderSize:cacheDirURL];
            NSLog(@"curentSize:%lld",curentSize);
        }

    }
    
}

-(long long)cacheFolderSize:(NSURL *)cacheDirURL
{
    NSFileManager *filemanager = [[NSFileManager alloc]init];
    NSArray *files = [filemanager subpathsOfDirectoryAtPath:cacheDirURL.path error:Nil];
    long long sizeOfFolder = 0.00;
    for (NSString *file in files) {
        NSDictionary *fileDictionary = [filemanager attributesOfItemAtPath:[cacheDirURL URLByAppendingPathComponent:file].path error:Nil];
        sizeOfFolder += [fileDictionary fileSize];
    }
    NSLog(@"sizeOfFolder %lld",sizeOfFolder);
    return sizeOfFolder;
    
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _imageView;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"Show URL"]) {
        return self.imageURL && !self.urlPopover.popoverVisible ? YES : NO;
    }
    return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.scrollView addSubview:self.imageView];
    self.scrollView.minimumZoomScale = 0.2;
    self.scrollView.maximumZoomScale = 5.0;
    self.scrollView.delegate = self;
    [self resetImage];
    self.titleBarButtonItem.title = self.title;
}

@end
