//
//  CTTask.h
//  CTBundleManager
//
//  Created by 朱天超 on 2018/1/31.
//  Copyright © 2018年 ctrip.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CTTask : NSObject
+(NSTask*)taskWithLaunchPath:(NSString *)launchPath
                arguments:(NSArray *)arguments
            currentWorkSpace:(NSString *)workspace;

+(NSTask*)taskWithLaunchPath:(NSString *)launchPath
                   arguments:(NSArray *)arguments
            currentWorkSpace:(NSString *)workspace
               outputhandler:(void(^)(NSString* str))handler;

/**  /usr/bin/sh task */
+(void)shTaskWithArguments:(NSArray<NSString *> *)arguments
                          handler:(void(^)(NSString* str))handler;

/**  /usr/bin/cat task */
+(void)catTaskWithArguments:(NSArray<NSString*> *)arguments
                    handler:(void(^)(NSString* str))handler;

/** /usr/bin/which task */
+(void)whichTaskWithArguments:(NSArray<NSString *> *)arguments
                   handler:(void(^)(NSString* str))handler;


/** 执行工程配置 python pbxhelper.py */
+(void)installTaskWithLaunchPath:(NSString *)launchPath
                       arguments:(NSArray *)arguments
                currentWorkSpace:(NSString *)workspace
                      receiveLog:(void(^)(NSString* str))receiveLogHander
                         handler:(void(^)(NSString* str))handler;


@end
