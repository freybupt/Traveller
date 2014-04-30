//
//  DSLCalendarRange+Trip.m
//  Traveller
//
//  Created by WEI-JEN TU on 2014-04-30.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "DSLCalendarRange+Trip.h"

@implementation DSLCalendarRange (Trip)
- (DSLCalendarRange *)joinedCalendarRangeWithTrip:(Trip *)trip
{
    if (!trip) {
        return self;
    }
    
    if ([self.endDay.date compare:trip.startDate] == NSOrderedSame) {
        return [[DSLCalendarRange alloc] initWithStartDay:self.startDay endDay:[trip.endDate dateComponents]];
    } else if ([[[self.startDay.date dateAfterOneDay] dateAtMidnight] compare:trip.endDate] == NSOrderedSame) {
        return [[DSLCalendarRange alloc] initWithStartDay:[trip.startDate dateComponents] endDay:self.endDay];
    }
    
    return self;
}
@end
