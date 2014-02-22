//
//  CalendarTripObject.h
//  Traveller
//
//  Created by Shirley on 2/21/2014.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CityObject, DSLCalendarRange;

@interface CalendarTripObject : NSObject

@property (nonatomic, strong) DSLCalendarRange *tripRange;
@property (nonatomic, strong) CityObject *departureCity;
@property (nonatomic, strong) CityObject *destinationCity;

@end
