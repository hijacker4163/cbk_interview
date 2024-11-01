//
//  UIView+CollapsibleView.h
//  KOKO_Friend
//
//  Created by Mars Lin on 2024/10/30.
//

#import <UIKit/UIKit.h>

@interface UIView (CollapsibleView)

- (void)addCollapsibleViewWithItems:(NSArray<NSString *> *)items;

extern NSString * const CollapsibleViewDidToggleExpandNotification;
extern NSString * const CollapsibleViewIsExpandedKey;

@end

