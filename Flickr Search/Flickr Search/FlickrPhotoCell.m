//
//  FFFlickrPhotoCell.m
//  Flickr Search
//
//  Created by Yixiong on 14-4-1.
//  Copyright (c) 2014年 Fang Yixiong. All rights reserved.
//

#import "FlickrPhotoCell.h"
#import "FlickrPhoto.h"

@implementation FlickrPhotoCell

// 当视图从xib文件或者storyboard 初始化后，initWithCoder 方法被调用。
- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        // 创建一个以蓝色背景，白色边框的视图设置为 cell 选中状态的背景图
        UIView *bgView = [[UIView alloc] initWithFrame:self.backgroundView.frame];
        bgView.backgroundColor = [UIColor blueColor];
        bgView.layer.borderColor = [[UIColor whiteColor] CGColor];
        bgView.layer.borderWidth = 4.0;
        self.selectedBackgroundView = bgView;
    }
    return self;
}

// 更新UI
- (void)setPhoto:(FlickrPhoto *)photo{
    if (_photo != photo) {
        _photo = photo;
    }
    self.imageView.image = _photo.thumbnail;
}

@end
