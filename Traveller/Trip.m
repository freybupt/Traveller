//
//  Trip.m
//  Traveller
//
//  Created by Shirley on 2/21/2014.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "Trip.h"
#import "CalendarColorManager.h"

@implementation Trip

- (id)initWithDateRange:(DSLCalendarRange *)range
          departureCity:(NSString *)departureCityName
         andDestination:(NSString *)destinationCityName
            isRoundTrip:(BOOL)isRoundTrip
{
    if (self = [super init]) {
        self.dateRange = range;
        self.departureCity = [[City alloc] initWithCityName:departureCityName];
        self.destinationCity = [[City alloc] initWithCityName:destinationCityName];
        self.isRoundTrip = isRoundTrip;
        self.defaultColor = [[CalendarColorManager sharedManager] getActiveColor:YES];
    }
    
    return self;
}

- (id)initWithExistingTrip:(Trip *)trip
{
    if (self = [super init]) {
        self.dateRange = trip.dateRange;
        self.departureCity = trip.departureCity;
        self.destinationCity = trip.departureCity;
        self.isRoundTrip = trip.isRoundTrip;
        self.defaultColor = trip.defaultColor;
    }
    
    return self;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[Trip class]]) {
        Trip *trip = (Trip *)object;
        if ([trip.dateRange.startDay isEqual:self.dateRange.startDay] &&
            [trip.dateRange.endDay isEqual:self.dateRange.endDay]) {
            return YES;
        }
    }
    
    return NO;
}

@end
