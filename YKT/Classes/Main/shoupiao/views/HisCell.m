//
//  HisCell.m
//  YKT
//
//  Created by 周春仕 on 2018/5/3.
//  Copyright © 2018年 周春仕. All rights reserved.
//

#import "HisCell.h"
#import "LRMacroDefinitionHeader.h"
@implementation HisCell


- (instancetype)initWithDataArr:(NSArray *)dataArr{
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HotCell"]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.dataArr = dataArr;
        NSInteger Hnum = dataArr.count % 3 == 0 ? dataArr.count / 3 : dataArr.count / 3 + 1;
        CGFloat spaceH = 12;
        CGFloat spaceS = 12;
        CGFloat ButtonHeight = 32;
        CGFloat ButtonWidth = (SIZEWIDTH - 48) / 3;
        self.frame = CGRectMake(0, 0, SIZEWIDTH,(2 + Hnum - 1) * spaceS + Hnum * ButtonHeight);
        for (int i = 0; i < dataArr.count; i ++) {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(12 + i % 3 * (ButtonWidth + spaceH),12 + i / 3 * (ButtonHeight + spaceS) , ButtonWidth, ButtonHeight)];
            button.tag = i;
            [button setTitle:dataArr[i][@"StationName"] forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:13];
            [button setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] forState:UIControlStateNormal];
            button.layer.borderWidth = 1;
            button.layer.borderColor = [UIColor colorWithRed:229/255.0 green:229/255.0 blue:229/255.0 alpha:1].CGColor;
            [button addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
        }
    }
    return self;
}


- (void)btnAction:(UIButton *)sender{
    [self.delegate didSelectHisCity:self.dataArr[sender.tag]];
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
