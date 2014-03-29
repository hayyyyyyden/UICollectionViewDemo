//
//  FFPhotoCell.m
//  CollectionViewDemo
//
//  Created by Yixiong on 14-3-29.
//  Copyright (c) 2014年 Fang Yixiong. All rights reserved.
//

#import "FFPhotoCell.h"

@implementation FFPhotoCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib{
    //增加选中后的背景图
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    self.selectedBackgroundView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.5];
    //四周增加留白
    self.photoView.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.photoView.layer.borderWidth = 5.0f;
    [super awakeFromNib];
}

@end
