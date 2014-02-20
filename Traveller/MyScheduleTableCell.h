//
//  MyScheduleTableCell.h
//  Traveller
//
//  Created by Shirley on 2/17/2014.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>

@interface MyScheduleTableCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *eventTimeLabel;
@property (nonatomic, strong) IBOutlet UILabel *eventTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *eventLocationLabel;

- (void)setWithEvent:(EKEvent *)event;

@end
