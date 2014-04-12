//
//  AddCityTableViewCell.m
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-03-25.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "AddCityTableViewCell.h"

@implementation AddCityTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib
{
    _textField = [self newTextField];
    [self addSubview:_textField];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (UITextField *)newTextField
{
    CGFloat x = ADDCITY_TABLEVIEWCELL_PADDING * 3;
    CGFloat y = ADDCITY_TABLEVIEWCELL_PADDING;
    CGFloat width = self.frame.size.width - x * 2;
    CGFloat height = self.frame.size.height - y * 2;
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(x, y, width, height)];
    
    return textField;
}

@end
