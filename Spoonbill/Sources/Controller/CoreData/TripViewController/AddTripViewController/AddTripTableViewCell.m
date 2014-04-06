//
//  AddTripTableViewCell.m
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-03-30.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "AddTripTableViewCell.h"

@implementation AddTripTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _toggle = [self newToggle];
        [self addSubview:_toggle];
        
        _datePicker = [self newDatePicker];
        [self addSubview:_datePicker];
    }
    return self;
}

#pragma mark - Configuration
- (UISwitch *)newToggle
{
    UISwitch *toggle = [[UISwitch alloc] initWithFrame:CGRectMake(self.frame.size.width - 52.0f - ADDCITY_TABLEVIEWCELL_PADDING*2, (ADDCITY_TABLEVIEWCELL_HEIGHT - 32.0f)/2, 52.0f, 32.0f)];
    toggle.hidden = YES;

    return toggle;
}

#pragma mark - Configuration
- (UIDatePicker *)newDatePicker
{
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, DEFAULT_DATECELL_HEIGHT)];
    datePicker.hidden = YES;
    
    return datePicker;
}
@end
