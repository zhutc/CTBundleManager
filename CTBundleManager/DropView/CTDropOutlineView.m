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

@interface CTDropOutlineView()<NSOutlineViewDataSource , NSOutlineViewDelegate>
@property (nonatomic , strong) NSScrollView* scrollView;
@property (nonatomic , strong) NSOutlineView* outlineView;
@property (nonatomic , strong) NSMutableArray* dataArray;
@property (nonatomic , strong) NSPasteboardType passtedboardType;
@end

@implementation CTDropOutlineView

-(void)configTestData{
    CTNode* root = [[CTNode alloc] init];
    root.name = @"root";
    
    CTNode* n1 = [[CTNode alloc] init];
    CTNode* n2 = [[CTNode alloc] init];
    CTNode* n3 = [[CTNode alloc] init];
    n1.name = @"n1";
    n2.name = @"n2";
    n3.name = @"n3";

    [root addNode:n1];
    [root addNode:n2];
    [root addNode:n3];
    
    CTNode* root1 = [[CTNode alloc] init];
    root1.name = @"root1";
    
    CTNode* n4 = [[CTNode alloc] init];
    CTNode* n5 = [[CTNode alloc] init];
    CTNode* n6 = [[CTNode alloc] init];
    
    n4.name = @"n4";
    n5.name = @"n5";
    n6.name = @"n6";
    
    [root1 addNode:n4];
    [root1 addNode:n5];
    [root1 addNode:n6];

    self.dataArray = [NSMutableArray arrayWithObjects:root,root1, nil];
    [self.outlineView reloadData];
    [self.outlineView expandItem:nil expandChildren:NO];
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
    
    self.outlineView = [[NSOutlineView alloc] init];
    self.outlineView.delegate = self;
    self.outlineView.dataSource = self;
    self.outlineView.indentationMarkerFollowsCell = YES;
    self.outlineView.indentationPerLevel = 16.0f;
    self.outlineView.headerView = nil;
    
    NSTableColumn* column = [[NSTableColumn alloc] initWithIdentifier:@"name"];
    [self.outlineView addTableColumn:column];
    
    self.scrollView = [[NSScrollView alloc] init];
    self.scrollView.hasVerticalScroller = NO;
    self.scrollView.focusRingType = NSFocusRingTypeNone;
    self.scrollView.autohidesScrollers = YES;
    self.scrollView.borderType = NSBezelBorder;
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.scrollView.documentView = self.outlineView;
    [self addSubview:self.scrollView];
    
    [self configScrollViewConstraint];

    
    [self.outlineView registerNib:[[NSNib alloc] initWithNibNamed:@"CTDropCell" bundle:[NSBundle mainBundle]] forIdentifier:column.identifier];
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
-(BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    return YES;
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
