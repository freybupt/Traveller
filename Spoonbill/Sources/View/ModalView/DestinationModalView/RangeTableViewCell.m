//
//  RangeTableViewCell.m
//  Traveller
//
//  Created by WEI-JEN TU on 2014-04-21.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "RangeTableViewCell.h"

@implementation RangeTableViewCell

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
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

#pragma mark - Configuration
- (UILabel *)newLabel
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8.0f * 4,
                                                               (self.frame.size.height - 20.0f)/2,
                                                               self.frame.size.width - 8.0f * 6,
                                                               20.0f)];
    label.textColor = UIColorFromRGB(0xACB7BA);
    label.font = [UIFont systemFontOfSize:14.0f];
    label.text = NSLocalizedString(@"Month startDay-endDay, Year", nil);
    
    return label;
}
@end
