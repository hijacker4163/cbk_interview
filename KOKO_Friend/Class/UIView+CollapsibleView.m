#import "UIView+CollapsibleView.h"
#import <Masonry/Masonry.h>
#import "FriendModel.h"

@interface CollapsibleView : UIView

@property (nonatomic, strong) NSMutableArray<UIView *> *additionalViews;
@property (nonatomic, assign) BOOL isExpanded;
@property (nonatomic, strong) UIView *collapsedView;

- (instancetype)initWithFrame:(CGRect)frame items:(NSArray<NSDictionary *> *)items;

@end

// Notification
NSString * const CollapsibleViewDidToggleExpandNotification = @"CollapsibleViewDidToggleExpandNotification";
NSString * const CollapsibleViewIsExpandedKey = @"CollapsibleViewIsExpandedKey";

@implementation CollapsibleView

- (instancetype)initWithFrame:(CGRect)frame items:(NSArray<NSDictionary *> *)items {
    self = [super initWithFrame:frame];
    if (self) {
        _isExpanded = NO;
        _additionalViews = [NSMutableArray array];
        [self setupWithItems:items];
    }
    return self;
}

- (void)setupWithItems:(NSArray<FriendModel *> *)items {
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.backgroundColor = [UIColor whiteColor];
    [self addSubview:scrollView];
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    // 創建第一個view
    UIView *firstView = [[UIView alloc] init];
    firstView.backgroundColor = [UIColor lightGrayColor];
    firstView.userInteractionEnabled = YES;
    [scrollView addSubview:firstView];
    [firstView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(scrollView).offset(20);
        make.centerX.equalTo(scrollView);
        make.height.mas_equalTo(80);
    }];
    
    // 添加手勢
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleExpand:)];
    [firstView addGestureRecognizer:tapGesture];
    
    UIImageView *profileImageView = [[UIImageView alloc] init];
    profileImageView.layer.cornerRadius = 20;
    profileImageView.clipsToBounds = YES;
    profileImageView.image = [UIImage imageNamed:@"photo"];
    [firstView addSubview:profileImageView];
    [profileImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(firstView).offset(5);
        make.left.equalTo(firstView).offset(10);
        make.width.height.mas_equalTo(40);
    }];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.text = items[0].name;
    nameLabel.font = [UIFont boldSystemFontOfSize:16];
    [firstView addSubview:nameLabel];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(firstView).offset(5);
        make.left.equalTo(profileImageView.mas_right).offset(10);
        make.right.equalTo(firstView).offset(-130);
    }];
    
    UILabel *descriptionLabel = [[UILabel alloc] init];
    descriptionLabel.text = @"邀請你成為好友:）";
    descriptionLabel.font = [UIFont systemFontOfSize:12];
    descriptionLabel.textColor = [UIColor grayColor];
    [firstView addSubview:descriptionLabel];
    [descriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nameLabel.mas_bottom).offset(5);
        make.left.equalTo(nameLabel);
        make.right.equalTo(nameLabel);
    }];
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeSystem];
    [button1 setTitle:@"Ok" forState:UIControlStateNormal];
    [firstView addSubview:button1];
    [button1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(firstView).offset(5);
        make.right.equalTo(firstView).offset(-70);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(30);
    }];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeSystem];
    [button2 setTitle:@"No" forState:UIControlStateNormal];
    [firstView addSubview:button2];
    [button2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(button1);
        make.right.equalTo(firstView).offset(-10);
        make.width.height.equalTo(button1);
    }];
    
    // 新增摺疊視圖
    self.collapsedView = [[UIView alloc] init];
    self.collapsedView.backgroundColor = [UIColor grayColor];
    [scrollView addSubview:self.collapsedView];
    [self.collapsedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(firstView.mas_bottom);
        make.centerX.equalTo(scrollView);
        make.width.equalTo(firstView).multipliedBy(0.9);
        make.height.mas_equalTo(10);
    }];
    
    // 新增其他view (item 2 和 item 3)
    UIView *lastView = firstView;
    for (int i = 1; i < items.count; i++) {
        UIView *additionalView = [[UIView alloc] init];
        additionalView.backgroundColor = [UIColor lightGrayColor];
        [scrollView addSubview:additionalView];
        [additionalView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(lastView.mas_bottom).offset(10);
            make.centerX.equalTo(scrollView);
            make.height.mas_equalTo(80);
        }];
        
        FriendModel *item = items[i];
        
        UIImageView *profileImageView = [[UIImageView alloc] init];
        profileImageView.layer.cornerRadius = 20;
        profileImageView.clipsToBounds = YES;
        profileImageView.image = [UIImage imageNamed:@"photo"];
        [additionalView addSubview:profileImageView];
        [profileImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(additionalView).offset(5);
            make.left.equalTo(additionalView).offset(10);
            make.width.height.mas_equalTo(40);
        }];
        
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.text = item.name;
        nameLabel.font = [UIFont boldSystemFontOfSize:16];
        [additionalView addSubview:nameLabel];
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(additionalView).offset(5);
            make.left.equalTo(profileImageView.mas_right).offset(10);
            make.right.equalTo(additionalView).offset(-130);
        }];
        
        UILabel *descriptionLabel = [[UILabel alloc] init];
        descriptionLabel.text = @"邀請你成為好友:）";
        descriptionLabel.font = [UIFont systemFontOfSize:12];
        descriptionLabel.textColor = [UIColor grayColor];
        [additionalView addSubview:descriptionLabel];
        [descriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(nameLabel.mas_bottom).offset(5);
            make.left.equalTo(nameLabel);
            make.right.equalTo(nameLabel);
        }];
        
        UIButton *button1 = [UIButton buttonWithType:UIButtonTypeSystem];
        [button1 setTitle:@"Ok" forState:UIControlStateNormal];
        [additionalView addSubview:button1];
        [button1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(additionalView).offset(5);
            make.right.equalTo(additionalView).offset(-70);
            make.width.mas_equalTo(50);
            make.height.mas_equalTo(30);
        }];
        
        UIButton *button2 = [UIButton buttonWithType:UIButtonTypeSystem];
        [button2 setTitle:@"No" forState:UIControlStateNormal];
        [additionalView addSubview:button2];
        [button2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(button1);
            make.right.equalTo(additionalView).offset(-10);
            make.width.height.equalTo(button1);
        }];
        
        additionalView.hidden = YES;
        [self.additionalViews addObject:additionalView];
        lastView = additionalView;
    }
    
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(lastView).offset(20);
    }];
}

