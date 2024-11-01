//
//  CustomTableViewCell.h
//  KOKO_Friend
//
//  Created by Mars Lin on 2024/10/30.
//

#import <UIKit/UIKit.h>

@class CustomTableViewCell;

@protocol CustomTableViewCellDelegate <NSObject>
- (void)cellDidTapMoreButton:(CustomTableViewCell *)cell;

@end

@interface CustomTableViewCell : UITableViewCell

@property (nonatomic, strong) UIButton *favoriteButton;
@property (nonatomic, strong) UIImageView *profileImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIButton *actionButton1;
@property (nonatomic, strong) UIButton *actionButton2;

@property (nonatomic, weak) id<CustomTableViewCellDelegate> delegate;

- (void)configureWithFavoriteVisible:(BOOL)favoriteVisible
                        profileImage:(UIImage *)image
                                name:(NSString *)name
                actionButton1Visible:(BOOL)actionButton1Visible
                actionButton2Visible:(BOOL)actionButton2Visible
                   moreButtonVisible:(BOOL)moreButtonVisible;

@end

