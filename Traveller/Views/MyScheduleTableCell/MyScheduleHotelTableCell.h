//
//  MyScheduleHotelTableCell.h
//  Traveller
//
//  Created by Shirley on 2014-05-05.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "MyScheduleTableCell.h"

@interface MyScheduleHotelTableCell : MyScheduleTableCell

@property (nonatomic, weak) IBOutlet UIView *hotelDetailView;
@property (nonatomic, weak) IBOutlet UILabel *addressLabel;
@property (nonatomic, weak) IBOutlet UILabel *phoneLabel;
@property (nonatomic, weak) IBOutlet UILabel *checkinLabel;
@property (nonatomic, weak) IBOutlet UILabel *checkoutLabel;
@property (nonatomic, weak) IBOutlet UILabel *roomTypeLabel;
@property (nonatomic, weak) IBOutlet UILabel *amenitiesLabel;
@property (nonatomic, weak) IBOutlet UILabel *reviewLabel;
@property (nonatomic, weak) IBOutlet UILabel *distanceLabel;


@end
