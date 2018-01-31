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


//获取输出的task
+(void)catTaskWithArguments:(NSArray<NSString*> *)arugments handler:(void(^)(NSString* str))handler;
@end
