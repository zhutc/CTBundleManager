//
//  CTBundleNode.h
//  CTBundleManager
//
//  Created by ChuTing on 2018/1/31.
//  Copyright © 2018年 ctrip.com. All rights reserved.
//

#import "CTNode.h"

@interface CTBundleNode : CTNode
@property(nonatomic , assign) BOOL isExtension;
@property(nonatomic , copy) NSString* sourceCodeLocalPath;
@property(nonatomic , copy) NSString* remoteCodePath;
@property(nonatomic , copy) NSString* owner;
@property(nonatomic , assign) BOOL hasResouceBundle;
@property(nonatomic , assign) BOOL isLib;
@property(nonatomic , assign) BOOL disable;
@property(nonatomic , strong) NSArray* dependency;
@property(nonatomic , copy) NSString* releaseBundleVersion;
@property(nonatomic , copy) NSString* debugBundleVersion;
@property(nonatomic , copy) NSString* releaseCommitId;
@property(nonatomic , copy) NSString* debugCommitId;
-(instancetype)initWithDictionary:(NSDictionary*)dic;
-(NSDictionary *)toDictionary;
@end
