//
//  CTSettingCache.m
//  CTBundleManager
//
//  Created by 朱天超 on 2018/2/1.
//  Copyright © 2018年 ctrip.com. All rights reserved.
//

#import "CTSettingCache.h"

@implementation CTSettingCache
- (instancetype)init{
    self = [super init];
    if (self) {
    }
    return self;
}
+(CTSettingCache *)settingCache
{
    return [[[self class] alloc] init];
}

+(void)setObject:(id<NSCoding>)object forKey:(NSString*)key{
    [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(id)objectForKey:(NSString *)key{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}
+(void)removeObjectForKey:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
