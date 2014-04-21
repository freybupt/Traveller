//
//  DepartureTableViewCell.m
//  Traveller
//
//  Created by WEI-JEN TU on 2014-04-21.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "DepartureTableViewCell.h"

@implementation DepartureTableViewCell

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
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _label = [self newLabel];
    [self addSubview:_label];
    
    _textField = [self newTextField];
    [self addSubview:_textField];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

#pragma mark - Configuration
- (UILabel *)newLabel
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(32.0f,
                                                               (self.frame.size.height - 30.0f)/2,
                                                               150.0f,
                                                               30.0f)];
    label.textColor = UIColorFromRGB(0xACB7BA);
    label.font = [UIFont systemFontOfSize:14.0f];
    label.text = NSLocalizedString(@"Departing from:", nil);
    
    return label;
}

- (BDTextField *)newTextField
{
    BDTextField *field = [[BDTextField alloc] initWithFrame:CGRectMake(145.0f,
                                                                       (self.frame.size.height - 30.0f)/2,
                                                                       138.0f,
                                                                       30.0f)];
    field.textField.placeholder = NSLocalizedString(@"City Name", nil);
    
    return field;
}
@end
