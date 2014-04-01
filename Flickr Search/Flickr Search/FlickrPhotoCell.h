//
//  FlickrPhotoCell.h
//  Flickr Search
//
//  Created by Yixiong on 14-4-1.
//  Copyright (c) 2014年 Fang Yixiong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FlickrPhoto;

@interface FlickrPhotoCell : UICollectionViewCell
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) FlickrPhoto *photo;


@end
