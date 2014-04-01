//
//  FFViewController.m
//  Flickr Search
//
//  Created by Yixiong on 14-3-31.
//  Copyright (c) 2014年 Fang Yixiong. All rights reserved.
//

#import "FFViewController.h"
#import "Flickr.h"
#import "FlickrPhoto.h"
#import "FlickrPhotoCell.h"
#import "FlickrPhotoHeaderview.h"
#import "FFFlickrPhotoViewController.h"
#import <MessageUI/MessageUI.h>

@interface FFViewController ()<UITextFieldDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,MFMailComposeViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *shareButton;
@property (nonatomic, weak) IBOutlet UITextField *textField;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *searches;
@property (nonatomic, strong) NSMutableArray *selectedPhotos;
@property (nonatomic, strong) NSMutableDictionary *searchResults;
@property (nonatomic, strong) Flickr *flickr;
@property (nonatomic)         BOOL  sharing;

- (IBAction)shareButtonTapped:(id)sender;

@end

@implementation FFViewController

- (IBAction)shareButtonTapped:(id)sender{
    if (!self.sharing) {
        // 如果用户当前不在分享模式下，这段代码将 UICollectionView 设置为允许多选并将 Share 按钮标题修改为 Done
        self.sharing = YES;
        self.shareButton.style = UIBarButtonItemStyleDone;
        self.shareButton.title = @"Done";
        self.collectionView.allowsMultipleSelection = YES;
    } else {
        // 这时用户已经在分享模式下，并且点击了 Done 按钮。因此将按钮标题修改回 Share 并禁止 CollectionView 多选
        self.sharing = NO;
        self.shareButton.style = UIBarButtonItemStyleBordered;
        self.shareButton.title = @"Share";
        self.collectionView.allowsMultipleSelection = NO;
    }
    
    if ([self.selectedPhotos count] > 0) {
        // 检查用户是否选择了图片，如果有，则调用 showMailComposerAndSend 方法
        [self showMailComposerAndSend];
    }
    
    // 取消全部选中的 cell，并将他们从 selectedPhotos 数组中移除
    for (NSIndexPath *indexPath in self.collectionView.indexPathsForSelectedItems) {
        [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
    }
    [self.selectedPhotos removeAllObjects];
}

- (void)showMailComposerAndSend{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController * mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        // 设置邮件的标题
        [mailer setSubject:@"快来看看这几张 Flickr 的照片！"];
        // 设置邮件的内容
        NSMutableString *emailBody = [NSMutableString string];
        for (FlickrPhoto *flickrPhoto in self.selectedPhotos) {
            NSString *url = [Flickr flickrPhotoURLForFlickrPhoto:flickrPhoto size:@"m"];
            [emailBody appendFormat:@"<div><img src='%@'></div><br>",url];
        }
        [mailer setMessageBody:emailBody isHTML:YES];
        // 调用邮件
        [self presentViewController:mailer animated:YES completion:nil];
    } else {
        // 无法发送邮件的错误提示
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"发送邮件失败" message:@"您的设备不支持在应用内发送邮件！" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
        [alert show];
    }
}

// 用户点击［发送邮件］或者［取消］的回调方法
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // 设置背景颜色
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_cork.png"]];
    
    // 设置顶部工具栏的背景颜色
    UIImage *navBarImage = [[UIImage imageNamed:@"navbar.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(27, 27, 27, 27)];
    [self.toolbar setBackgroundImage:navBarImage forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
    // 设置分享按钮的图片
    UIImage *shareButtonImage = [[UIImage imageNamed:@"button.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    [self.shareButton setBackgroundImage:shareButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    // 设置文本输入框的背景图片
    UIImage *textFieldImage = [[UIImage imageNamed:@"search_field"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    self.textField.background = textFieldImage;
    
    // 初始化
    self.searches = [@[] mutableCopy];
    self.selectedPhotos = [@[] mutableCopy];
    self.searchResults = [@{} mutableCopy];
    self.flickr = [[Flickr alloc] init];
    
    // 注册重用的 Cell
//    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"FlickrCell"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    // 使用 Flickr 封装类来对搜索关键词进行异步搜索。当搜索完成后，completion block 会被调用，该block 中含有搜索关键词，一个FlickrPhoto的数组，和错误信息（如果发生错误的话）
    [self.flickr searchFlickrForTerm:textField.text completionBlock:^(NSString *searchTerm, NSArray *results, NSError *error) {
        // 判断是否有结果，如果有结果：
        if (results && [results count] >0) {
            // 判断关键词是否重复，如果没重复：
            if (![self.searches containsObject:searchTerm]) {
                NSLog(@"搜索关键词 %@ 共找到 %d 张图片。",searchTerm,[results count]);
                // 更新本地的数据 Model
                [self.searches insertObject:searchTerm atIndex:0];
                self.searchResults[searchTerm] = results;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                //更新CollectionView
                [self.collectionView reloadData];
            });
        } else {
            // 没有找到照片的错误信息输出
            NSLog(@"Error searching Flickr: %@",error.localizedDescription);
        }
    }];
    return YES;
}

# pragma mark - UICollectionView Datasource

// 返回有多少个 section
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSString *searchTerm = self.searches[section];
    return [self.searchResults[searchTerm] count];
}

// 返回每个 section 有几个 cell
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return [self.searches count];
}

// 返回某个 cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    FlickrPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FlickrCell" forIndexPath:indexPath];
    NSString *searchTerm = self.searches[indexPath.section];
    cell.photo = self.searchResults[searchTerm][indexPath.row];
    return cell;
}

// 点击选中某个 cell 的响应事件
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *searchTerm = self.searches[indexPath.section];
    FlickrPhoto *photo = self.searchResults[searchTerm][indexPath.row];
    if (!self.sharing) {
        [self performSegueWithIdentifier:@"ShowFlickrPhoto" sender:photo];
        [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
    }else{
        // 分享模式中，将选中的照片加入到数组中
        [self.selectedPhotos addObject:photo];
    }
}

// 撤销选中某个 cell 的响应事件
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.sharing) {
        // 允许用户取消误选的照片
        NSString *searchTerm = self.searches[indexPath.section];
        FlickrPhoto *photo = self.searchResults[searchTerm][indexPath.row];
        [self.selectedPhotos removeObject:photo];
    }
}

// 返回某个辅助视图（例如，header、footer）
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath{
    FlickrPhotoHeaderview *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"FlickrPhotoHeaderView" forIndexPath:indexPath];
    NSString *searchTerm = self.searches[indexPath.section];
    [headerView setSearchText:searchTerm];
    return headerView;
}

#pragma mark - UICollecionViewDelegateFlowLayout


// 询问每个 cell 的大小，如果不实现，则。。。
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *searchTerm = self.searches[indexPath.section];
    FlickrPhoto *photo = self.searchResults[searchTerm][indexPath.row];
    
    // 图片未加载时显示为 100x100 的空白图片，外加 35 pt的留白
    CGSize retval = photo.thumbnail.size.width >0 ? photo.thumbnail.size : CGSizeMake(100,100);
    retval.height += 35;
    retval.width  += 35;
    
    return retval;
}

// 询问 cell 与 footer 和 header 视图之间的间距
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(50, 20, 50, 20);
}


#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"ShowFlickrPhoto"]) {
        FFFlickrPhotoViewController *flickrPhotoViewController = segue.destinationViewController;
        flickrPhotoViewController.flickrPhoto = sender;
    }
}

@end
