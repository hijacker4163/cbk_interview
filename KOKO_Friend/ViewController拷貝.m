//
//  ViewController.m
//  KOKO_Friend
//
//  Created by Mars Lin on 2024/10/30.
//

#import "ViewController.h"
#import <Masonry/Masonry.h>
#import "KafkaRefresh.h"
#import "KafkaArrowHeader.h"

#import "CustomTableViewCell.h"

#import "UIView+CollapsibleView.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, CustomTableViewCellDelegate>

@property (nonatomic, strong) UIView *customView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UITabBar *tabBar;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;

@property (nonatomic, strong) UIView *collapsibleView; // 可折疊view

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *waitArray;
@property (nonatomic, strong) NSMutableArray *filteredArray;

@end

@implementation ViewController

int testFlag = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // init
    self.dataArray = [NSMutableArray array];
    self.waitArray = [NSMutableArray array];
    self.filteredArray = [NSMutableArray array];
    
    UIBarButtonItem *leftButton1 = [[UIBarButtonItem alloc] initWithTitle:@"ATM" style:UIBarButtonItemStylePlain target:self action:@selector(leftButton1Tapped)];
    UIBarButtonItem *leftButton2 = [[UIBarButtonItem alloc] initWithTitle:@"$" style:UIBarButtonItemStylePlain target:self action:@selector(leftButton2Tapped)];
    self.navigationItem.leftBarButtonItems = @[leftButton1, leftButton2];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Camera" style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonTapped)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    // 初始化 collapsibleView
    self.collapsibleView = [[UIView alloc] init];
    self.collapsibleView.backgroundColor = [UIColor lightGrayColor];

    // 添加可折疊的項目
    NSArray *items = @[
        @{@"name": @"Alice"},
        @{@"name": @"Bob"},
        @{@"name": @"Charlie"}
    ];
    [self.collapsibleView addCollapsibleViewWithItems:items];

    // 將 collapsibleView 添加到主視圖中
    [self.view addSubview:self.collapsibleView];
    self.collapsibleView.translatesAutoresizingMaskIntoConstraints = NO;

    // 設定 collapsibleView 的約束
    [self.collapsibleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(100);
    }];

    self.customView = [[UIView alloc] init];
    self.customView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.customView];
    
    [self.customView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.collapsibleView.mas_bottom);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(54);
    }];
    
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"好友", @"聊天"]];
    self.segmentedControl.selectedSegmentIndex = 0;
    [self.segmentedControl addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
    [self.customView addSubview:self.segmentedControl];
    
    [self.segmentedControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.customView);
    }];
    
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"想轉一筆給誰呢？";
    
    // SearchBar - 高度
    CGRect searchBarFrame = self.searchBar.frame;
    searchBarFrame.size.height = 44;
    self.searchBar.frame = searchBarFrame;
    
    // 建立 TableView
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableHeaderView = self.searchBar;
    self.tableView.allowsSelectionDuringEditing = YES;
    
    [self.view addSubview:self.tableView];
    
    // 下拉加載
    KafkaArrowHeader *arrow = [[KafkaArrowHeader alloc] init] ;
    arrow.pullingText = @"上拉加載更多資料";
    arrow.readyText = @"放開後開始加載";
    arrow.refreshingText = @"資料讀取中...";
    arrow.refreshHandler = ^{
        testFlag++;
        if (testFlag >= 3) {
            testFlag = 0;
        }
        [self fetchData];
    };
    
    self.tableView.headRefreshControl = arrow;

    
    // TabBar - 添加五個按鈕
    self.tabBar = [[UITabBar alloc] init];
    self.tabBar.backgroundColor = [UIColor whiteColor];
    self.tabBar.itemPositioning = UITabBarItemPositioningCentered;
    [self.view addSubview:self.tabBar];
    
    NSArray *images = @[@"icTabbarProductsOff",
                        @"icTabbarFriendsOn",
                        @"",
                        @"icTabbarManageOff",
                        @"icTabbarSettingOff"];
    
    NSMutableArray *tabBarItems = [NSMutableArray array];
    
    int tag = 0;
    for (NSString *img in images) {
        UITabBarItem *item;
        if (tag == 2) {
            item = [[UITabBarItem alloc] initWithTitle:@"KO"
                                                 image:nil
                                                   tag:tag];
        } else {
            item = [[UITabBarItem alloc] initWithTitle:@""
                                                 image:[UIImage imageNamed:img]
                                                   tag:tag];
        }
        item.imageInsets = UIEdgeInsetsMake(6, 0, -10, 0);
        tag++;
        [tabBarItems addObject:item];
    }
    
    self.tabBar.items = tabBarItems;
    
    [self.tabBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(102);
    }];
    
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.customView.mas_bottom);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.tabBar.mas_top);
    }];
    
    // 點擊任意地方收起鍵盤
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tapGesture];
    
    // 加入loading view
    [self setupLoadingView];
    [self fetchData];
}

