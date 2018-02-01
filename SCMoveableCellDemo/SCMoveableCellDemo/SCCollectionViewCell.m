
#import "SCCollectionViewCell.h"

@implementation SCCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor grayColor];
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 85, 20)];
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        self.titleLabel.textColor = [UIColor blueColor];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 85, 85)];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.layer.masksToBounds = YES;
        
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.titleLabel];
    }
    return self;
}

- (void)dealloc
{
    
}

@end
