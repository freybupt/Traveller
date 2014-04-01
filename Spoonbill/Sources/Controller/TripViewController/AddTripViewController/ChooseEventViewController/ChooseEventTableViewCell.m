//
//  ChooseEventTableViewCell.m
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-04-01.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "ChooseEventTableViewCell.h"

#define CHOOSEEVENT_TABLEVIEWCELL_PADDING 5.0f
#define CHOOSEEVENT_BUTTON_WIDTH 80.0f
#define CHOOSEEVENT_BUTTON_HEIGHT 35.0f

@implementation ChooseEventTableViewCell

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
    _button = [self newButton];
    [self addSubview:_button];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

#pragma mark - Configuration
- (UIButton *)newButton
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - CHOOSEEVENT_BUTTON_WIDTH - CHOOSEEVENT_TABLEVIEWCELL_PADDING * 2,
                                                                  CHOOSEEVENT_TABLEVIEWCELL_PADDING,
                                                                  CHOOSEEVENT_BUTTON_WIDTH,
                                                                  CHOOSEEVENT_BUTTON_HEIGHT)];
    [button setTitle:NSLocalizedString(@"Add", nil) forState:UIControlStateNormal];
    [button setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [button setTitle:NSLocalizedString(@"Remove", nil) forState:UIControlStateSelected];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    [button.layer setBorderColor:[UIColor grayColor].CGColor];
    [button.layer setBorderWidth:1.0f];
    
    return button;
}
@end
