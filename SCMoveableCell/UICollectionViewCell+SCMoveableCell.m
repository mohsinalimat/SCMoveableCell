
#import "UICollectionViewCell+SCMoveableCell.h"
#import <objc/runtime.h>

@interface SCIndexPathAndFrame : NSObject

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, assign) CGRect frame;

@end
@implementation SCIndexPathAndFrame
@end

@interface SCMoveableCellInfo : NSObject

@property (nonatomic, assign) CGPoint beganPoint;
@property (nonatomic, assign) CGRect beganFrame;
@property (nonatomic, assign) CGRect endFrame;
@property (nonatomic, copy) NSArray *frameOfVisibleCells;

@end
@implementation SCMoveableCellInfo
@end

@interface SCMoveableCellWeakProxy : NSObject

@property (nonatomic, weak) id target;

@end
@implementation SCMoveableCellWeakProxy
@end

@interface UICollectionViewCell ()

@property (nonatomic, weak) UICollectionView *sc_collectionView;
@property (nonatomic, weak) UIImageView *sc_fakeImageView;

@property (nonatomic, strong) UILongPressGestureRecognizer *sc_longPressGestureRecognizer;
@property (nonatomic, strong) SCMoveableCellInfo *sc_info;

@end

@implementation UICollectionViewCell (SCMoveableCell)

#pragma mark - Event Response

