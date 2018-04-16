//
//  TickerOrderPeople.m
//  YKT
//
//  Created by 周春仕 on 2018/4/13.
//  Copyright © 2018年 周春仕. All rights reserved.
//

#import "TickerOrderPeople.h"
#import "LRMacroDefinitionHeader.h"

@interface TickerOrderPeople()
{
    CGRect myframe;
}
@end

@implementation TickerOrderPeople

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self = [[NSBundle mainBundle] loadNibNamed:@"TickerOrderPeople" owner:self options:nil].firstObject;
        myframe = frame;
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    self.bounds = CGRectMake(0, 0, SIZEWIDTH, 85);
}

- (void)layoutSubviews {
    self.frame = myframe;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    self.frame = myframe;
}
- (IBAction)gouAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender == self.gou1) {
        self.gblock(1, sender.selected);
    }
    else {
        self.gblock(2, sender.selected);
    }
}
- (IBAction)delete:(id)sender {
    self.deblock();
}




@end
