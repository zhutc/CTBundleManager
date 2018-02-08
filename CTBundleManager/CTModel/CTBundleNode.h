//
//  CTBundleNode.h
//  CTBundleManager
//
//  Created by ChuTing on 2018/1/31.
//  Copyright © 2018年 ctrip.com. All rights reserved.
//

#import "CTNode.h"

@interface CTBundleNode : CTNode
@property(nonatomic , copy) NSString* SourceCodeLocalPath;
@property(nonatomic , copy) NSString* RemoteCodePath;
@property(nonatomic , assign) BOOL hasResouceBundle;
@property(nonatomic , assign) BOOL isLib;
@property(nonatomic , assign) BOOL disable;
@property(nonatomic , strong) NSArray* dependency;

-(instancetype)initWithDictionary:(NSDictionary*)dic;
-(NSDictionary *)toDictionary;
@end
