//
//  CTLogPanel.m
//  CTBundleManager
//
//  Created by 朱天超 on 2018/2/1.
//  Copyright © 2018年 ctrip.com. All rights reserved.
//

#import "CTLogPanel.h"

@interface CTLogPanel()
@property (weak) IBOutlet NSProgressIndicator *incator;
@property (unsafe_unretained) IBOutlet NSTextView *textView;
@property (weak) IBOutlet NSButton *okButton;


@end


@implementation CTLogPanel

+(CTLogPanel *)logPanel
{
    NSMutableArray* array = nil;
    NSNib* nib = [[NSNib alloc] initWithNibNamed:@"CTLogPanel" bundle:[NSBundle mainBundle]];
    [nib instantiateWithOwner:nil topLevelObjects:&array];
    for (id obj in array) {
        if ([obj isKindOfClass:[CTLogPanel class]]) {
            [(NSWindow *)obj setShowsResizeIndicator:NO];
            return obj;
        }
    }
    return nil;
}

- (IBAction)okAction:(id)sender {
    [self.sheetParent endSheet:self
        returnCode:NSModalResponseOK];
}
-(void)start
{
    self.okButton.hidden = YES;
    self.incator.hidden = NO;
    [self.incator startAnimation:nil];
}
-(void)end
{
    self.okButton.hidden = NO;
    self.incator.hidden = YES;
    [self.incator stopAnimation:nil];
}
-(void)upateCotent:(NSString *)text
{
    NSString* originText = self.textView.string;
    if (nil == originText) {
        originText = @"";
    }
    originText = [originText stringByAppendingFormat:@"\n%@",text];
    self.textView.string = originText;
//    [self.textView scrollPageUp:<#(nullable id)#>]
}

@end
