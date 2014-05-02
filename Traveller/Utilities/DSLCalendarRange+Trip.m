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
        return [[DSLCalendarRange alloc] initWithStartDay:self.startDay endDay:[[self.endDay.date dateAtMidnight] dateComponents]];
    }

    NSDateComponents *adjustedActiveEndDateComponents = [[[self.endDay.date dateAfterOneDay] dateAtMidnight] dateComponents];
    NSDateComponents *tripStartDateComponents = [trip.startDate dateComponents];
    NSDateComponents *tripEndDateComponents = [trip.endDate dateComponents];
    
    if ([self.startDay.date withinSameDayWith:trip.startDate] &&
        [self.endDay.date withinSameDayWith:trip.endDate]) {
        return [[DSLCalendarRange alloc] initWithStartDay:tripStartDateComponents
                                                   endDay:tripEndDateComponents];
    } else if ([self.startDay.date withinSameDayWith:trip.startDate]) {
        
        if ([[[self.endDay.date dateAfterOneDay] dateAtMidnight] compare:trip.endDate] < NSOrderedSame) {
            return [[DSLCalendarRange alloc] initWithStartDay:self.endDay
                                                       endDay:tripEndDateComponents];
        }
        return [[DSLCalendarRange alloc] initWithStartDay:self.startDay
                                                   endDay:adjustedActiveEndDateComponents];
    
    } else if ([self.endDay.date withinSameDayWith:trip.endDate]) {
        
        if ([self.startDay.date compare:trip.startDate] > NSOrderedSame) {
            return [[DSLCalendarRange alloc] initWithStartDay:tripStartDateComponents
                                                       endDay:[[[self.startDay.date dateAfterOneDay] dateAtMidnight] dateComponents]];
        }
        return [[DSLCalendarRange alloc] initWithStartDay:self.startDay
                                                   endDay:adjustedActiveEndDateComponents];
    
    } else if ([self.endDay.date withinSameDayWith:trip.startDate]) {
        return [[DSLCalendarRange alloc] initWithStartDay:self.startDay
                                                   endDay:tripEndDateComponents];
    } else if ([self.startDay.date withinSameDayWith:trip.endDate]) {
        return [[DSLCalendarRange alloc] initWithStartDay:tripStartDateComponents
                                                   endDay:adjustedActiveEndDateComponents];
    }
    
    return [[DSLCalendarRange alloc] initWithStartDay:tripStartDateComponents endDay:tripEndDateComponents];
}
@end
