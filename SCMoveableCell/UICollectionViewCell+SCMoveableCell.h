
#import <UIKit/UIKit.h>

@protocol SCMoveableCellDelegate <NSObject>

@required

- (void)collectionViewCell:(UICollectionViewCell *)collectionViewCell bringDataSourceFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;

@end

@interface UICollectionViewCell (SCMoveableCell)

@property (nonatomic, weak) id<SCMoveableCellDelegate> sc_moveableCellDelegate;

@end
