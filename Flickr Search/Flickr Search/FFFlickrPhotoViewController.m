//
//  FFFlickrPhotoViewController.m
//  Flickr Search
//
//  Created by Yixiong on 14-4-1.
//  Copyright (c) 2014年 Fang Yixiong. All rights reserved.
//

#import "FFFlickrPhotoViewController.h"
#import "Flickr.h"
#import "FlickrPhoto.h"

@interface FFFlickrPhotoViewController ()
@property (weak) IBOutlet UIImageView *imageView;
- (IBAction)done:(id)sender;
@end

@implementation FFFlickrPhotoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated{
    if (self.flickrPhoto.largeImage) {
        self.imageView.image = self.flickrPhoto.largeImage;
    } else {
        self.imageView.image = self.flickrPhoto.thumbnail;
        [Flickr loadImageForPhoto:self.flickrPhoto thumbnail:NO completionBlock:^(UIImage *photoImage, NSError *error) {
            if (!error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.imageView.image = self.flickrPhoto.largeImage;
                });
            }
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done:(id)sender{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
