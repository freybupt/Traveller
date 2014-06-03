//
//  MyScheduleFlightTableCell.h
//  Traveller
//
//  Created by Shirley on 2014-05-05.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "MyScheduleTableCell.h"

@interface MyScheduleFlightTableCell : MyScheduleTableCell


@property (nonatomic, weak) IBOutlet UIView *flightDetailView;
@property (nonatomic, weak) IBOutlet UILabel *departureTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *arrivalTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *departureAirportLabel;
@property (nonatomic, weak) IBOutlet UILabel *airlineWithDurationLabel;
@property (nonatomic, weak) IBOutlet UILabel *arrivalAirportLabel;


@end
