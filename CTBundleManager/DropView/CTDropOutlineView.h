//
//  CTDropOutlineView.h
//  CTBundleManager
//
//  Created by 朱天超 on 2018/1/30.
//  Copyright © 2018年 ctrip.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol  CTDropOutlineViewDelegate <NSObject>

-(BOOL)acceptDrag:(id)node;

@end

@interface CTDropOutlineView : NSView
@property(nonatomic , weak) IBOutlet id<CTDropOutlineViewDelegate> delegate;
-(void)updateDataArray:(NSMutableArray*)array;
@end








