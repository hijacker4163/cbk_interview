//
//  FriendModel.m
//  KOKO_Friend
//
//  Created by Mars Lin on 2024/10/31.
//

#import "FriendModel.h"

@implementation FriendModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _name = dictionary[@"name"];
        _fid = dictionary[@"fid"];
        _status = [dictionary[@"status"] intValue];
        _isTop = [dictionary[@"isTop"] intValue];
        _updateDate = dictionary[@"updateDate"];
    }
    return self;
}

@end

