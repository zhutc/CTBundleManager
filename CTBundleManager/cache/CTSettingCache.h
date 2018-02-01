//
//  CTSettingCache.h
//  CTBundleManager
//
//  Created by 朱天超 on 2018/2/1.
//  Copyright © 2018年 ctrip.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kCtripSpecKey @"kCtripSpecKey" // ctrip.spec
#define kCtripJSONLockFilePathKey @"kCtripJSONLockFilePathKey" // ctrip.json.lock
#define kPython @"kPython" // /usr/bin/python

@interface CTSettingCache : NSObject
+(CTSettingCache *)settingCache;
+(void)setObject:(id<NSCoding>)object forKey:(NSString*)key;
+(id)objectForKey:(NSString *)key;
+(void)removeObjectForKey:(NSString *)key;
@end
