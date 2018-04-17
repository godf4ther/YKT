//
//  MyOrderListCell.m
//  YKT
//
//  Created by 周春仕 on 2018/4/17.
//  Copyright © 2018年 周春仕. All rights reserved.
//

#import "MyOrderListCell.h"
#import "LRMacroDefinitionHeader.h"
@implementation MyOrderListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    LRViewBorderRadius(self.container, 5, 1, [UIColor whiteColor]);
    LRViewShadow(self.container, [UIColor blackColor], CGSizeMake(2, 2), 0.3, 5);
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
