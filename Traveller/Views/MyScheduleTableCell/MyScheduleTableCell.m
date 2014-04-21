//
//  MyScheduleTableCell.m
//  Traveller
//
//  Created by Shirley on 2/17/2014.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "MyScheduleTableCell.h"


@implementation MyScheduleTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)checkBoxClicked
{
    if (self.event) {
        //change event isSelect status - didn't work
//        BOOL isSelected = !self.checkBox.isSelected;
//        self.event.isSelected = [NSNumber numberWithBool: isSelected];
    }
}

@end
