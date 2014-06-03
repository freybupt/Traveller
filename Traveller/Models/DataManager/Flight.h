//
//  Flight.h
//  Traveller
//
//  Created by WEI-JEN TU on 2014-05-02.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class City;

@interface Flight : NSManagedObject


@property (nonatomic, retain) NSString * airline;
@property (nonatomic, retain) NSString * departureCode;
@property (nonatomic, retain) NSString * arrivalCode;
@property (nonatomic, retain) NSString * departureAirport;
@property (nonatomic, retain) NSString * arrivalAirport;
@property (nonatomic, retain) NSString * departureCity;
@property (nonatomic, retain) NSString * departureCountry;
@property (nonatomic, retain) NSDate * departureTime;
@property (nonatomic, retain) NSString * arrivalCity;
@property (nonatomic, retain) NSString * arrivalCountry;
@property (nonatomic, retain) NSDate * arrivalTime;
@property (nonatomic, retain) NSString * designatorCode;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * uid;

@property (nonatomic, retain) City *toCity;

@end