// 點擊任意地方收起鍵盤
- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

// 點擊SearchBar使tableView置頂
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self.tableView setContentOffset:CGPointZero animated:YES];
}

// 按鈕動作
- (void)leftButton1Tapped { /* 左1按鈕行為 */ }
- (void)leftButton2Tapped { /* 左2按鈕行為 */ }
- (void)rightButtonTapped { /* 右按鈕行為 */ }
- (void)segmentChanged:(UISegmentedControl *)sender { /* 分頁切換行為 */ }

#pragma mark - Loading View
- (void)setupLoadingView {
    self.backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    self.backgroundView.hidden = YES;
    [self.view addSubview:self.backgroundView];

    self.backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.backgroundView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.backgroundView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [self.backgroundView.widthAnchor constraintEqualToConstant:100],
        [self.backgroundView.heightAnchor constraintEqualToConstant:100]
    ]];

    // 初始化 loadingIndicator
    self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.loadingIndicator.center = self.backgroundView.center;
    self.loadingIndicator.hidesWhenStopped = YES;

    [self.backgroundView addSubview:self.loadingIndicator];
    
    self.loadingIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.loadingIndicator.centerXAnchor constraintEqualToAnchor:self.backgroundView.centerXAnchor],
        [self.loadingIndicator.centerYAnchor constraintEqualToAnchor:self.backgroundView.centerYAnchor]
    ]];
}


// 隱藏 loading view
- (void)hideLoadingView {
    [self.loadingIndicator stopAnimating];
    self.backgroundView.hidden = YES; // 隱藏背景視圖
}

#pragma mark - Fetch Data
- (void)fetchDataFromURL:(NSString *)urlString completion:(void (^)(NSArray *fetchedData))completion {
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSError *error = nil;

    if (data) {
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (!error) {
            NSArray *responseArray = jsonDict[@"response"];
            completion(responseArray);
        } else {
            NSLog(@"Error parsing JSON: %@", error);
            completion(nil);
        }
    } else {
        NSLog(@"Error fetching data");
        completion(nil);
    }
}

- (void)fetchData {
    [self.dataArray removeAllObjects];
    
    self.backgroundView.hidden = NO;
    [self.loadingIndicator startAnimating];
    
    NSString *urlStr = @"";
    if (testFlag == 0) {
        // 無資料邀請/好友列表
        urlStr = @"https://dimanyen.github.io/friend5.json";
    } else if (testFlag == 1) {
        // 好友列表1+好友列表2
        urlStr = @"https://dimanyen.github.io/friend1.json";
    } else if (testFlag == 2) {
        // 好友列表含邀請列表
        urlStr = @"https://dimanyen.github.io/friend3.json";
    }
    
    NSDate *startTime = [NSDate date];
    
    // 第一個 URL
    [self fetchDataFromURL:urlStr completion:^(NSArray *fetchedData) {
        if (fetchedData) {
            // parse並加入到 dataArray or waitArray
            [self parseFetchedData:fetchedData];

            if (testFlag == 1) {
                // 第二個 URL
                [self fetchDataFromURL:@"https://dimanyen.github.io/friend2.json" completion:^(NSArray *fetchedData2) {
                    if (fetchedData2) {
                        [self parseFetchedData:fetchedData2];
                    }
                    [self endFetchingWithDelaySince:startTime];
                }];
            } else {
                [self endFetchingWithDelaySince:startTime];
                
                NSArray *items = @[
                @{@"name": @"Alice"},@{@"name": @"Bob"},@{@"name": @"Charlie"}
                ];

                [self.collapsibleView addCollapsibleViewWithItems:items];
            }
        } else {
            [self endFetchingWithDelaySince:startTime];
        }
    }];
}

- (void)endFetchingWithDelaySince:(NSDate *)startTime {
    NSTimeInterval elapsed = [[NSDate date] timeIntervalSinceDate:startTime];
    NSTimeInterval delay = MAX(1.0 - elapsed, 0);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView.headRefreshControl endRefreshing];
        [self.tableView reloadData];
        [self hideLoadingView];
    });
}

