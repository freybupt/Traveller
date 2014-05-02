//
//  City.h
//  Traveller
//
//  Created by WEI-JEN TU on 2014-05-02.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event, Location, Trip;

@interface City : NSManagedObject

@property (nonatomic, retain) NSString * cityCode;
@property (nonatomic, retain) NSString * cityName;
@property (nonatomic, retain) NSString * countryCode;
@property (nonatomic, retain) NSString * countryName;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSSet *toEvent;
@property (nonatomic, retain) Location *toLocation;
@property (nonatomic, retain) NSSet *toTripDepartureCity;
@property (nonatomic, retain) NSSet *toTripDestinationCity;
@property (nonatomic, retain) NSManagedObject *toFlight;
@end

@interface City (CoreDataGeneratedAccessors)

- (void)addToEventObject:(Event *)value;
- (void)removeToEventObject:(Event *)value;
- (void)addToEvent:(NSSet *)values;
- (void)removeToEvent:(NSSet *)values;

- (void)addToTripDepartureCityObject:(Trip *)value;
- (void)removeToTripDepartureCityObject:(Trip *)value;
- (void)addToTripDepartureCity:(NSSet *)values;
- (void)removeToTripDepartureCity:(NSSet *)values;

- (void)addToTripDestinationCityObject:(Trip *)value;
- (void)removeToTripDestinationCityObject:(Trip *)value;
- (void)addToTripDestinationCity:(NSSet *)values;
- (void)removeToTripDestinationCity:(NSSet *)values;

@end
