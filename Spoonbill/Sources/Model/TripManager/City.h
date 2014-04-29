//
//  City.h
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-04-29.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Branch, Event, Hotel, Trip;

@interface City : NSManagedObject

@property (nonatomic, retain) NSString * cityCode;
@property (nonatomic, retain) NSString * cityName;
@property (nonatomic, retain) NSString * countryCode;
@property (nonatomic, retain) NSString * countryName;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * latitudeRef;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * longitudeRef;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSSet *toEvent;
@property (nonatomic, retain) NSSet *toTripDepartureCity;
@property (nonatomic, retain) NSSet *toTripDestinationCity;
@property (nonatomic, retain) Branch *toBranch;
@property (nonatomic, retain) Hotel *toHotel;
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
