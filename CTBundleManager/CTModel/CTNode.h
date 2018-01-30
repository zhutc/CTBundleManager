//
//  CTNode.h
//  CTBundleManager
//
//  Created by 朱天超 on 2018/1/30.
//  Copyright © 2018年 ctrip.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CTNode : NSObject
@property (nonatomic , copy) NSString* name;
@property (nonatomic , weak) CTNode* parent; //super node
@property (nonatomic , strong) NSMutableArray* childrens; // children node
-(void)addNode:(CTNode *)node;
-(void)removeNode:(CTNode *)node;
@end
