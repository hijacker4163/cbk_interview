//
//  FriendModel.h
//  KOKO_Friend
//
//  Created by Mars Lin on 2024/10/31.
//

#import <Foundation/Foundation.h>

@interface FriendModel : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *fid;
@property (nonatomic, assign) int status;
@property (nonatomic, assign) int isTop;
@property (nonatomic, strong) NSDate *updateDate;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

