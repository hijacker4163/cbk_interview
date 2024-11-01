#import "ViewController.h"
#import "UIView+CollapsibleView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *items = @[
        @{@"name": @"Alice"},@{@"name": @"Bob"},@{@"name": @"Charlie"}
    ];

    [self.view addCollapsibleViewWithItems:items];
}

@end
