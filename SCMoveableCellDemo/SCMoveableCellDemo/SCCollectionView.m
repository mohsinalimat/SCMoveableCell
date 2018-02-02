
#import "SCCollectionView.h"

@implementation SCCollectionView

- (NSMutableArray<UICollectionViewCell *> *)movingCells
{
    if (!_movingCells) {
        _movingCells = [NSMutableArray array];
    }
    return _movingCells;
}

- (void)dealloc
{
    
}

@end
