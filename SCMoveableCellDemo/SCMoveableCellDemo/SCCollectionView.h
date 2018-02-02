
#import <UIKit/UIKit.h>

@interface SCCollectionView : UICollectionView

@property (nonatomic, assign) BOOL moving;
@property (nonatomic, strong) NSMutableArray<UICollectionViewCell *> *movingCells;

@end
