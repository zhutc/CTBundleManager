//
//  CTDropOutlineView.m
//  CTBundleManager
//
//  Created by 朱天超 on 2018/1/30.
//  Copyright © 2018年 ctrip.com. All rights reserved.
//

#import "CTDropOutlineView.h"
#import "CTNode.h"
#import "CTDropCell.h"
#define kDragOutlineViewTypeName @"kDragOutlineViewTypeName"

static CTDropOutlineView* currentDropOutlineView;
static CTNode* currentParent;

@interface CTDropOutlineView()<NSOutlineViewDataSource , NSOutlineViewDelegate>
@property (nonatomic , strong) IBOutlet NSScrollView* scrollView;
@property (nonatomic , strong) IBOutlet NSOutlineView* outlineView;
@property (nonatomic , strong) NSMutableArray* dataArray;
@property (nonatomic , strong) NSPasteboardType passtedboardType;
@end

@implementation CTDropOutlineView

-(BOOL)containsNode:(CTNode *)node
{
    for (CTNode* nd in self.dataArray) {
        if ([node.name isEqualToString:nd.name]) {
            return YES;
        }
    }
    return NO;
}

-(CTNode *)topNodeForName:(CTNode *)node
{
    for (CTNode* nd in self.dataArray) {
        if ([node.name isEqualToString:nd.name]) {
            return nd;
        }
    }
    return nil;
}
-(void)configTestData{
    static int a = 0;
    CTNode* root = [[CTNode alloc] init];
    root.name = @"root";
    
    CTNode* n1 = [[CTNode alloc] init];
    CTNode* n2 = [[CTNode alloc] init];
    CTNode* n3 = [[CTNode alloc] init];
    n1.name = [NSString stringWithFormat:@"n%d",++a];
    n2.name = [NSString stringWithFormat:@"n%d",++a];
    n3.name = [NSString stringWithFormat:@"n%d",++a];

    [root addNode:n1];
    [root addNode:n2];
    [root addNode:n3];
    
    CTNode* root1 = [[CTNode alloc] init];
    root1.name = @"root1";
    
    CTNode* n4 = [[CTNode alloc] init];
    CTNode* n5 = [[CTNode alloc] init];
    CTNode* n6 = [[CTNode alloc] init];
    
    n4.name = [NSString stringWithFormat:@"n%d",++a];
    n5.name = [NSString stringWithFormat:@"n%d",++a];
    n6.name = [NSString stringWithFormat:@"n%d",++a];
    
    [root1 addNode:n4];
    [root1 addNode:n5];
    [root1 addNode:n6];

    self.dataArray = [NSMutableArray arrayWithObjects:root,root1, nil];
    [self.outlineView reloadData];
}

 - (instancetype)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        [self creatOutlineView];
        [self configTestData];
    }
    return self;
}

-(void)creatOutlineView{
    [[NSBundle mainBundle] loadNibNamed:@"CTDropOutlineView" owner:self topLevelObjects:nil];
//    [self addSubview:self.outlineView];
    [self addSubview:self.scrollView];
    [self configScrollViewConstraint];


    self.passtedboardType = kDragOutlineViewTypeName;
    [self.outlineView registerForDraggedTypes:@[self.passtedboardType]];
    
}

-(void)configScrollViewConstraint
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollView
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollView
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1.0
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollView
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1.0
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:1.0
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:1.0
                                                      constant:0]];
    [self updateConstraints];
}

#pragma mark - NSOutlineViewDataSource

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(CTNode* )item
{
    if (nil == item) {
        return self.dataArray.count;
    }
    if (item.childrens) {
        return item.childrens.count;
    }
    return 0;
}

-(id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(CTNode* )item
{
    if(nil == item){
        return self.dataArray[index];
    }
    return item.childrens[index];
}
-(BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(CTNode *)item
{
    if (item) {
        return item.childrens.count > 0;
    }
    return YES;
}

//拖动处理
-(BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pasteboard
{
    NSLog(@"items = %@",items);
    CTNode* node = items.firstObject;
    NSData* encodeData = [NSKeyedArchiver archivedDataWithRootObject:node];
    [pasteboard declareTypes:@[self.passtedboardType] owner:self];
    [pasteboard setData:encodeData forType:self.passtedboardType];

    currentDropOutlineView = self;
    currentParent = node.parent;
    return YES;
}
//接受拖动
- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id<NSDraggingInfo>)info item:(CTNode *)item childIndex:(NSInteger)index
{
    if ([self isEqual:currentDropOutlineView] || (0 == item.childrens.count && item)) {
        currentParent = nil;
        currentDropOutlineView = nil;
        return NO;
    }

    NSPasteboard* pasteboard = info.draggingPasteboard;
    NSData* data = [pasteboard dataForType:self.passtedboardType];
    CTNode* acceptNode = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    if (acceptNode && item) {
        if (currentParent == nil && ![acceptNode.name isEqualToString:item.name]) {
            return NO;
        }
        if (![item.name isEqualToString:acceptNode.parentName] && acceptNode.parentName) {
            return NO;
        }
    }
    /** 处理空数据源情况 */
    if (nil == item) {
        if (nil == currentParent) {
            if (![self containsNode:acceptNode]) {
                CTNode* realNode = acceptNode ;
                item = [[CTNode alloc] init];
                item.name = realNode.name;
                item.parent = realNode.parent;
                [self.dataArray addObject:item];                
            }
        }else{
            if ([self containsNode:currentParent]) {
                CTNode* topNode = [self topNodeForName:currentParent];
                item = topNode;
            }else{
                CTNode* realNode = currentParent ;
                item = [[CTNode alloc] init];
                item.name = realNode.name;
                item.parent = realNode.parent;
                [self.dataArray addObject:item];
            }
           
        }
    }
    
    
    /** 移除原始表 */
    if (currentParent/* acceptNode.parent */) {
        [currentParent removeNode:acceptNode]; //[acceptNode.parent removeNode:acceptNode];
        if (0 == currentParent.childrens.count) {
            [currentDropOutlineView.dataArray removeObject:currentParent];
        }
    }else{
        [currentDropOutlineView.dataArray removeObject:acceptNode];
    }

    if (0 == acceptNode.childrens.count) {
        [item addNode:acceptNode];
    }else {/** 接受group的children */
        [acceptNode.childrens enumerateObjectsUsingBlock:^(CTNode*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [item addNode:obj];
        }];
    }
    NSLog(@"info = %@ , item = %@ index = %ld acceptNode = %@",info,item,(long)index , acceptNode);
    [currentDropOutlineView.outlineView reloadData];
    currentDropOutlineView = nil;
    [outlineView reloadData];
    return YES;
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id<NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(NSInteger)index
{
    return NSDragOperationEvery;
}

#pragma mark - NSOutlineViewDelegate

-(NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(CTNode *)item
{
    CTDropCell* cell = [outlineView makeViewWithIdentifier:tableColumn.identifier owner:self];
    cell.textField.stringValue = item.name;

    return cell;
}

-(CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item
{
    return 30;
}


@end
