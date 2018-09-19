//
//  CTVCModelView.h
//  CTBundleManager
//
//  Created by ChuTing on 2018/1/31.
//  Copyright © 2018年 ctrip.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CTBundleManagerStatus) {
    CTBundleManagerStatusNormal = 0,
    CTBundleManagerStatusNoSpec,
    CTBundleManagerStatusRootError,
    CTBundleManagerStatusCtripJSONError,
    CTBundleManagerStatusOK
};


@interface CTVCModelView : NSObject

/**
  CtripJSON中的字段
 */
@property(nonatomic , assign) BOOL allBaseIsSource;
@property(nonatomic , assign) BOOL debug;
@property(nonatomic , strong) NSMutableDictionary* extensionOtherFields; /** extension 扩展的字段 */

@property(nonatomic , strong) NSMutableArray* excludeArray;/** 不参与编译 */
@property(nonatomic , strong) NSMutableArray* bundleArray;/** Bundle编译 */
@property(nonatomic , strong) NSMutableArray* sourceArray;/** 源码编译 */

@property (assign) CTBundleManagerStatus status;
@property (nonatomic , copy) NSString* specContent;

#pragma mark - 外部参数
@property (nonatomic , copy) NSString* rootPath;
@property (nonatomic , copy) NSString* ctripSpecPath;
@property (nonatomic , copy) NSString* ctripJsonPath;
@property (nonatomic , copy) NSString* ctripJsonLockPath;/** 生成一个json.lock */
@property (nonatomic , copy) NSString* xcodeprojPath;
@property (nonatomic , copy) NSString* appVersion;

-(void)readArguments:(NSString* )specPath;

-(void)saveCtripJSONLockFile;
- (BOOL)acceptDrag:(id)node;
-(void)configNode;/** 刷新分组 */
@end
