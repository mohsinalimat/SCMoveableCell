
#import "SCCollectionViewController.h"
#import "SCCollectionView.h"
#import "SCCollectionViewCell.h"

@interface SCItem : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *image;

@end
@implementation SCItem
@end

@interface SCCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate, SCMoveableCellDelegate>

@property (nonatomic, strong) SCCollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray<SCItem *> *dataSource;

@end

@implementation SCCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Photos";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.collectionView];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"reset" style:UIBarButtonItemStylePlain target:self action:@selector(resetData)];
    
    [self resetData];
}

#pragma mark - UICollectionViewDataSource & UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SCItem *item = self.dataSource[indexPath.item];
    SCCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.sc_moveableCellDelegate = self;
    cell.titleLabel.text = item.title;
    cell.imageView.image = item.image;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.collectionView.moving) return;
    
    UICollectionViewCell *currentCell = [self.collectionView cellForItemAtIndexPath:indexPath];
    if (currentCell.hidden) return;
    currentCell.hidden = YES;
    [self.collectionView.movingCells addObject:currentCell];
    
    UICollectionViewCell *movingCell = self.collectionView.movingCells.firstObject;
    NSIndexPath *movingIndexPath = [collectionView indexPathForCell:movingCell];
    
    SCItem *currentItem = self.dataSource[indexPath.item];
    if (indexPath.item < movingIndexPath.item) {
        [self.dataSource removeObjectAtIndex:indexPath.item];
        [self.dataSource insertObject:currentItem atIndex:movingIndexPath.item];
        [collectionView moveItemAtIndexPath:indexPath toIndexPath:movingIndexPath];
    } else {
        [self.dataSource removeObjectAtIndex:indexPath.item];
        [self.dataSource insertObject:currentItem atIndex:movingIndexPath.item + 1];
        [collectionView moveItemAtIndexPath:indexPath toIndexPath:[NSIndexPath indexPathForItem:movingIndexPath.item+ 1 inSection:0]];
    }
}

#pragma mark - SCMoveableCellDelegate

- (void)collectionViewCell:(UICollectionViewCell *)collectionViewCell bringDataSourceFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    if (fromIndexPath.item == toIndexPath.item) return;
    
    SCItem *item = self.dataSource[fromIndexPath.item];
    [self.dataSource removeObjectAtIndex:fromIndexPath.item];
    [self.dataSource insertObject:item atIndex:toIndexPath.item];
}

#pragma mark - Event Response

- (void)resetData
{
    [self.dataSource removeAllObjects];
    for (int i = 0; i < 20; i++) {
        SCItem *item = [SCItem new];
        NSString *imageName = [NSString stringWithFormat:@"%ld", (long)i];
        item.title = imageName;
        item.image = [UIImage imageNamed:imageName];
        [self.dataSource addObject:item];
    }
    
    [self.collectionView reloadData];
}

#pragma mark - Getter and Setter

- (SCCollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
        flowLayout.itemSize = CGSizeMake(85, 85);
        flowLayout.minimumLineSpacing = 15;
        flowLayout.minimumInteritemSpacing = 15;
        flowLayout.sectionInset = UIEdgeInsetsMake(15, 15, 15, 15);
        
        _collectionView = [[SCCollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:[SCCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    }
    return _collectionView;
}

- (NSMutableArray<SCItem *> *)dataSource
{
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

@end
