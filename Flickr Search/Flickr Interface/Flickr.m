//
//  Flickr.m
//  Flickr Search
//
//  Created by Brandon Trebitowski on 6/28/12.
//  Copyright (c) 2012 Brandon Trebitowski. All rights reserved.
//

#import "Flickr.h"
#import "FlickrPhoto.h"

#define kFlickrAPIKey @"edf707f400d0faaa8748a2cced0f2572"

@implementation Flickr

+ (NSString *)flickrSearchURLForSearchTerm:(NSString *) searchTerm
{
    // 先对搜索词进行编码，相关内容可以参考：http://t.cn/8sMZf9V
    searchTerm = [searchTerm stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&text=%@&per_page=20&format=json&nojsoncallback=1",kFlickrAPIKey,searchTerm];
}

//  取得指定大小的图片URL的方法，详情：https://www.flickr.com/services/api/misc.urls.html
/*  size可以是以下几个值：
s	小正方形 75x75
q	large square 150x150
t	縮圖，最長邊為 100
m	小，最長邊為 240
n	small, 320 on longest side
-	中等，最長邊為 500
z	中等尺寸 640，最長邊為 640
c	中等尺寸 800，最長邊為 800†
b	大尺寸，最長邊為 1024*
o	原始圖片, 根據來源格式可以是 jpg、gif 或 png
 */
+ (NSString *)flickrPhotoURLForFlickrPhoto:(FlickrPhoto *) flickrPhoto size:(NSString *) size
{
    if(!size)
    {
        size = @"m";
    }
    return [NSString stringWithFormat:@"http://farm%d.staticflickr.com/%d/%lld_%@_%@.jpg",flickrPhoto.farm,flickrPhoto.server,flickrPhoto.photoID,flickrPhoto.secret,size];
}

- (void)searchFlickrForTerm:(NSString *) term completionBlock:(FlickrSearchCompletionBlock) completionBlock
{
    
    NSString *searchURL = [Flickr flickrSearchURLForSearchTerm:term];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        NSError *error = nil;
        NSString *searchResultString = [NSString stringWithContentsOfURL:[NSURL URLWithString:searchURL]
                                                           encoding:NSUTF8StringEncoding
                                                              error:&error];
        if (error != nil) {
            // 请求错误，返回相应的错误信息
            completionBlock(term,nil,error);
        }
        else
        {
            // 解析 JSON 格式的返回值
            NSData *jsonData = [searchResultString dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *searchResultsDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                              options:kNilOptions
                                                                                error:&error];
            if(error != nil)
            {
                // 解析出错，返回相应的错误信息
                completionBlock(term,nil,error);
            }
            else
            {
                NSString * status = searchResultsDict[@"stat"];
                if ([status isEqualToString:@"fail"]) {
                    // 服务器返回失败信息，创建并返回相应的错误信息
                    NSError * error = [[NSError alloc] initWithDomain:@"FlickrSearch" code:0 userInfo:@{NSLocalizedFailureReasonErrorKey: searchResultsDict[@"message"]}];
                    completionBlock(term, nil, error);
                } else {
                    // 终于到了正确的地方...
                    NSArray *objPhotos = searchResultsDict[@"photos"][@"photo"];
                    NSMutableArray *flickrPhotos = [@[] mutableCopy];
                    // 遍历建模，这里我认为没有必要用可变字典吧..
                    for(NSMutableDictionary *objPhoto in objPhotos)
                    {
                        FlickrPhoto *photo = [[FlickrPhoto alloc] init];
                        photo.farm = [objPhoto[@"farm"] intValue];
                        photo.server = [objPhoto[@"server"] intValue];
                        photo.secret = objPhoto[@"secret"];
                        photo.photoID = [objPhoto[@"id"] longLongValue];
                        
                        NSString *searchURL = [Flickr flickrPhotoURLForFlickrPhoto:photo size:@"m"];
                        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:searchURL]
                                                                  options:0
                                                                    error:&error];
                        UIImage *image = [UIImage imageWithData:imageData];
                        photo.thumbnail = image;
                        
                        [flickrPhotos addObject:photo];
                    }
                    // 调用返回 Block，正确返回
                    completionBlock(term,flickrPhotos,nil);
                }
            }
        }
    });
}


// 载入单个图片的方法
+ (void)loadImageForPhoto:(FlickrPhoto *)flickrPhoto thumbnail:(BOOL)thumbnail completionBlock:(FlickrPhotoCompletionBlock) completionBlock
{
    
    NSString *size = thumbnail ? @"m" : @"b";
    
    NSString *searchURL = [Flickr flickrPhotoURLForFlickrPhoto:flickrPhoto size:size];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        NSError *error = nil;
        
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:searchURL]
                                                  options:0
                                                    error:&error];
        if(error)
        {
            completionBlock(nil,error);
        }
        else
        {
            UIImage *image = [UIImage imageWithData:imageData];
            if([size isEqualToString:@"m"])
            {
                flickrPhoto.thumbnail = image;
            }
            else
            {
                flickrPhoto.largeImage = image;
            }
            completionBlock(image,nil);
        }
        
    });
}



@end
