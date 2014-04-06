//
//  PLPlanTripTableViewCell.m
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-04-06.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "PLPlanTripTableViewCell.h"

#define PLANTRIP_CHECKBOX_WIDTH 25.0f
#define PLANTRIP_CHECKBOX_HEIGHT 35.0f
#define PLANTRIP_TIMELABEL_WIDTH 60.0f
#define PLANTRIP_TIMELABEL_HEIGHT 35.0f
#define PLANTRIP_TITLELABEL_WIDTH 180.0f
#define PLANTRIP_TITLELABEL_HEIGHT 20.0f
#define PLANTRIP_LOCATIONLABEL_WIDTH 180.0f
#define PLANTRIP_LOCATIONLABEL_HEIGHT 15.0f

@implementation PLPlanTripTableViewCell

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
    self.accessoryType = UITableViewCellAccessoryDetailButton;
    
    _checkBox = [self newCheckBox];
    [self.contentView addSubview:_checkBox];
    
    _timeLabel = [self newTimeLabel];
    [self.contentView addSubview:_timeLabel];
    
    _titleLabel = [self newTitleLabel];
    [self.contentView addSubview:_titleLabel];
    
    _locationLabel = [self newLocationLabel];
    [self.contentView addSubview:_locationLabel];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

#pragma mark - Configuration
- (Checkbox *)newCheckBox
{
    Checkbox *checkBox = [[Checkbox alloc] initWithFrame:CGRectMake(PLANTRIP_TABLEVIEWCELL_PADDING,
                                                                    (PLANTRIP_TABLEVIEWCELL_HEIGHT - PLANTRIP_CHECKBOX_HEIGHT)/2,
                                                                    PLANTRIP_CHECKBOX_WIDTH,
                                                                    PLANTRIP_CHECKBOX_HEIGHT)];
    checkBox.backgroundColor = [UIColor whiteColor];
    return checkBox;
}

- (UILabel *)newTimeLabel
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(PLANTRIP_CHECKBOX_WIDTH + PLANTRIP_TABLEVIEWCELL_PADDING * 2,
                                                               (PLANTRIP_TABLEVIEWCELL_HEIGHT - PLANTRIP_TIMELABEL_HEIGHT)/2,
                                                               PLANTRIP_TIMELABEL_WIDTH,
                                                               PLANTRIP_TIMELABEL_HEIGHT)];
    label.text = @"8:00 AM";
    label.font = [UIFont systemFontOfSize:13.0f];
    return label;
}

- (UILabel *)newTitleLabel
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(PLANTRIP_CHECKBOX_WIDTH + PLANTRIP_TIMELABEL_WIDTH + PLANTRIP_TABLEVIEWCELL_PADDING * 3,
                                                               PLANTRIP_TABLEVIEWCELL_PADDING * 2,
                                                               PLANTRIP_TITLELABEL_WIDTH,
                                                               PLANTRIP_TITLELABEL_HEIGHT)];
    label.text = @"Event Name";
    label.font = [UIFont boldSystemFontOfSize:16.0f];
    return label;
}

- (UILabel *)newLocationLabel
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(PLANTRIP_CHECKBOX_WIDTH + PLANTRIP_TIMELABEL_WIDTH + PLANTRIP_TABLEVIEWCELL_PADDING * 3,
                                                               PLANTRIP_TABLEVIEWCELL_PADDING * 2 + PLANTRIP_TITLELABEL_HEIGHT,
                                                               PLANTRIP_LOCATIONLABEL_WIDTH,
                                                               PLANTRIP_LOCATIONLABEL_HEIGHT)];
    label.text = @"Location";
    label.font = [UIFont systemFontOfSize:14.0f];
    return label;
}
@end
