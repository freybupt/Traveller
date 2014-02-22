//
//  CalendarTripDayObject.h
//  Traveller
//
//  Created by Shirley on 2/21/2014.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CityObject;

@interface CalendarTripDayObject : NSObject

@property (nonatomic, strong) NSDateComponents *day;
@property (nonatomic, strong) CityObject *city;


@end
