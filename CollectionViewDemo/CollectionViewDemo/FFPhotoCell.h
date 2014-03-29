//
//  FFPhotoCell.h
//  CollectionViewDemo
//
//  Created by Yixiong on 14-3-29.
//  Copyright (c) 2014年 Fang Yixiong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FFPhotoCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@end
