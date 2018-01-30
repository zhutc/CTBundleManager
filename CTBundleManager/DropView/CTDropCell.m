//
//  CTDropCell.m
//  CTBundleManager
//
//  Created by 朱天超 on 2018/1/30.
//  Copyright © 2018年 ctrip.com. All rights reserved.
//

#import "CTDropCell.h"

@implementation CTDropCell

//-(instancetype)init{
//    self = [super init];
//    if (self) {
//        self.customField = [[NSTextField alloc] initWithFrame:NSRectFromCGRect(CGRectMake(0, 0, 200, 30))];
//        self.customField.editable = NO;
//        self.customField.textColor = [NSColor blackColor];
//        self.customField.backgroundColor = [NSColor clearColor];
//        self.customField.bordered = NO;
//        [self addSubview:self.customField];
//    }
//    return self;
//}
//
//- (void)drawRect:(NSRect)dirtyRect {
//    [super drawRect:dirtyRect];
//    [[NSColor clearColor] setFill];
//}

- (void)awakeFromNib
{
    NSLog(@"CTDropCell awakeFromNib");
}

@end
