//
//  CalendarView.h
//  Traveller
//
//  Created by Shirley on 2/21/2014.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "DSLCalendarView.h"

@interface CalendarView : DSLCalendarView

@property (nonatomic, strong) NSMutableArray *savedTripRanges;
@property (nonatomic, strong) Trip *editingTrip;
@property (nonatomic, strong) Trip *originalTrip;

@end