- (void)sc_onActionLongPress:(UILongPressGestureRecognizer *)longPressGestureRecognizer
{
    UIWindow *window = UIApplication.sharedApplication.delegate.window;
    CGPoint currentPoint = [longPressGestureRecognizer locationInView:window];
    
    switch (longPressGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            UIGraphicsBeginImageContext(self.bounds.size);
            CGContextRef contextRef = UIGraphicsGetCurrentContext();
            [self.layer renderInContext:contextRef];
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            imageView.frame = [self.superview convertRect:self.frame toView:window];
            [window addSubview:imageView];
            self.sc_fakeImageView = imageView;
            self.hidden = YES;
            
            SCMoveableCellInfo *info = [SCMoveableCellInfo new];
            
            CGRect frame = imageView.frame;
            frame.origin.x -= frame.size.width * 0.1 / 2;
            frame.origin.y -= frame.size.height * 0.1 / 2;
            frame.size.width = frame.size.width * 1.1;
            frame.size.height = frame.size.height * 1.1;
            info.beganPoint = currentPoint;
            info.beganFrame = frame;
            info.endFrame = frame;
            
            [UIView animateWithDuration:0.05 animations:^{
                imageView.alpha = 0.9;
                imageView.frame = frame;
            }];
            
            NSArray<NSIndexPath *> *sortedVisibleIndexPaths = [self.sc_collectionView.indexPathsForVisibleItems sortedArrayUsingComparator:^NSComparisonResult(NSIndexPath  *preIndexPath, NSIndexPath  *nextIndexPath) {
                if (preIndexPath.item < nextIndexPath.item) {
                    return NSOrderedAscending;
                } else {
                    return NSOrderedDescending;
                }
            }];
            
            NSMutableArray *frameOfVisibleCells = [NSMutableArray array];
            for (NSIndexPath *indexPath in sortedVisibleIndexPaths) {
                UICollectionViewCell *cell = [self.sc_collectionView cellForItemAtIndexPath:indexPath];
                CGRect frame = [cell.superview convertRect:cell.frame toView:window];
                SCIndexPathAndFrame *indexPathAndFrame = [SCIndexPathAndFrame new];
                indexPathAndFrame.indexPath = indexPath;
                indexPathAndFrame.frame = frame;
                [frameOfVisibleCells addObject:indexPathAndFrame];
            }
            info.frameOfVisibleCells = frameOfVisibleCells.copy;
            self.sc_info = info;
        }
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            self.sc_info.endFrame = [self.superview convertRect:self.frame toView:window];
            
            SCMoveableCellInfo *info = self.sc_info;
            CGRect imageViewFrame = info.beganFrame;
            imageViewFrame.origin.x += currentPoint.x - info.beganPoint.x;
            imageViewFrame.origin.y += currentPoint.y - info.beganPoint.y;
            self.sc_fakeImageView.frame = imageViewFrame;
            
            if (!self.sc_moveableCellDelegate || ![self.sc_moveableCellDelegate respondsToSelector:@selector(collectionViewCell:bringDataSourceFromIndexPath:toIndexPath:)]) return;
            
            UICollectionViewCell *findCell;
            NSIndexPath *findIndexPath;
            for (SCIndexPathAndFrame *indexPathAndFrame in info.frameOfVisibleCells) {
                CGRect frame = indexPathAndFrame.frame;
                if (CGRectContainsPoint(frame, self.sc_fakeImageView.center)) {
                    findIndexPath = indexPathAndFrame.indexPath;
                    findCell = [self.sc_collectionView cellForItemAtIndexPath:findIndexPath];
                    break;
                }
            }
            
            if (!findCell || !findIndexPath || findCell.hidden) return;
            
            NSIndexPath *currentIndexPath = [self.sc_collectionView indexPathForCell:self];
            [self.sc_moveableCellDelegate collectionViewCell:self bringDataSourceFromIndexPath:currentIndexPath toIndexPath:findIndexPath];
            [self.sc_collectionView moveItemAtIndexPath:currentIndexPath toIndexPath:findIndexPath];
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            [UIView animateWithDuration:0.25 animations:^{
                self.sc_fakeImageView.frame = self.sc_info.endFrame;
                self.sc_fakeImageView.alpha = 1;
            } completion:^(BOOL finished) {
                self.hidden = NO;
                [self.sc_fakeImageView removeFromSuperview];
            }];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - Getter and Setter

- (id<SCMoveableCellDelegate>)sc_moveableCellDelegate
{
    SCMoveableCellWeakProxy *weakProxy = objc_getAssociatedObject(self, @selector(sc_moveableCellDelegate));
    return weakProxy.target;
}

- (void)setSc_moveableCellDelegate:(id<SCMoveableCellDelegate>)sc_moveableCellDelegate
{
    if (self.sc_moveableCellDelegate == sc_moveableCellDelegate) return;
    
    if (!self.sc_moveableCellDelegate && sc_moveableCellDelegate) {
        [self addGestureRecognizer:self.sc_longPressGestureRecognizer];
    } else if (self.sc_moveableCellDelegate && !sc_moveableCellDelegate) {
        [self removeGestureRecognizer:self.sc_longPressGestureRecognizer];
    }
    
    SCMoveableCellWeakProxy *weakProxy = [SCMoveableCellWeakProxy new];
    weakProxy.target = sc_moveableCellDelegate;
    objc_setAssociatedObject(self, @selector(sc_moveableCellDelegate), weakProxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UICollectionView *)sc_collectionView
{
    SCMoveableCellWeakProxy *weakProxy = objc_getAssociatedObject(self, @selector(sc_collectionView));
    UICollectionView *collectionView = weakProxy.target;
    if (!collectionView) {
        UIView *superView = self.superview;
        while (superView) {
            if ([superView isKindOfClass:[UICollectionView class]]) {
                break;
            }
        }
        collectionView = (UICollectionView *)superView;
        SCMoveableCellWeakProxy *weakProxy = [SCMoveableCellWeakProxy new];
        weakProxy.target = collectionView;
        objc_setAssociatedObject(self, @selector(sc_collectionView), weakProxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return collectionView;
}

- (UIImageView *)sc_fakeImageView
{
    SCMoveableCellWeakProxy *weakProxy = objc_getAssociatedObject(self, @selector(sc_fakeImageView));
    return weakProxy.target;
}

- (void)setSc_fakeImageView:(UIImageView *)sc_fakeImageView
{
    if (self.sc_fakeImageView == sc_fakeImageView) return;
    
    SCMoveableCellWeakProxy *weakProxy = [SCMoveableCellWeakProxy new];
    weakProxy.target = sc_fakeImageView;
    objc_setAssociatedObject(self, @selector(sc_fakeImageView), weakProxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UILongPressGestureRecognizer *)sc_longPressGestureRecognizer
{
    UILongPressGestureRecognizer *longPressGestureRecognizer = objc_getAssociatedObject(self, @selector(sc_longPressGestureRecognizer));
    if (!longPressGestureRecognizer) {
        longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(sc_onActionLongPress:)];
        objc_setAssociatedObject(self, @selector(sc_longPressGestureRecognizer), longPressGestureRecognizer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return longPressGestureRecognizer;
}

- (SCMoveableCellInfo *)sc_info
{
    return objc_getAssociatedObject(self, @selector(sc_info));
}

- (void)setSc_info:(SCMoveableCellInfo *)sc_info
{
    if (self.sc_info == sc_info) return;
    
    objc_setAssociatedObject(self, @selector(sc_info), sc_info, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end