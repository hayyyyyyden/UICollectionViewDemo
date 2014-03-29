//
//  FFDetailViewController.m
//  CollectionViewDemo
//
//  Created by Yixiong on 14-3-29.
//  Copyright (c) 2014年 Fang Yixiong. All rights reserved.
//

#import "FFDetailViewController.h"

@interface FFDetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@end

@implementation FFDetailViewController


// 完成按钮的点击事件
- (IBAction)doneTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.textLabel.text = [[self.photoPath lastPathComponent] stringByDeletingPathExtension];
    //这里为什么要用低优先级的线程？
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        UIImage *image = [UIImage imageWithContentsOfFile:self.photoPath];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = image;
        });
    });
}

@end
