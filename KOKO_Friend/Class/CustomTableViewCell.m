#import "CustomTableViewCell.h"
#import <Masonry/Masonry.h>

@interface CustomTableViewCell ()

@property (nonatomic, strong) UIButton *moreButton;

@end

@implementation CustomTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // 星號按鈕
        self.favoriteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.favoriteButton setImage:[UIImage imageNamed:@"icFriendsStar"] forState:UIControlStateNormal];
        [self.contentView addSubview:self.favoriteButton];
        
        // 圓形圖片
        self.profileImageView = [[UIImageView alloc] init];
        self.profileImageView.layer.cornerRadius = 25; // 設定圓形
        self.profileImageView.clipsToBounds = YES;
        [self.contentView addSubview:self.profileImageView];
        
        // 名字
        self.nameLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.nameLabel];
        
        // 按鈕
        self.actionButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.actionButton1 setTitle:@"轉帳" forState:UIControlStateNormal];
        [self.actionButton1 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self.contentView addSubview:self.actionButton1];

        self.actionButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.actionButton2 setTitle:@"邀請中" forState:UIControlStateNormal];
        [self.actionButton2 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self.contentView addSubview:self.actionButton2];

        self.moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.moreButton setTitle:@"..." forState:UIControlStateNormal];
        [self.moreButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.moreButton addTarget:self action:@selector(moreButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.moreButton];

        [self layoutUI];
    }
    return self;
}

- (void)layoutUI {
    // 使用 Masonry 進行約束
    [self.favoriteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(10);
        make.centerY.equalTo(self.contentView);
        make.width.height.mas_equalTo(30);
    }];
    
    [self.profileImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.favoriteButton.mas_right).offset(10);
        make.centerY.equalTo(self.contentView);
        make.width.height.mas_equalTo(50);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.profileImageView.mas_right).offset(10);
        make.centerY.equalTo(self.contentView);
    }];
    
    [self.moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-10);
        make.centerY.equalTo(self.contentView);
    }];
    
    [self.actionButton2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.moreButton.mas_left).offset(-10);
        make.centerY.equalTo(self.contentView);
    }];

    [self.actionButton1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.actionButton2.mas_left).offset(-10);
        make.centerY.equalTo(self.contentView);
    }];
}

- (void)configureWithFavoriteVisible:(BOOL)favoriteVisible
                        profileImage:(UIImage *)image
                                name:(NSString *)name
                actionButton1Visible:(BOOL)actionButton1Visible
                actionButton2Visible:(BOOL)actionButton2Visible
                   moreButtonVisible:(BOOL)moreButtonVisible {
    self.favoriteButton.hidden = !favoriteVisible;
    self.profileImageView.image = image;
    self.nameLabel.text = name;
    self.actionButton1.hidden = !actionButton1Visible;
    self.actionButton2.hidden = !actionButton2Visible;
    self.moreButton.hidden = !moreButtonVisible;
}

- (void)moreButtonTapped {
    [self showMoreButton];
}

- (void)showMoreButton {
    if ([self.delegate respondsToSelector:@selector(cellDidTapMoreButton:)]) {
        [self.delegate cellDidTapMoreButton:self];
    }
}

@end
