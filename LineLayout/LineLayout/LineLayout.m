
#import "LineLayout.h"

#define ITEM_SIZE 200.0

@implementation LineLayout

#define ACTIVE_DISTANCE 200
#define ZOOM_FACTOR 0.3

-(id)init
{
    self = [super init];
    if (self) {
        self.itemSize = CGSizeMake(ITEM_SIZE, ITEM_SIZE);
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        //item上下缩进200个Point
        self.sectionInset = UIEdgeInsetsMake(200, 0.0, 200, 0.0);
        //每个item在水平上的最小间距为50个point
        self.minimumLineSpacing = 50.0;
    }
    return self;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds
{
    return YES;
}

-(NSArray*)layoutAttributesForElementsInRect:(CGRect)rect
{
    //取到当前可视屏幕上所有的 item 的布局信息 layoutAttributes
    NSArray* array = [super layoutAttributesForElementsInRect:rect];
    
    CGRect visibleRect;//当前可视屏幕的矩形
    visibleRect.origin = self.collectionView.contentOffset;
    visibleRect.size = self.collectionView.bounds.size;
    
    for (UICollectionViewLayoutAttributes* attributes in array) {
        if (CGRectIntersectsRect(attributes.frame, rect)) {
            //计算当前item的中心点离屏幕中心的距离
            CGFloat distance = CGRectGetMidX(visibleRect) - attributes.center.x;
            //将这个距离标准化
            CGFloat normalizedDistance = distance / ACTIVE_DISTANCE;
            //如果该距离小于一个有效距离（ACTIVE_DISTANCE），那么就进行缩放
            if (ABS(distance) < ACTIVE_DISTANCE) {
                CGFloat zoom = 1 + ZOOM_FACTOR*(1 - ABS(normalizedDistance));
                attributes.transform3D = CATransform3DMakeScale(zoom, zoom, 1.0);
                attributes.zIndex = 1;
            }
        }
    }
    return array;
}


- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    
    //proposedContentOffset 是没有对齐网格时本来应该停下来的位置
    CGFloat offsetAdjustment = MAXFLOAT;
    CGFloat horizontalCenter = proposedContentOffset.x + (CGRectGetWidth(self.collectionView.bounds) / 2.0);
    
    //取到当前的可视屏幕
    CGRect targetRect = CGRectMake(proposedContentOffset.x, 0.0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    
    //取到当前可视屏幕上所有的 item 的布局信息
    NSArray* array = [super layoutAttributesForElementsInRect:targetRect];
    
    ///对当前屏幕中的所有 item 的中心点逐个与屏幕中心进行比较，找出最接近中心的一个
    for (UICollectionViewLayoutAttributes* layoutAttributes in array) {
        //取到某个 item 的中心点位置
        CGFloat itemHorizontalCenter = layoutAttributes.center.x;
        //取得所有 item 中心点与当前屏幕中心点的水平差距最小的值，赋给 offsetAdjustment
        if (ABS(itemHorizontalCenter - horizontalCenter) < ABS(offsetAdjustment)) {
            offsetAdjustment = itemHorizontalCenter - horizontalCenter;
        }
    }
    
    //返回经过调整的ContentOffset值
    return CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y);
}

@end