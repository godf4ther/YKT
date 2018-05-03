//
//  HisCell.h
//  YKT
//
//  Created by 周春仕 on 2018/5/3.
//  Copyright © 2018年 周春仕. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HisCellDelegate <NSObject>

- (void)didSelectHisCity:(NSDictionary *)hotCity;

@end

@interface HisCell : UITableViewCell
@property (nonatomic, weak) id<HisCellDelegate>delegate;
@property (nonatomic, copy) NSArray *dataArr;
- (instancetype)initWithDataArr:(NSArray *)dataArr;
@end
