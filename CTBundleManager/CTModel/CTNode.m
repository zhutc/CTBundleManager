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
    
    for (CTNode* nd in self.childrens) {
        if ([nd isEqual:node]) {
            return;
        }
    }
    node.parent = self;
    node.parentName = self.name;
    [self.childrens addObject:node];
    
}
-(void)removeNode:(CTNode *)node
{
    if (nil == node || NO == [node isKindOfClass:[CTNode class]]) return;
    for (CTNode* nd in self.childrens) {
        if ([nd isEqual:node]) {
            node.parent = nil;
            node.parentName = nil;
            [self.childrens removeObject:nd];
            return;
        }
    }
}
-(NSString *)description
{
    return [NSString stringWithFormat:@"name = %@ , parent = %@ , children = %@",self.name,self.parent.name , self.childrens];
}

/** code */
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.parentName forKey:@"parentName"];
//    [aCoder encodeObject:self.parent forKey:@"parent"];
    [aCoder encodeObject:self.childrens forKey:@"childrens"];
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.parentName = [aDecoder decodeObjectForKey:@"parentName"];
//        self.parent = [aDecoder decodeObjectForKey:@"parent"];
        self.childrens = [aDecoder decodeObjectForKey:@"childrens"];
    }
    return self;
}
-(BOOL)isEqual:(CTNode *)object
{
    if ([object isKindOfClass:[CTNode class]]) {
        return [object.name isEqual:self.name] && (self.childrens.count == object.childrens.count) ;
    }
    return [super isEqual:object];
}

@end
