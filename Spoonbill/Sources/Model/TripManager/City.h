//
//  City.h
//  Spoonbill
//
//  Created by WEI-JEN TU on 2014-03-31.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event, Trip;

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
@property (nonatomic, retain) Trip *toTripDepartureCity;
@property (nonatomic, retain) Trip *toTripDestinationCity;
@property (nonatomic, retain) Event *toEvent;

@end
