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
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setWithEvent:(EKEvent *)event
{
    if (event) {
        self.eventTitleLabel.text = event.title;
        
        if (event.allDay) {
            self.eventTimeLabel.text = @"all-day";
        }
        else{
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"HH:mm"];
            [formatter setTimeZone:[NSTimeZone localTimeZone]];
            self.eventTimeLabel.text = [formatter stringFromDate:event.startDate];
        }
        
        
        self.eventLocationLabel.text = event.location;
        
    }
}

@end
