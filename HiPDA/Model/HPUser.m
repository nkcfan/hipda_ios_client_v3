//
//  HPUser.m
//  HiPDA
//
//  Created by wujichao on 13-11-11.
//  Copyright (c) 2013年 wujichao. All rights reserved.
//

#import "HPUser.h"

@implementation HPUser {
@private
    NSString *_avatarImageURLString;
}

- (id)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _uid = [[attributes valueForKeyPath:@"uid"] integerValue];
    _username = [attributes valueForKeyPath:@"username"];
    
    // 在post页面 可以直接获得 avatar url
    // 也可以直接判断是否存在 avatar
    NSString *avatar = [attributes valueForKeyPath:@"avatar"];
    if (avatar) {
        if (![avatar isEqualToString:@"000/00/00/00"]) {
            _avatarImageURLString = [NSString stringWithFormat:@"http://www.hi-pda.com/forum/uc_server/data/avatar/%@_avatar_small.jpg", avatar];
            _avatarImageURL = [NSURL URLWithString:_avatarImageURLString];
            //NSLog(@"avatar url %@", _avatarImageURL);
        } else {
            _avatarImageURL = nil;
        }
        
    } else {
        
        /*
         http://www.hi-pda.com/forum/uc_server/data/avatar/000/00/53/69_avatar_middle.jpg
         http://www.hi-pda.com/forum/uc_server/data/avatar/000/02/61/71_avatar_middle.jpg
         http://www.hi-pda.com/forum/uc_server/data/avatar/000/22/22/37_avatar_middle.jpg
         
         2013-9-15 最新会员 747004
         */
        
        NSUInteger a, b, c;
        a = _uid / 10000;
        b = _uid % 10000 / 100;
        c = _uid % 100;
        //NSLog(@"%02d/%02d/%02d", a, b, c);
        
        //size [small middle big]
        _avatarImageURLString = [NSString stringWithFormat:@"http://www.hi-pda.com/forum/uc_server/data/avatar/000/%02ld/%02ld/%02ld_avatar_small.jpg", a, b, c];
        _avatarImageURL = [NSURL URLWithString:_avatarImageURLString];
    }
    
    return self;
}



- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:_uid forKey:@"uid"];
    [aCoder encodeObject:_username forKey:@"username"];
    [aCoder encodeObject:_avatarImageURL forKey:@"avatarImageURL"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _uid = [aDecoder decodeIntegerForKey:@"uid"];
        _username = [aDecoder decodeObjectForKey:@"username"];
        _avatarImageURL = [aDecoder decodeObjectForKey:@"avatarImageURL"];
    }
    return self;
}


+ (NSURL *)avatarStringWithUid:(NSInteger)_uid {
    
    if (!_uid) {
        return nil;
    }
    
    NSInteger a, b, c;
    a = _uid / 10000;
    b = _uid % 10000 / 100;
    c = _uid % 100;
    //NSLog(@"%02d/%02d/%02d", a, b, c);
    
    NSString *avatarImageURLString = [NSString stringWithFormat:@"http://www.hi-pda.com/forum/uc_server/data/avatar/000/%02ld/%02ld/%02ld_avatar_small.jpg", a, b, c];
    return [NSURL URLWithString:avatarImageURLString];
}

@end
