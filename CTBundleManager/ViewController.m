//
//  ViewController.m
//  CTBundleManager
//
//  Created by 朱天超 on 2018/1/29.
//  Copyright © 2018年 ctrip.com. All rights reserved.
//

#import "ViewController.h"
#import "CTDropOutlineView.h"

@interface ViewController()<NSSearchFieldDelegate>
@property (weak) IBOutlet NSView *mainBackgroundView;
@property (weak) IBOutlet NSSearchField *searchField;
@property (weak) IBOutlet NSView *mainDrapBackgroundView;
@property (weak) IBOutlet CTDropOutlineView *excludeDropView;
@property (weak) IBOutlet CTDropOutlineView *bundleDropView;
@property (weak) IBOutlet CTDropOutlineView *sourceCodeDropView;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
}
- (IBAction)installAction:(NSButton *)sender {
}

- (IBAction)updateAction:(id)sender {
}

- (IBAction)helpAction:(id)sender {
    
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
