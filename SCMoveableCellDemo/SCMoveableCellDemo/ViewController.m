
#import "ViewController.h"
#import "SCCollectionViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"click viewController view";
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    SCCollectionViewController *viewController = [SCCollectionViewController new];
    [self.navigationController pushViewController:viewController animated:YES];
}


@end
