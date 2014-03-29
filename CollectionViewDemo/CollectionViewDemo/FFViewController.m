//
//  FFViewController.m
//  CollectionViewDemo
//
//  Created by Yixiong on 14-3-29.
//  Copyright (c) 2014年 Fang Yixiong. All rights reserved.
//

#import "FFViewController.h"
#import "FFPhotoCell.h"
#import "FFDetailViewController.h"

enum PhotoOrientation{
    PhotoOrientationLandscape,
    PhotoOrientationPortrait
};

@interface FFViewController ()
@property (strong,nonatomic) NSArray *photoList;
@property (strong,nonatomic) NSMutableArray *photoOrientation;
@property (strong,nonatomic) NSMutableDictionary *photosCache;
@end

@implementation FFViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    //初始化属性
    self.photoOrientation = [NSMutableArray array];
    self.photoList = nil;
    self.photosCache = [NSMutableDictionary dictionary];
    NSArray * photoArray  = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self photosDirectory] error:nil];
    dispatch_queue_t t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0);
    dispatch_async(t, ^{
        // 遍历图片目录建立
        for (NSString * path in photoArray) {
            NSLog(@"path = %@",path);
            UIImage * image = [UIImage imageWithContentsOfFile:[[self photosDirectory] stringByAppendingPathComponent:path]];
            [self.photoOrientation addObject:image.size.width>image.size.height?@(PhotoOrientationLandscape):@(PhotoOrientationPortrait)];
        }
        self.photoList = photoArray;
        dispatch_queue_t main_t = dispatch_get_main_queue();
        dispatch_async(main_t, ^{
            [self.collectionView reloadData];
        });
    });
}


- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    //清除缓存
    self.photosCache = [NSMutableDictionary dictionary];
}


// 图片目录的路径
- (NSString *)photosDirectory{
    NSString *result = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Photos"];
    return result;
}

// 有几个 section
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}


// 某个section有几个cell
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.photoList count];
}


// 询问cell在被点击时是否应该高亮
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath * )indexPath{
    return YES;
}

// 询问cell是否可以被点击
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

// 返回的 Cell 必须通过调用 -dequeueReusableCellWithReuseIdentifier:forIndexPath
// 这个方法来获取
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifierLandscape = @"FFPhotoCellLandscape";
    static NSString *CellIdentifierPortrait  = @"FFPhotoCellPortrait";
    
    NSInteger orientation = [self.photoOrientation[indexPath.row] integerValue];
    FFPhotoCell *cell = (FFPhotoCell *)[collectionView dequeueReusableCellWithReuseIdentifier:orientation == PhotoOrientationLandscape ? CellIdentifierLandscape : CellIdentifierPortrait forIndexPath:indexPath];
    NSString *photoName = self.photoList[indexPath.row];
    NSString *photoFilePath = [self photoPathWithName:photoName];
    cell.nameLabel.text = [photoName stringByDeletingPathExtension];
    
    __block UIImage * thumbImage = self.photosCache[photoName];
    if (thumbImage) {
        cell.photoView.image = thumbImage;
    }else{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            UIImage * image = [UIImage imageWithContentsOfFile:photoFilePath];
            if (orientation == PhotoOrientationPortrait) {
                //绘图代码，不是很懂，注释掉也没问题。。
                UIGraphicsBeginImageContext(CGSizeMake(120.0f,180.0f));
                [image drawInRect:CGRectMake(0, 0, 120.0f, 180.0f)];
                thumbImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }else{
                //同上...为了节约空间？还是性能？
                UIGraphicsBeginImageContext(CGSizeMake(180.0f,120.0f));
                [image drawInRect:CGRectMake(0, 0, 180.0f, 120.0f)];
                thumbImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            [self.photosCache setObject:thumbImage forKey:photoName];
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.photoView.image = thumbImage;
            });
        });
    }
    
    
    return cell;
}


// cell的点击事件
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"MainSegue" sender:indexPath];
}


// 使用storyboard切换界面时统一的配置方法
- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender{
    NSIndexPath *selectedIndexPath = sender;
    NSString *photoName = self.photoList[selectedIndexPath.row];
    FFDetailViewController *controller = segue.destinationViewController;
    controller.photoPath = [self photoPathWithName:photoName];
}


// 根据图片文件名返回图片完整路径
- (NSString *)photoPathWithName:(NSString *)photoName{
    return [[self photosDirectory] stringByAppendingPathComponent:photoName];
}

@end
