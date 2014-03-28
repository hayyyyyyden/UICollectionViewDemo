
#import "CircleLayout.h"

#define ITEM_SIZE 70

@interface CircleLayout()

// arrays to keep track of insert, delete index paths
// 用来保存插入和删除的cell的indexPath值的数组
@property (nonatomic, strong) NSMutableArray *deleteIndexPaths;
@property (nonatomic, strong) NSMutableArray *insertIndexPaths;

@end

@implementation CircleLayout

-(void)prepareLayout
{
    //和init相似，必须call super 的 prepareLayout 以保证初始化正确
    [super prepareLayout];
    
    CGSize size = self.collectionView.frame.size;
    _cellCount = [[self collectionView] numberOfItemsInSection:0];
    _center = CGPointMake(size.width / 2.0, size.height / 2.0);
    _radius = MIN(size.width, size.height) / 2.5;
    
    //其实对于一个size不变的collectionView来说，除了_cellCount之外的中心和半径的定义也可以扔到init里去做，但是显然在prepareLayout里做的话具有更大的灵活性。因为每次重新给出layout时都会调用prepareLayout，这样在以后如果有collectionView大小变化的需求时也可以自动适应变化。
}



//整个collectionView的内容大小就是collectionView的大小（没有滚动）

-(CGSize)collectionViewContentSize
{
    return [self collectionView].frame.size;
}


- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)path
{
    //生成空白的布局属性对象，其中只记录了类型是cell以及对应的位置是indexPath
    UICollectionViewLayoutAttributes* attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:path];
    
    //配置布局属性中的大小和位置信息，使item被放到圆周上
    //需要一点点的初中几何知识，希望这些知识还没还给老师＝＝
    attributes.size = CGSizeMake(ITEM_SIZE, ITEM_SIZE);
    attributes.center = CGPointMake(_center.x + _radius * cosf(2 * path.item * M_PI / _cellCount),
                                    _center.y + _radius * sinf(2 * path.item * M_PI / _cellCount));
    return attributes;
}

//用来在一开始给出一个布局属性（layoutAttributes）的数组
-(NSArray*)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray* attributes = [NSMutableArray array];
    for (NSInteger i=0 ; i < self.cellCount; i++) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        //这里利用了-layoutAttributesForItemAtIndexPath:来获取attributes
        [attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
    }
    return attributes;
}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems
{
    // 持续更新要插入和删除的cell的indexpath的数组
    //
    [super prepareForCollectionViewUpdates:updateItems];
    
    self.deleteIndexPaths = [NSMutableArray array];
    self.insertIndexPaths = [NSMutableArray array];
    
    for (UICollectionViewUpdateItem *update in updateItems)
    {
        if (update.updateAction == UICollectionUpdateActionDelete)
        {
            [self.deleteIndexPaths addObject:update.indexPathBeforeUpdate];
        }
        else if (update.updateAction == UICollectionUpdateActionInsert)
        {
            [self.insertIndexPaths addObject:update.indexPathAfterUpdate];
        }
    }
}

- (void)finalizeCollectionViewUpdates
{
    [super finalizeCollectionViewUpdates];
    // release the insert and delete index paths
    self.deleteIndexPaths = nil;
    self.insertIndexPaths = nil;
}

// 注意: 方法名变更了
// 不仅是插入的cell，所有可见的 cell 都会调用这个方法！删除 cell 时也会调用这个方法！
- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    // 必须调用父类的方法
    UICollectionViewLayoutAttributes *attributes = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
    
    // 判断是否为要插入的 cell，因为我们只改变要插入的 cell 的布局属性
    if ([self.insertIndexPaths containsObject:itemIndexPath])
    {
        if (!attributes)
            attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
        
        // 配置布局属性：cell 的位置在圆心，全透明
        attributes.alpha = 0.0;
        attributes.center = CGPointMake(_center.x, _center.y);
    }
    
    return attributes;
}

// 注意: 方法名变更了
// 不仅是删除的cell，所有可见的 cell 都会调用这个方法！甚至插入 cell 时也会调用这个方法！
- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    // 到目前为止，这里并不一定要调用父类的方法，但还是调用一下以防万一
    UICollectionViewLayoutAttributes *attributes = [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath];

    // 判断是否为要删除的 cell，因为我们只改变要删除的 cell 的布局属性
    if ([self.deleteIndexPaths containsObject:itemIndexPath])
    {
        if (!attributes)
            attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
        
        // cell 的位置在圆心，全透明，且只有原来的 1/10 大
        attributes.alpha = 0.0;
        attributes.center = CGPointMake(_center.x, _center.y);
        attributes.transform3D = CATransform3DMakeScale(0.1, 0.1, 1.0);
    }
    
    return attributes;
}


@end
