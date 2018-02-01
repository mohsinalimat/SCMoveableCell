
#import <UIKit/UIKit.h>

@interface SCMoveableCellConfiguration : NSObject

@property (nonatomic, assign) CGFloat alphaOfMovingCell;
@property (nonatomic, assign) CGFloat scaleOfMovingCell;
@property (nonatomic, assign) NSTimeInterval animationDuration;

+ (instancetype)configuration;

@end

@protocol SCMoveableCellDelegate <NSObject>

@required

- (void)collectionViewCell:(UICollectionViewCell *)collectionViewCell bringDataSourceFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;

@end

@interface UICollectionViewCell (SCMoveableCell)

@property (nonatomic, weak) id<SCMoveableCellDelegate> sc_moveableCellDelegate;
@property (nonatomic, strong) SCMoveableCellConfiguration *sc_moveableCellConfiguration;

@end
