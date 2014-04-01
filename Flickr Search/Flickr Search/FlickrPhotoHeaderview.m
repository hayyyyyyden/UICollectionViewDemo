//
//  FlickrPhotoHeaderview.m
//  Flickr Search
//
//  Created by Yixiong on 14-4-1.
//  Copyright (c) 2014年 Fang Yixiong. All rights reserved.
//

#import "FlickrPhotoHeaderview.h"

@interface FlickrPhotoHeaderview ()
@property (weak) IBOutlet UIImageView *backgourndImageView;
@property (weak) IBOutlet UILabel *searchLabel;

@end

@implementation FlickrPhotoHeaderview

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)setSearchText:(NSString *)text{
    self.searchLabel.text = text;
    UIImage *backgroundImage = [[UIImage imageNamed:@"header_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(68, 68, 68, 68)];
    self.backgourndImageView.image = backgroundImage;
}

@end