- (void)parseFetchedData:(NSArray *)fetchedData {
    for (NSDictionary *friend in fetchedData) {
        int status = [friend[@"status"] intValue];
        NSString *fid = friend[@"fid"];
        NSDate *updateDate = friend[@"updateDate"];
        
        // 根據 status 和 fid 進行處理
        if (status == 0) {
            // 加入 waitArray
            [self.waitArray addObject:friend];
        } else {
            // 檢查是否已存在於 dataArray
            BOOL exists = NO;
            for (NSDictionary *existingFriend in self.dataArray) {
                if ([existingFriend[@"fid"] isEqualToString:fid]) {
                    exists = YES;

                    // 如果存在，檢查更新日期，保留較新的
                    NSDate *existingUpdateDate = existingFriend[@"updateDate"];
                    if ([updateDate compare:existingUpdateDate] == NSOrderedDescending) {
                        // 替換較舊的資料
                        [self.dataArray removeObject:existingFriend];
                        [self.dataArray addObject:friend];
                    }
                    break;
                }
            }
            // 如果不存在，加入 dataArray
            if (!exists) {
                [self.dataArray addObject:friend];
            }
        }
    }
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    // 清空篩選結果
    [self.filteredArray removeAllObjects];
    
    if (searchText.length == 0) {
        // 若搜尋欄位為空，顯示所有資料
        [self.filteredArray addObjectsFromArray:self.dataArray];
    } else {
        // 篩選包含搜尋字串的姓名
        for (NSDictionary *friend in self.dataArray) {
            NSString *name = friend[@"name"];
            if ([name containsString:searchText]) {
                [self.filteredArray addObject:friend];
            }
        }
    }
    
    // 重新載入表格
    [self.tableView reloadData];
}


#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    if (self.segmentedControl.selectedSegmentIndex == 0) {
//        // A頁面
//    } else {
//        // B頁面
//    }
    if (self.filteredArray.count > 0) {
        return self.filteredArray.count;
    } else {
        return self.dataArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"CustomCell";
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.delegate = self;
    }
    
    NSDictionary *dict = self.dataArray[indexPath.row];
    if (self.filteredArray.count > 0) {
        dict = self.filteredArray[indexPath.row];
    }
    
    // 自定義Cell
    UIImage *image = [UIImage imageNamed:@"photo"];
    NSString *name = [NSString stringWithFormat:@"%@", [dict objectForKey:@"name"]];
    
    int isTop = [[dict objectForKey:@"isTop"] intValue];
    int status = [[dict objectForKey:@"status"] intValue];
    
    [cell configureWithFavoriteVisible:(isTop == 1)
                          profileImage:image
                                  name:name
                  actionButton1Visible:YES
                  actionButton2Visible:(status == 2)
                     moreButtonVisible:(status == 1)];

    return cell;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *deleteAction =
    [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive
                                       title:@"刪除"
                                     handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
    {
        [self handleDeleteActionAtIndexPath:indexPath];
    }];
    return @[deleteAction];
}

#pragma mark - CustomTableViewCellDelegate
- (void)cellDidTapMoreButton:(CustomTableViewCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath) {
        // 創建彈出選單
        UIAlertController *actionSheet =
    [UIAlertController alertControllerWithTitle:nil
                                        message:nil
                                 preferredStyle:UIAlertControllerStyleActionSheet];
            
        // 刪除
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"刪除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self handleDeleteActionAtIndexPath:indexPath];
        }];
        [actionSheet addAction:deleteAction];
            
        // 最愛
        UIAlertAction *favoriteAction = [UIAlertAction actionWithTitle:@"最愛" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self handleFavoriteActionForCell:cell];
        }];
        [actionSheet addAction:favoriteAction];
            
        // 取消
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [actionSheet addAction:cancelAction];
        
        // show
        [self presentViewController:actionSheet animated:YES completion:nil];
    }
}

// 刪除操作
- (void)handleDeleteActionAtIndexPath:(NSIndexPath *)indexPath {
    if (self.filteredArray.count > 0) {
        [self.filteredArray removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
        self.searchBar.text = @"";
        return;
    } else {
        [self.dataArray removeObjectAtIndex:indexPath.row];
    }
    
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

// 最愛操作
- (void)handleFavoriteActionForCell:(CustomTableViewCell *)cell {
    cell.favoriteButton.hidden = !cell.favoriteButton.hidden;
}

@end
