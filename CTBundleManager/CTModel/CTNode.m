//
//  CTNode.m
//  CTBundleManager
//
//  Created by 朱天超 on 2018/1/30.
//  Copyright © 2018年 ctrip.com. All rights reserved.
//

#import "CTNode.h"

@implementation CTNode

- (NSMutableArray *)childrens
{
    if (!_childrens) {
        _childrens = [NSMutableArray array];
    }
    return _childrens;
}
-(void)addNode:(CTNode *)node{
    if (nil == node || NO == [node isKindOfClass:[CTNode class]] || [self.childrens containsObject:node] ) return;
    node.parent = self;
    [self.childrens addObject:node];
    
}
-(void)removeNode:(CTNode *)node
{
    if (nil == node || NO == [node isKindOfClass:[CTNode class]] || NO == [self.childrens containsObject:node]) return;
    node.parent = nil;
    [self.childrens removeObject:node];
}
@end