// 切換展開狀態
- (void)toggleExpand:(UITapGestureRecognizer *)gesture {
    self.isExpanded = !self.isExpanded;
    
    self.collapsedView.hidden = self.isExpanded;
    
    for (UIView *view in self.additionalViews) {
        view.hidden = !self.isExpanded;
    }
    
    UIScrollView *scrollView = self.subviews[0];
    CGRect rect = CGRectMake(0, 0, self.bounds.size.width, 0);
    if (self.isExpanded) {
        rect.size.height = 120+80;
        self.frame = rect;
        
        scrollView.contentSize = CGSizeMake(self.bounds.size.width, 120 + ((self.additionalViews.count) * 80));
    } else {
        rect.size.height = 120;
        self.frame = rect;
        
        scrollView.contentSize = CGSizeMake(self.bounds.size.width, 120);
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:CollapsibleViewDidToggleExpandNotification
                                                        object:self
                                                          userInfo:@{CollapsibleViewIsExpandedKey: @(self.isExpanded)}];
}

@end

@implementation UIView (CollapsibleView)

- (void)addCollapsibleViewWithItems:(NSArray<NSDictionary *> *)items {
    CollapsibleView *collapsibleView = [[CollapsibleView alloc] initWithFrame:self.bounds items:items];
    [self addSubview:collapsibleView];
}

@end
