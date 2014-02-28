//
//  Trip.h
//  Traveller
//
//  Created by Shirley on 2/21/2014.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DSLCalendarRange.h"
#import "City.h"

@interface Trip : NSObject

@property (nonatomic, strong) DSLCalendarRange *dateRange;
@property (nonatomic, strong) City *departureCity;
@property (nonatomic, strong) City *destinationCity;
@property (nonatomic, assign) BOOL isRoundTrip;
@property (nonatomic, strong) UIColor *defaultColor;

@property (nonatomic, strong) NSMutableArray *events; //include schedule, flight, hotel and etc


- (id)initWithDateRange:(DSLCalendarRange *)range
          departureCity:(NSString *)departureCityName
         andDestination:(NSString *)destinationCityName
            isRoundTrip:(BOOL)isRoundTrip;

- (id)initWithExistingTrip:(Trip *)trip;

@end
